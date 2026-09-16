---
title: "O número de partição que você escolheu no dia 1 não precisa te acompanhar pra sempre"
date: 2026-09-15T09:00:00-03:00
draft: false
tags: ["Databricks", "Structured Streaming", "Apache Spark", "Data Engineering", "Performance"]
summary: "Até a Databricks Runtime 18, mudar spark.sql.shuffle.partitions numa query stateful com checkpoint já criado simplesmente não fazia nada. O repartition sob demanda (Public Preview) resolve isso sem exigir reconstrução do checkpoint do zero, e a Coveo já reportou 40% de redução de custo de API do S3 usando ele."
ShowToc: true
---

Toda query stateful de Structured Streaming carrega uma decisão que parecia definitiva: o número de partição de shuffle escolhido no dia em que o checkpoint foi criado. Errou o número, geralmente porque o volume real de produção só aparece meses depois do valor padrão de 200 ter sido aceito sem pensar muito, e a opção histórica era binária, ou aceitar a partição errada indefinidamente, ou abandonar o checkpoint inteiro (e o estado acumulado nele) pra recriar a query do zero com o valor certo. Pra job que já processou meses de sessão de usuário ou de janela de agregação, "abandonar o checkpoint" nunca foi uma opção real.

O repartition sob demanda, agora em Public Preview na Databricks Runtime 18, existe justamente pra fechar essa lacuna: mudar o número de partição de uma query com estado, sem perder o que já foi acumulado.

## O mecanismo: por que isso nunca foi trivial

O estado de uma query stateful no Structured Streaming não é um número solto, é dado físico, guardado em instância de RocksDB dentro do checkpoint, uma por partição. Cada chave da sua agregação é distribuída entre partição via hash, então o número de partição não é metadado de configuração, ele define literalmente onde cada chave mora fisicamente em disco. Mudar `spark.sql.shuffle.partitions` depois que o checkpoint já existe não tinha efeito nenhum, porque o motor continuava lendo o número de partição gravado na primeira execução, e mudar esse número sem redistribuir o dado físico primeiro corromperia a relação entre chave e partição.

O repartition sob demanda resolve isso com uma operação explícita e única: a query termina o microbatch pendente, executa uma redistribuição que rehash cada chave pro novo número de partição, e só depois volta a processar normalmente. É uma pausa controlada, não uma migração em segundo plano, e o tempo dela aparece de forma auditável no evento `StreamingQueryProgress`, no campo `durationMs.controlBatch.REPARTITION`.

**Minha leitura:** o detalhe que mais chama atenção aqui não é a feature em si, é o quanto ela expõe uma dívida técnica silenciosa que provavelmente existe em produção agora mesmo. Muita equipe aceita os 200 de padrão do `spark.sql.shuffle.partitions` sem questionar, porque na hora de escrever a query stateful ninguém sabe ainda qual vai ser o volume real seis meses depois. Antes dessa feature, essa decisão de dia 1 virava praticamente permanente. Vale já mapear quais das suas queries stateful mais antigas nunca tiveram o número de partição revisitado desde a criação, essa é a lista de candidata a ganho de graça.

## Mão na massa: escalando uma query já em produção

O requisito é Databricks Runtime 18 LTS ou superior, com o state store provider RocksDB (que já é o padrão desde a DBR 17.3). A troca em si é feita parando a query, ajustando a configuração, e reiniciando com o mesmo checkpoint:

```python
# Query original, criada com o padrão de 200 partições
query = (df
  .withWatermark("event_time", "10 minutes")
  .groupBy(window("event_time", "5 minutes"), "id")
  .count()
  .writeStream
  .format("delta")
  .option("checkpointLocation", "/checkpoint/path")
  .outputMode("append")
  .start()
)

# Volume cresceu, 200 partições não bastam mais: escalando para 600
query.stop()
spark.conf.set("spark.sql.streaming.stateStore.partitions", "600")

query = (df
  .withWatermark("event_time", "10 minutes")
  .groupBy(window("event_time", "5 minutes"), "id")
  .count()
  .writeStream
  .format("delta")
  .option("checkpointLocation", "/checkpoint/path")  # mesmo checkpoint
  .outputMode("append")
  .start()
)
```

O detalhe que importa aqui é que `spark.sql.streaming.stateStore.partitions` passa a valer mais que `spark.sql.shuffle.partitions` pra essa query especificamente, então não é preciso reescrever a lógica de agregação nem mexer em nenhum outro parâmetro, só reiniciar com o checkpoint intacto. Em Lakeflow Pipelines, o mesmo ajuste entra via `spark_conf` no decorador do flow ou da tabela, sem precisar de reinício manual fora do ciclo normal de deploy do pipeline:

