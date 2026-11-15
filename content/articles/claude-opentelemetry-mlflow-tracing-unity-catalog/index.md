---
title: "Quando o agente responde errado com confiança: rastreando a decisão do Claude dentro do Unity Catalog"
date: 2026-11-04T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "MLflow", "Unity Catalog", "IA Agêntica"]
ShowToc: true
summary: "Um agente pode devolver uma resposta plausível mesmo tendo lido a mesma fonte duas vezes ou ignorado um achado importante, e a resposta sozinha nunca explica o porquê. A Claude Platform agora exporta trace nativo via OpenTelemetry direto pro Unity Catalog, via Zerobus Ingest, o que dá ao MLflow visibilidade span a span sobre toda chamada de modelo e ferramenta, ainda em Beta Público e com limite real de ingestão que vale conhecer antes de depender disso em produção."
---

Um agente de IA pode retornar uma resposta plausível e, ainda assim, ter lido a mesma fonte duas vezes sem perceber, ou ignorado um achado relevante que estava bem na frente dele. A resposta final, sozinha, nunca explica o porquê. Pra investigar uma falha, comparar casos parecidos, ou testar se uma mudança de instrução realmente ajudou, é preciso ver a execução passo a passo: qual modelo foi chamado, em qual ordem, com qual ferramenta, e quanto tempo cada etapa levou.

Isso agora chegou em Beta Público: a Claude Platform exporta trace nativo via OpenTelemetry (OTel) direto pro MLflow do Azure Databricks, cobrindo SDKs da Anthropic, a Messages API e Claude Managed Agents, com o trace armazenado em tabela do Unity Catalog.

## O mecanismo: span exportado por OTLP, armazenado em tabela governada

MLflow Tracing é construído sobre OpenTelemetry. Um trace representa a execução inteira de um agente, dividida em spans, cada span correspondendo a uma chamada de modelo ou de ferramenta específica. A instrumentação nativa do Claude já gera esses spans e os exporta via OTLP (OpenTelemetry Protocol), o padrão aberto de telemetria.

O Azure Databricks recebe esses spans através do Zerobus Ingest (o mesmo mecanismo de ingestão serverless, orientado a push, que já expliquei aqui num contexto de replicação de banco de dados) e os grava em tabela do Unity Catalog vinculada a um experimento do MLflow. A combinação importa: Zerobus garante ingestão de baixa latência mesmo em alta taxa de requisição, e o Unity Catalog garante que o acesso ao dado sensível guardado dentro desses traces (que podem incluir prompt e resposta completos) seja governado como qualquer outra tabela corporativa.

{{< figure src="fluxo-otel-unity-catalog-mlflow.png" alt="Diagrama mostrando spans de trace nativo do Claude exportados via OpenTelemetry fluindo para o Unity Catalog e sendo lidos pelo MLflow do Azure Databricks" caption="Fluxo publicado pela Databricks: trace nativo do Claude flui via OpenTelemetry pro Unity Catalog, e o MLflow lê dali." >}}

## Mão na massa: criando o experimento com local de armazenamento no Unity Catalog

O primeiro passo real é criar um experimento do MLflow com o trace vinculado a uma tabela do Unity Catalog, em vez do armazenamento padrão do experimento (que tem limite de 100.000 traces e não escala pra produção). Isso exige MLflow 3.14 ou superior:

```bash
pip install "mlflow[databricks]>=3.14.0" --upgrade --force-reinstall
```

```python
import os
import mlflow
from mlflow.entities.trace_location import UnityCatalog

mlflow.set_tracking_uri("databricks")
os.environ["MLFLOW_TRACING_SQL_WAREHOUSE_ID"] = "<ID_DO_SQL_WAREHOUSE>"

experiment = mlflow.set_experiment(
    experiment_name="/Shared/agente-suporte-claude",
    trace_location=UnityCatalog(
        catalog_name="observabilidade",
        schema_name="agentes",
        table_prefix="suporte_claude",  # se omitido, usa o ID do experimento
    ),
)

print(f"Experiment ID: {experiment.experiment_id}")
print(experiment.trace_location.full_otel_spans_table_name)
```

Esse comando cria quatro tabelas no esquema informado: `<prefixo>_otel_spans`, `<prefixo>_otel_logs`, `<prefixo>_otel_metrics` e `<prefixo>_otel_annotations`. Um detalhe que vale conferir antes de rodar em produção: o esquema (`observabilidade.agentes`, no exemplo) precisa já existir antes da chamada, porque se não existir, o `create_experiment` cria o experimento mas falha a vinculação do local de trace, deixando um experimento órfão sem local de armazenamento definido. E depois de vinculado, o local de trace de um experimento não pode ser reatribuído, embora vários experimentos possam compartilhar o mesmo local.

A configuração da exportação nativa do lado do Claude usa variável de ambiente padrão OTel, apontando pro endpoint do Zerobus:

```bash
export OTEL_SERVICE_NAME="agente-suporte-claude"
export OTEL_EXPORTER_OTLP_PROTOCOL="http/protobuf"
export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="https://<workspace-id>.zerobus.<regiao>.azuredatabricks.net:443/v1/traces"
export OTEL_EXPORTER_OTLP_TRACES_HEADERS="authorization=Bearer ${TOKEN},x-databricks-zerobus-table-name=observabilidade.agentes.suporte_claude_otel_spans"
export OTEL_TRACES_EXPORTER="otlp"
```

