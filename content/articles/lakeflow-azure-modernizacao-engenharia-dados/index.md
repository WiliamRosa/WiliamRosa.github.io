---
title: "Lakeflow no Azure Databricks: quando ingestão, transformação e orquestração param de ser três produtos separados"
date: 2026-02-11T09:00:00-03:00
draft: true
tags: ["Databricks", "Lakeflow", "Azure Databricks", "Engenharia de Dados", "Unity Catalog"]
summary: "Lakeflow consolida Connect, Spark Declarative Pipelines e Jobs numa única superfície de engenharia de dados dentro do Azure Databricks, substituindo a combinação típica de ferramenta de ingestão, orquestrador externo e scripts de transformação por um único plano de controle governado pelo Unity Catalog."
ShowToc: true
---

Quem já montou uma stack de engenharia de dados do zero conhece o padrão: uma ferramenta de ingestão pra puxar dado de CRM e ERP, um orquestrador separado pra costurar as dependências entre jobs, notebooks ou scripts fazendo a transformação propriamente dita, e um quarto sistema só pra monitorar se tudo isso rodou certo ontem à noite. Cada peça vem de um fornecedor diferente, com autenticação própria, log próprio e SLA próprio. Quando algo quebra às três da manhã, o primeiro trabalho não é corrigir o problema, é descobrir em qual das quatro ferramentas ele está.

O Lakeflow ataca essa fragmentação de um jeito direto: junta ingestão, transformação e orquestração numa única superfície dentro do Azure Databricks, com Unity Catalog fazendo a governança de ponta a ponta. Não é reempacotamento de marketing de três produtos que já existiam separadamente, é a promessa de que dependência entre ingestão e transformação, lineage de coluna e controle de acesso deixam de ser reconciliados manualmente entre sistemas e passam a existir nativamente no mesmo grafo.

## As três peças que formam o Lakeflow

**Lakeflow Connect** cobre a ingestão, com conectores ponto e clique pra aplicação SaaS (Salesforce, Workday, ServiceNow), banco de dados (SQL Server) e mensageria, além do Zerobus Ingest, uma API serverless de escrita direta pra quem tem evento chegando de aplicação própria sem precisar montar um message bus no meio do caminho.

**Spark Declarative Pipelines** é a camada de transformação: em vez de escrever a orquestração de streaming table e materialized view manualmente, você declara a tabela de destino e a lógica de negócio, e o motor infere o grafo de dependência sozinho, monta o DAG, e cuida de detalhe operacional como backfill e versionamento. O nome interno mudou ao longo do tempo (quem acompanha a plataforma há mais tempo vai reconhecer isso como evolução direta do que era Delta Live Tables), mas o mecanismo de fundo, declarar o resultado desejado em vez do passo a passo procedural, continua sendo a ideia central.

**Lakeflow Jobs** orquestra tudo isso como um DAG unificado: workload SQL, código Python, pipeline declarativo, dashboard e sistema externo convivem na mesma definição de job, com gatilho orientado a dado (tabela atualizada, arquivo chegou num volume), tarefa de controle de fluxo, e execução de backfill sem código.

## Mão na massa: um pipeline simples de ponta a ponta

Pra dar concretude, um exemplo de como as três peças se encaixam num pipeline básico de ingestão e transformação declarada:

```python
import dlt
from pyspark.sql.functions import col

# Streaming table: ingestão incremental via Auto Loader
@dlt.table(
    comment="Ingestão bruta de pedidos via Auto Loader"
)
def pedidos_bronze():
    return (
        spark.readStream.format("cloudFiles")
        .option("cloudFiles.format", "json")
        .load("/Volumes/vendas/bronze/pedidos_raw")
    )

# Materialized view: validação e enriquecimento
@dlt.table(
    comment="Pedidos validados, com filtro de qualidade"
)
@dlt.expect_or_drop("valor_positivo", "valor_total > 0")
def pedidos_silver():
    return (
        dlt.read_stream("pedidos_bronze")
        .withColumn("valor_total", col("valor_total").cast("decimal(10,2)"))
        .filter(col("cliente_id").isNotNull())
    )
```

Esse trecho não roda sozinho, ele vira uma tarefa dentro de um Lakeflow Job que também pode disparar um dashboard de AI/BI assim que a tabela `pedidos_silver` for atualizada, usando gatilho orientado a dado em vez de agendamento por horário fixo. É essa amarração entre ingestão, transformação e o próximo passo do fluxo, tudo no mesmo lugar, que elimina boa parte do trabalho de cola que hoje vive em Airflow ou Azure Data Factory separado.

