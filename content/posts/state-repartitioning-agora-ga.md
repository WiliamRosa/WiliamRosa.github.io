---
title: "O repartition sob demanda que era Public Preview virou GA, e dois Databricks MVPs bateram nisso no mesmo dia"
date: 2026-10-14T20:00:00-03:00
draft: true
tags: ["Databricks", "Azure Databricks", "Structured Streaming", "Apache Spark"]
summary: "On-demand state repartitioning, que já cobrimos aqui como Public Preview, chegou à disponibilidade geral: redimensionar partição de shuffle de uma query stateful ou pipeline do Lakeflow sem perder o estado do checkpoint, e agora os Databricks MVPs Hubert Dudek e Derar Alhussein confirmaram, cada um por conta própria, que o recurso está liberado pra uso geral."
ShowToc: false
---

Já escrevemos aqui sobre o repartition sob demanda enquanto Public Preview; a novidade agora é só uma palavra, mas que muda tudo pra quem estava esperando antes de colocar em produção: GA.

Os Databricks MVPs Hubert Dudek e Derar Alhussein documentaram, cada um de forma independente e no mesmo dia, que o on-demand state repartitioning saiu de Public Preview pra disponibilidade geral. O mecanismo em si não mudou desde a cobertura anterior: ainda é possível redimensionar o número de partição de shuffle de uma query stateful do Structured Streaming, ou de uma pipeline do Lakeflow, sem precisar reconstruir o checkpoint do zero e sem perder o estado já acumulado.

Pontos técnicos que valem registrar:
- O status mudou de Public Preview pra disponibilidade geral (GA)
- O mecanismo central continua o mesmo: ajustar `spark.sql.streaming.stateStore.partitions` com o checkpoint intacto
- Agora também é suportado dentro de pipeline do Lakeflow, não só em query standalone de Structured Streaming
- Dois Databricks MVPs cobriram o mesmo anúncio de forma independente no mesmo dia, sinal de que a mudança de status pegou a comunidade de olho no recurso

**Minhas considerações:** GA costuma ser o sinal que faltava pra quem gostou do mecanismo em Preview mas segurou a adoção em produção esperando estabilidade de SLA e suporte oficial. Se sua equipe já tinha mapeado qual query stateful antiga nunca teve o número de partição revisado, como sugeri na cobertura anterior, agora é a hora de tirar isso do radar de "teste quando puder" pra "aplicar com prioridade".

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/structured-streaming/state-repartitioning

#Databricks #AzureDatabricks #StructuredStreaming