```python
@dp.append_flow(
  target="tabela_sessoes",
  name="agregacao_sessao",
  spark_conf={"spark.sql.streaming.stateStore.partitions": "600"}
)
def agregacao_sessao():
    return (spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "json")
        .load(caminho_origem)
        .withWatermark("timestamp", "10 minutes")
        .groupBy(window("timestamp", "5 minutes"), "id")
        .count())
```

## O ganho documentado: não é só velocidade, é fatura de storage

O caso publicado pela própria Databricks vem da Coveo, que reportou 40% de redução de custo de chamada de API do Amazon S3 depois de conseguir ajustar o particionamento de estado sem precisar migrar o checkpoint inteiro. Isso é uma pista importante sobre onde o ganho realmente aparece: partição de estado mal dimensionada não é só um problema de latência de processamento, é também volume desnecessário de chamada de leitura e escrita contra o object storage por trás do checkpoint. Partição de menos concentra chamada demais numa instância de RocksDB só; partição de mais espalha overhead de coordenação sem necessidade. Os dois extremos custam dinheiro de um jeito que só aparece de verdade na fatura de armazenamento, não no dashboard de latência.

## Como saber que número escolher (e como confirmar que funcionou)

Antes de disparar um repartition, vale medir dois números: o tamanho atual do estado por partição (visível na métrica `stateOperators` dentro do evento `StreamingQueryProgress`, campo `numRowsTotal` por operador) e a distribuição de carga entre partições, já que uma chave com cardinalidade muito maior que as outras concentra volume desproporcional numa única partição de RocksDB independente de quantas partições existam no total. Se o problema for volume total crescendo de forma uniforme, aumentar o número de partição resolve. Se o problema for uma chave específica dominando o volume (hot key), aumentar partição sozinho não ajuda muito, o gargalo está na distribuição da chave, não na contagem de partição.

Depois de rodar o repartition, o mesmo evento `StreamingQueryProgress` que registrou a duração da operação em `durationMs.controlBatch.REPARTITION` volta a reportar métrica normal de processamento no microbatch seguinte. Comparar o tempo médio de microbatch antes e depois da mudança, junto com a métrica de leitura de storage (se disponível no seu ambiente de observabilidade), é o jeito mais direto de confirmar que o ajuste teve o efeito esperado, em vez de assumir que "mais partição é sempre melhor" e seguir em frente sem medir.

## O que isso não resolve

O repartition sob demanda exige parar a query pra rodar, não é um ajuste vivo em tempo real, então ainda existe uma janela de pausa proporcional ao tamanho do estado acumulado, estado grande demora mais pra redistribuir. A feature também exige RocksDB como state store provider, quem ainda estiver no provider em memória (HDFS state store, o mais antigo) precisa migrar antes de sequer cogitar usar isso. E o recurso está em Public Preview na Databricks Runtime 18, então antes de aplicar em query crítica de produção vale testar o tempo de repartition contra um checkpoint de tamanho comparável num ambiente de não produção, o tempo de pausa em si não é documentado como previsível de antemão, só sabemos que "estado maior aumenta o tempo".

## Vale a pena revisitar sua configuração?

Se sua query stateful mais antiga nunca teve o número de partição revisado desde a criação, e o volume de dado cresceu desde então (o que é o caso comum), vale o exercício de medir o tamanho de estado atual e comparar com o número de partição herdado do dia 1. O ganho documentado pela Coveo sugere que esse tipo de ajuste tardio, que antes exigia reconstrução total do checkpoint (e por isso quase nunca acontecia na prática), agora tem custo operacional baixo o suficiente pra virar rotina de revisão periódica, não só um recurso de emergência.

## Referências

- Databricks Docs, "On-demand state repartitioning for stateful streaming queries": https://docs.databricks.com/aws/en/structured-streaming/state-repartitioning
- Microsoft Learn, "On-demand state repartitioning for stateful streaming queries - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/structured-streaming/state-repartitioning
- Databricks Blog, "Announcing On-Demand State Repartitioning for Apache Spark Structured Streaming on Databricks": https://www.databricks.com/blog/announcing-demand-state-repartitioning-apache-sparktm-structured-streaming-databricks

#Databricks #StructuredStreaming #ApacheSpark #Performance
