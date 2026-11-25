---
title: "Chega de ForeachWriter escrito à mão: o sink nativo do Lakebase chegou em GA"
date: 2026-11-24T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Lakebase", "Structured Streaming", "Spark"]
ShowToc: true
summary: "O sink nativo de Lakebase Postgres pro Spark Structured Streaming saiu de Beta pra Disponibilidade Geral, substituindo semanas de ForeachWriter customizado (backpressure, pool de conexão, retry, upsert) por uma chamada única de writeStream, com estratégia de merge configurável e, num benchmark publicado, latência ponta a ponta na casa dos 183 milissegundos sob 20 mil eventos por segundo."
---

Quem já precisou escrever resultado de um streaming do Spark direto num banco relacional conhece o trabalho que normalmente vem escondido atrás de "é só implementar um ForeachWriter". Tem que lidar com lote e fila limitada pra controlar contrapressão, pool de conexão, renovação de token OAuth, retry com backoff pra erro transitório, deduplicação dentro do próprio lote, e a semântica certa de upsert (manter o timestamp mais recente, só atualizar coluna quando o valor de ordenação que chegou é mais novo que o já gravado). A Databricks chama isso de semanas de trabalho inicial, mais manutenção contínua depois.

O sink nativo de Lakebase Postgres pro Spark Structured Streaming, agora em Disponibilidade Geral a partir do Databricks Runtime 18 LTS, resolve isso embutindo tudo isso dentro de uma única chamada `writeStream`, com a mesma API já usada pra escrever em tabela do Unity Catalog.

## O mecanismo: a mesma API de sempre, com upsert e merge configurável

Pra tabela Lakebase já registrada no Unity Catalog, a escrita usa exatamente o padrão `.toTable()`:

```python
(df.writeStream
   .outputMode("update")
   .option("upsertkey", "<colunas-de-chave-primaria>")
   .option("checkpointLocation", "/Volumes/<catalogo>/<schema>/<volume>/<nome-checkpoint>")
   .toTable("<catalogo>.<schema>.<tabela>"))
```

Pra tabela Lakebase que ainda não está registrada no Unity Catalog, a escrita aponta direto pro endpoint:

```python
(df.writeStream
   .format("postgresql")
   .outputMode("update")
   .option("endpoint", "<id-do-projeto>.<id-do-branch>.<id-do-endpoint>")
   .option("dbtable", "<schema>.<tabela>")
   .option("upsertkey", "<colunas-de-chave-primaria>")
   .option("checkpointLocation", "/Volumes/<catalogo>/<schema>/<volume>/<nome-checkpoint>")
   .start())
```

E, a partir do Databricks Runtime 19, o mesmo sink alcança até PostgreSQL externo (RDS, autogerenciado) via conexão do Unity Catalog, ainda em Public Preview, usando `.option("databricks.connection", "<nome-da-conexao>")` no lugar do endpoint direto.

Autenticação e reuso de conexão são automáticos, como usuário em execução ou service principal. Erro transitório de JDBC (falha de conexão, deadlock, limitação de taxa) é reprocessado com backoff exponencial, sem precisar de nenhum código de retry próprio. O agrupamento em lote também é automático, controlado por dois limites configuráveis: `batchsize` (1000 linhas por padrão) e `batchinterval` (100 milissegundos por padrão), e o flush acontece assim que qualquer um dos dois limites é atingido primeiro.

## A parte nova de verdade: estratégia de merge por coluna

A partir do Databricks Runtime 19, a opção `upsertkey` ganhou companhia: `upsert.mergeStrategies` permite declarar, coluna por coluna, como resolver conflito entre o valor já gravado e o valor que está chegando, sem precisar escrever SQL de `ON CONFLICT` manualmente.

```python
.option("upsertkey", "id")
.option(
    "upsert.mergeStrategies",
    "last_updated_at:greatest,creation_date:earliestNonNull,is_success:latestBy(last_updated_at)"
)
.option("upsert.defaultMergeStrategy", "latestBy(last_updated_at)")
```

