---
title: "Lakeflow Jobs basta como orquestrador, ou você ainda precisa de Airflow?"
date: 2026-09-25T09:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow Jobs", "Apache Airflow", "Data Engineering", "Arquitetura"]
summary: "Lakeflow Jobs resolve orquestração sozinho quando a operação vive inteira dentro do Azure Databricks, mas perde força em branching complexo, infraestrutura fora da plataforma e recuperação automática de execução perdida, cenários em que Apache Airflow ainda vale a pena."
ShowToc: false
---

Trocar Airflow por Lakeflow Jobs parece decisão óbvia até esbarrar num cenário que o orquestrador nativo não cobre bem.

O Databricks MVP Bartosz Konieczny encarou de frente uma pergunta que todo time que roda pipeline no Azure Databricks acaba fazendo: dá para abandonar um orquestrador externo e usar só o Lakeflow Jobs, ou isso é simplificação demais? A resposta que ele chega não é sim nem não, é "depende de onde termina o seu Databricks".

Quando a operação inteira, ingestão, transformação, disponibilização, roda dentro da plataforma, Lakeflow Jobs entrega orquestração totalmente gerenciada: nada de provisionar scheduler separado nem manter infraestrutura de orquestração como código à parte, tudo fica no mesmo lugar, com lineage, métrica de saúde do job e monitoramento de qualidade de dado já embutidos, sem lógica extra de sincronização entre dois sistemas. O problema aparece quando a arquitetura extrapola essa fronteira ou quando a lógica de controle de fluxo fica complexa demais para o modelo de tarefas do Lakeflow.

Pontos técnicos que valem registrar:
- Branching condicional complexo, com múltiplos caminhos dependendo de sucesso ou falha, fica difícil de expressar de forma limpa em Lakeflow Jobs
- Job rodando fora do Databricks, como AWS Batch ou Azure Functions, cai fora do alcance nativo do orquestrador
- Lakeflow Jobs não faz catchup automático: um job pausado não reprocessa sozinho o intervalo perdido, diferente de orquestrador com estado como Airflow
- A API em Python existe, mas ainda é menos madura que a interface declarativa e imperativa de um orquestrador dedicado

**Minha ressalva:** a tentação de eliminar Airflow inteiro assim que o grosso da stack migra pro Databricks é real, mas os quatro pontos acima não são detalhe raro, são justamente os casos que aparecem quando o pipeline cresce e passa a depender de sistema externo ou de lógica de retomada mais sofisticada. Antes de migrar de vez, vale mapear se algum desses quatro cenários já existe ou está no roadmap próximo, porque desfazer essa decisão depois custa bem mais caro do que rodar os dois orquestradores lado a lado por um tempo.

**Fonte:** https://www.waitingforcode.com/databricks/lakeflow-jobs-default-data-orchestration-setup/read

#Databricks #LakeflowJobs #DataEngineering