E pra capturar entrada e saída completas (prompt e resposta, não só metadado), é preciso habilitar explicitamente o modo de conteúdo completo, porque o padrão é `metadata_only` por razão de segurança:

```python
import anthropic
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider

provider = TracerProvider()
trace.set_tracer_provider(provider)

client = anthropic.Anthropic(
    open_telemetry={
        "tracer_provider": provider,
        "traces": {"content_mode": "content"},
    }
)
```

**Minha leitura:** esse padrão de `metadata_only` por padrão, exigindo opt-in explícito pra capturar conteúdo completo, é a decisão de design certa, mesmo sendo um atrito extra na hora de debugar. Trace de agente acumula prompt e resposta de usuário real com o tempo, e tratar isso como sensível por padrão evita que alguém ligue rastreamento completo numa aplicação de produção sem pensar duas vezes sobre onde esse dado vai morar.

## Depois de conectado: o que o MLflow faz com o trace

Com o trace fluindo pra tabela do Unity Catalog, o MLflow abre um conjunto de ferramenta construída em cima dele. A ação "Analyze trace" chama o Genie Code pra examinar a execução e explicar o que deu errado, permitindo pergunta de acompanhamento sobre contexto faltante, chamada de ferramenta que falhou, ou etapa que custou caro. O MLflow Issues (também em Beta) usa o mesmo Genie Code pra encontrar problema recorrente entre vários traces, como busca repetida que desperdiça token ou argumento de ferramenta faltando, com detecção agendada e monitor de frequência ao longo do tempo. MLflow Review Queues traz especialista de domínio pra revisar trace manualmente, e o feedback dessa revisão se transforma em resposta de referência pra avaliação automática depois, via MLflow Agent Evaluation, que roda LLM como juiz pra comparar versão antiga e nova do agente lado a lado.

Pra contar token consumido por um agente especificamente, já que trace client-side e server-side podem gerar span duplicado pro mesmo evento, a consulta precisa filtrar por tipo de span:

```sql
SELECT
  sum(attributes:`gen_ai.usage.input_tokens`::bigint) AS tokens_entrada,
  sum(attributes:`gen_ai.usage.output_tokens`::bigint) AS tokens_saida
FROM observabilidade.agentes.suporte_claude_otel_spans
WHERE name = 'anthropic.messages.create'
  AND kind = 'SPAN_KIND_CLIENT';
```

## O que isso não resolve

O limite mais concreto, documentado de forma explícita, é de ingestão: 200 traces por segundo por workspace e 100 MB por segundo por tabela, inicialmente, com a recomendação de contatar a conta Databricks se precisar de mais. Pra um agente de alto volume em produção, isso é um teto real que vale medir antes de assumir que vai aguentar o tráfego de pico sem fila.

Existem também lacunas específicas de operação: não é possível excluir trace individual de uma tabela do Unity Catalog diretamente pela interface (só via `DELETE` SQL direto na tabela, diferente do armazenamento padrão de experimento, que aceita exclusão via UI/API), trace maior que 25 MB não fica acessível pela interface do MLflow nem pelo SDK Python (só consultando a tabela via SQL), e o recurso ainda não funciona com Knowledge Assistant nem Supervisor Agent do Agent Bricks.

**Minha ressalva:** existe um segundo mecanismo do Azure Databricks, também anunciado na mesma semana, chamado Unified Trace Table, do AI Gateway, que captura todo o tráfego do Unity Gateway (qualquer endpoint de modelo ou MCP), não só o trace vinculado a um experimento específico do MLflow. São dois destinos Beta paralelos, ambos acabando no Unity Catalog via Zerobus, mas servindo propósito ligeiramente diferente, o da experimentação versus o de observabilidade de gateway inteiro. Antes de escolher onde investir configuração, vale decidir qual das duas perguntas você está tentando responder, "como esse agente específico se comportou nesse experimento" ou "o que está passando pelo meu gateway de modelo inteiro".

## Vale adotar?

Sim, pra quem já usa Claude em agente de produção e sente a dor específica de "a resposta parece errada, mas não sei em qual etapa", especialmente combinado com Analyze Trace e Issue Detection, que automatizam parte da investigação que hoje provavelmente é manual. Por ser Beta Público em todas as peças (export nativo do Claude, armazenamento no Unity Catalog, Issues), eu validaria o limite de ingestão contra o volume real da sua aplicação antes de tratar isso como a fonte única de observabilidade em produção, e manteria o modo de conteúdo completo desligado por padrão até decidir deliberadamente onde esse dado sensível vai ficar.

## Referências

- Databricks Blog, "Claude Platform now supports native OpenTelemetry observability in Databricks MLflow": https://www.databricks.com/blog/claude-platform-now-supports-native-opentelemetry-observability-databricks-mlflow
- Databricks Docs (AWS), "Store OpenTelemetry traces in Unity Catalog": https://docs.databricks.com/aws/en/mlflow3/genai/tracing/trace-unity-catalog
- Microsoft Learn, "Store OpenTelemetry traces in Unity Catalog - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/mlflow3/genai/tracing/trace-unity-catalog
- Microsoft Learn, "Configure OpenTelemetry clients to send data to Unity Catalog - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/ingestion/opentelemetry/configure
- Claude Platform Docs, "OpenTelemetry tracing": https://platform.claude.com/docs/en/manage-claude/opentelemetry

#AzureDatabricks #MLflow #UnityCatalog #IAAgentica