As estratégias disponíveis são `latest` (padrão, mais recente por ordem de chegada), `earliest`, `latestNonNull`, `earliestNonNull`, `greatest` (maior valor entre o existente e o que chegou, valor nulo recebido nunca substitui o existente), `least` (o espelho de `greatest`), e as duas variantes que dependem de uma coluna de ordenação declarada à parte, `latestBy(coluna)` e `earliestBy(coluna)`, que só atualizam quando o valor de ordenação que chega é estritamente maior (ou menor) que o já gravado, com empate preservando o valor existente. Declarar `upsert.mergeStrategies` ou `upsert.defaultMergeStrategy` numa tabela sem chave primária é erro de configuração.

## Mão na massa: o exemplo de feature de recomendação em tempo real

O exemplo publicado usa um pipeline de feature de recomendação: origem Kafka, agrupamento por `user_id` via `transformWithState` pra manter os últimos seis vídeos assistidos e os últimos três curtidos por usuário, com upsert direto pro Lakebase pelo sink nativo. O benchmark rodou com dado sintético replicado pro Kafka, sustentando cerca de 20 mil eventos por segundo por 60 minutos, cobrindo 5 milhões de usuário ativo e 63,5 milhões de operação de upsert, num cluster clássico de 40 núcleos em Databricks Runtime 18 LTS, contra um projeto Lakebase de 8 CU, com checkpoint de Real-Time Mode a cada 5 minutos.

O resultado de latência ponta a ponta (do timestamp de entrada no Kafka até a linha aparecer gravada no Lakebase) ficou em P50 de 183 milissegundos e P99 de 354 milissegundos, com o lado do servidor Postgres medindo cerca de 0,015 milissegundo por instrução de upsert, em média, com folga de capacidade sobrando. A própria Databricks é clara que esse número depende de taxa de entrada, tamanho de estado, e dimensionamento de cluster e de Lakebase, não é uma garantia universal.

## O que isso não resolve

A documentação não declara explicitamente a garantia de entrega (exactly-once versus at-least-once) pro sink nativo, então não dá pra assumir uma ou outra sem confirmar isso num teste próprio antes de depender disso pra um caso de uso sensível a duplicata. O sink também não é suportado dentro de Declarative Pipelines (LakeFlow Declarative Pipelines), só em job de Structured Streaming direto, e no modo serverless só o gatilho `Trigger.AvailableNow` é suportado, não os gatilhos de tempo real ou intervalo de processamento contínuo.

**Minha ressalva:** a opção de conectar a um PostgreSQL externo via conexão do Unity Catalog é a peça que eu trataria com mais cautela agora, por ser Public Preview e exigir Databricks Runtime 19. É tentador usar isso como atalho pra escrever direto num banco relacional que já existe fora do Lakebase, mas eu validaria o comportamento de retry e backpressure contra o banco externo especificamente, porque as garantias documentadas (reconexão, controle de taxa) foram desenhadas pensando no Lakebase, não necessariamente em qualquer Postgres de terceiro com configuração própria de limite de conexão.

## Vale adotar?

Vale, principalmente pra quem já mantém um `ForeachWriter` customizado só pra fazer upsert num banco relacional a partir de streaming, porque o ganho aqui não é de performance bruta, é de deixar de manter código de infraestrutura que não agrega valor de negócio nenhum. A estratégia de merge configurável por coluna também resolve um problema real de lógica de negócio (qual versão do dado vence quando duas atualizações chegam fora de ordem) sem precisar de SQL customizado. Para quem ainda não tem Databricks Runtime 19, o `upsertkey` sozinho, sem estratégia de merge por coluna, já entrega a maior parte do ganho de deixar de escrever o writer à mão.

## Referências

- Databricks Blog, "Announcing General Availability of native Lakebase Postgres sink for Spark Structured Streaming": https://www.databricks.com/blog/announcing-general-availability-native-lakebase-postgres-sink-spark-structured-streaming
- Databricks Docs (AWS), "Write to Lakebase Postgres from Structured Streaming": https://docs.databricks.com/aws/en/structured-streaming/lakebase
- Microsoft Learn, "Write to Lakebase Postgres from Structured Streaming - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/structured-streaming/lakebase
- Databricks Blog, "How Lakebase architecture delivers 5x faster Postgres writes": https://www.databricks.com/blog/how-lakebase-architecture-delivers-5x-faster-postgres-writes

#AzureDatabricks #Lakebase #StructuredStreaming #Spark
