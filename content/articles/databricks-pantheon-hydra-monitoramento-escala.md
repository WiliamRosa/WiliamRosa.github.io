---
title: "5 bilhões de séries temporais, um motor só não basta: como a Databricks separou alerta rápido de investigação profunda"
date: 2026-05-06T09:00:00-03:00
draft: true
tags: ["Databricks", "Observabilidade", "Auto Loader", "Structured Streaming", "Delta Lake"]
summary: "A própria Databricks conta como escalou monitoramento interno para 10 trilhões de amostras por dia e 5 bilhões de séries temporais ativas combinando um fork do Thanos para alerta rápido, uma camada de agregação que absorve pico de cardinalidade, e uma plataforma baseada em lakehouse para investigação profunda sobre dado bruto."
ShowToc: true
---

Todo time que já operou observabilidade em escala grande conhece o sintoma: o Prometheus ou o Thanos aguentam bem até um certo volume, e depois de um certo ponto de explosão de cardinalidade, geralmente workload serverless gerando métrica nova a cada execução, a solução vira "jogar mais shard em cima" até o sistema inteiro ficar frágil demais pra mexer sem medo. A Databricks bateu nesse teto internamente, com 5 bilhões de série temporal ativa e 10 trilhões de amostra por dia espalhada por setenta região de nuvem, e a solução que documentaram não foi um Thanos maior, foi aceitar que alerta em tempo real e investigação profunda são dois problemas diferentes, que merecem dois sistemas diferentes conversando entre si.

## Pantheon: um fork do Thanos que troca hash ring único por isolamento

A camada de série temporal, batizada de Pantheon, é um fork customizado do Thanos de código aberto, com armazenamento em camada: dado recente fica em memória pra consulta rápida, as últimas 24 horas ficam em disco, e o histórico vai pra object storage. A escolha de design mais interessante não é a camada em si, é como a Databricks separou o receive path. Em vez de um hash ring único recebendo tudo, existem grupos de Receive isolados com política de retenção diferente, duas horas pra workload persistente, trinta minutos pra workload efêmero, cada um rodando em StatefulSet de Kubernetes separado. Isso significa que um problema de capacidade ou de release numa fatia efêmera de altíssima cardinalidade não arrasta o resto do sistema junto.

Multitenancy é baseada em regra, com atribuição automática de tenant, e o upload pro object storage acontece com garantia de "pelo menos uma vez" a partir de duas de três réplicas, reduzindo redundância de gravação sem abrir mão de durabilidade. Um conjunto de controlador cuida da operação contínua: um Rollout Operator coordena release seguro, um Hashring Controller garante que só pod saudável apareça no roteamento, e um controlador de autoscaling e auto cura faz remediação contínua sem depender de intervenção manual. O resultado documentado é 160 instância de Thanos rodando em três nuvem, aguentando cerca de 5 bilhões de série temporal em memória e cerca de mil consulta PromQL por segundo na maior instância, com queda de aproximadamente cinco vezes no tempo de indisponibilidade da infraestrutura de monitoramento.

## A camada que absorve o pico antes que ele chegue no Pantheon

Nenhum TSDB, por melhor que seja o design, aguenta explosão de cardinalidade sem alguma forma de contenção antes da porta de entrada. Pra isso existe uma camada de agregação construída sobre Telegraf com otimização própria, e um serviço interno chamado Dicer, um "auto-sharder" que faz roteamento sticky inteligente. Milhares de regra de agregação processam cerca de 1 GB por segundo na maior região, reduzindo o volume que efetivamente chega no Pantheon.

O teste real dessa camada não foi sintético: durante um incidente com pico de métrica entre duas e cinco vezes o volume normal, a camada de agregação absorveu a maior parte do choque, e o Pantheon viu um aumento de só 20% de carga, em vez do pico bruto de duas a cinco vezes que chegou na borda. Isso é o tipo de resultado que só aparece quando o sistema é desenhado pra degradar graciosamente sob estresse real, não só pra performar bem no dia calmo.

## Hydra: quando o problema deixa de ser alertar rápido e vira investigar fundo

Pantheon e a camada de agregação resolvem bem o problema de alerta e consulta operacional recente, mas depois de um incidente alguém sempre precisa fazer pergunta que a agregação já apagou a resposta: qual série específica, com qual combinação exata de label, começou a se comportar diferente, e desde quando. Pra isso a Databricks construiu o Hydra, uma plataforma de troubleshooting baseada em lakehouse, não em TSDB.