## Governança sem reconciliação manual

O ponto que costuma passar despercebido em quem só olha a superfície de produto é o que acontece por baixo com o Unity Catalog. Como ingestão, transformação e orquestração compartilham o mesmo catálogo, a linhagem de dado é capturada de ponta a ponta automaticamente, desde a tabela de origem no SQL Server até o dashboard final, sem depender de anotação manual ou de um sistema de linhagem terceiro tentando inferir relação a partir de log.

**Minha leitura:** essa unificação de governança é, na minha visão, o argumento mais forte do Lakeflow, mais forte até que a conveniência de ter um conector pronto pra Workday. Eu já vi mais de um projeto de engenharia de dados falhar auditoria não porque o pipeline estava errado, mas porque ninguém conseguia provar com confiança de onde um número específico tinha vindo, com quantas transformações no meio. Ter isso garantido estruturalmente, e não como processo manual de documentação que sempre fica desatualizado, muda o tipo de conversa que se tem com o time de compliance.

System Tables entram como a peça de observabilidade: em vez de montar um dashboard próprio de monitoramento consultando API de cada ferramenta separada, dá pra construir alerta e relatório de saúde direto em cima de tabela SQL nativa, com retenção e schema padronizados pela própria Databricks.

## Custo: onde a promessa exige verificação própria

A Databricks divulga número de redução de custo bem expressivo, incluindo caso de até 83% de redução em custo de ETL e melhoria de performance de até 90 vezes reportada por cliente específico. Vale tratar esse tipo de número com o ceticismo padrão que qualquer benchmark de fornecedor merece: geralmente reflete uma migração específica, de uma stack mal otimizada, pra uma configuração nova bem ajustada. **Na prática**, eu testaria a economia real comparando o mesmo workload representativo do seu ambiente rodando old vs. new, com cluster policy e modo de compute (Performance vs. Standard no compute serverless) equivalentes, antes de usar o número de marketing numa justificativa de orçamento pra liderança.

O mecanismo que sustenta a economia é real e faz sentido tecnicamente: compute serverless com otimização automática elimina cold start entre tarefa sequencial do mesmo job, e resource control granular por tarefa evita superalocar cluster pra etapa leve do pipeline. Isso é diferente de garantir que qualquer migração vai bater 83% de redução.

## O que isso não resolve

Consolidar ingestão, transformação e orquestração numa plataforma não elimina a necessidade de modelagem de dado bem pensada, nem substitui decisão de arquitetura sobre particionamento e clustering de tabela grande. Também não resolve, por si só, o problema de time que já tem investimento pesado em Airflow com plugin customizado difícil de portar, a migração de orquestração legada continua sendo trabalho manual de reescrita, mesmo com a tarefa dbt e integrações de terceiro facilitando parte do caminho. E o conector ponto e clique do Lakeflow Connect cobre um conjunto específico de fonte, sistema legado ou API proprietária sem conector nativo ainda dependem de ingestão customizada via Auto Loader ou API própria.

## Fechamento

Lakeflow não inventa um paradigma novo de engenharia de dados, ele remove a fricção de coordenar três ferramentas diferentes pra fazer o que sempre foi conceitualmente uma coisa só: trazer dado de fora pra dentro, transformá-lo com confiança, e entregar no formato certo pro próximo consumidor. Pra quem está no Azure Databricks e já sente a dor de manter Data Factory, um orquestrador de terceiro e um catálogo de linhagem separado, vale o piloto num pipeline real antes de prometer o número de redução de custo da Databricks pra ninguém.

## Referências

- Databricks Blog, "Modernize your Data Engineering Platform with Lakeflow on Azure Databricks": https://www.databricks.com/blog/modernize-your-data-engineering-platform-lakeflow-azure-databricks
- Databricks Docs, "Get started: Build an ETL pipeline": https://docs.databricks.com/aws/en/getting-started/data-pipeline-get-started
- Microsoft Learn, "Tutorial: Build an ETL pipeline with Lakeflow pipelines - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/getting-started/data-pipeline-get-started
- Microsoft Learn, "System tables": https://learn.microsoft.com/en-us/azure/databricks/admin/system-tables/

#Databricks #Lakeflow #EngenhariaDeDados #AzureDatabricks