Hydra ingere métrica bruta e não agregada usando Apache Spark Structured Streaming e Auto Loader, com Delta Lake como camada de armazenamento, implantado por região com autoscaling independente. O volume é de 20 bilhões de série temporal ativa não agregada, com frescor de ponta a ponta de cinco minutos, e um custo de armazenamento cerca de 50 vezes menor que manter o mesmo volume bruto no Thanos. Pra não obrigar todo mundo a aprender SQL de lakehouse do zero, existe uma camada de tradução de PromQL pra SQL, mantendo compatibilidade com Grafana pra quem já vive nesse ecossistema, além de acesso direto via SQL ou notebook pra análise mais profunda, incluindo join com outro dado da empresa sob a mesma governança do Unity Catalog.

## Mão na massa: um esqueleto de ingestão de métrica bruta com Auto Loader

O padrão que sustenta o Hydra, streaming contínuo de arquivo bruto direto pra Delta, é genérico o suficiente pra reproduzir em qualquer pipeline de telemetria de alto volume. Um esqueleto simplificado, usando Auto Loader com o source `cloudFiles`:

```python
from pyspark.sql.functions import col, from_json
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, TimestampType

metric_schema = StructType([
    StructField("metric_name", StringType()),
    StructField("labels", StringType()),
    StructField("value", DoubleType()),
    StructField("timestamp", TimestampType()),
])

raw_metrics = (
    spark.readStream.format("cloudFiles")
    .option("cloudFiles.format", "json")
    .option("cloudFiles.schemaLocation", "/Volumes/observability/bronze/_schema/metrics")
    .schema(metric_schema)
    .load("/Volumes/observability/landing/metrics")
)

query = (
    raw_metrics
    .withColumn("labels_parsed", from_json(col("labels"), "map<string,string>"))
    .writeStream
    .option("checkpointLocation", "/Volumes/observability/bronze/_checkpoint/metrics")
    .trigger(processingTime="30 seconds")
    .toTable("observability.bronze.raw_metrics")
)
```

O ganho estrutural do Auto Loader aqui não é só a sintaxe simples. O checkpoint garante processamento exatamente uma vez sem gerenciar estado manualmente, o custo de descoberta de arquivo escala com o número de arquivo, não com o número de diretório, e schema drift em campo novo de métrica é detectado e evolui sem quebrar o pipeline em produção. Pra um volume real de telemetria, a Databricks recomenda modo de notificação de arquivo em vez de listagem de diretório, justamente pra reduzir custo de nuvem em ingestão contínua de alto volume.

**Minha leitura:** vale reproduzir esse padrão de três camadas, caminho rápido, agregação que absorve pico, lakehouse pra investigação funda, proporcional ao problema real, não como receita fixa. A maioria das empresas não tem 5 bilhões de série temporal nem precisa de três sistemas separados. Mas a lição de fundo, separar o que precisa responder em segundo do que precisa responder com detalhe em minuto, se aplica em qualquer escala onde monitoramento e mock de dashboard bonito param de ser a mesma coisa.

## O que essa arquitetura não resolve sozinha

Nenhuma dessas três camadas elimina a necessidade de alguém decidir, com julgamento humano, o que vale a pena pré-agregar e o que precisa continuar bruto. A camada Telegraf/Dicer só absorve pico se a regra de agregação já existir antes do incidente acontecer, ela não infere sozinha qual métrica vai explodir amanhã. E o frescor de cinco minutos do Hydra, mesmo sendo impressionante pra volume de dado bruto, não serve pra alerta crítico de paging, esse continua sendo trabalho do Pantheon com SPOT rodando em cima de janela recente. Trocar as duas coisas de lugar, tentando usar Hydra como caminho de alerta em tempo real ou o Pantheon como ferramenta de investigação histórica funda, quebra a proposta de cada peça.

## Resumindo

O que a Databricks documentou aqui não é um produto que qualquer empresa compra amanhã, é um estudo de caso de engenharia interna resolvendo um problema de escala real com peça que já existe no próprio ecossistema Databricks, Structured Streaming, Auto Loader e Delta Lake reaproveitados pra um domínio, observabilidade, que normalmente vive fora do lakehouse. Vale menos como manual de cópia exata, e mais como argumento de que separar caminho rápido de caminho de investigação funda é uma decisão de arquitetura, não um upgrade de hardware.

## Referências

- Databricks Blog, "10 trillion samples a day: Scaling beyond traditional monitoring infra at Databricks": https://www.databricks.com/blog/10-trillion-samples-day-scaling-beyond-traditional-monitoring-infra-databricks
- Microsoft Learn, "What is Auto Loader? - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/ingestion/cloud-object-storage/auto-loader/
- Databricks Docs, "What is Auto Loader?": https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/
- Thanos, projeto de código aberto: https://thanos.io/

#Databricks #Observabilidade #StructuredStreaming #DeltaLake
