---
title: "Micro-batch atrasado não precisa mais travar a fila inteira no Lakeflow serverless"
date: 2026-08-26T09:00:00-03:00
draft: true
tags: ["Databricks", "Lakeflow", "SparkStreaming", "Opinião"]
summary: "Stream Pipelining permite múltiplos micro-batches em voo ao mesmo tempo em pipelines declarativos serverless, em vez de esperar cada um terminar antes do próximo começar."
ShowToc: false
---

Uma pergunta simples de cliente virou um artigo técnico sobre um detalhe que muda latência de pipeline streaming sensível.

O Databricks MVP Mani Kandasamy destacou o trabalho do arquiteto de soluções Sreekanth Munigati, que explicou o que acontece quando um micro-batch demora mais que o intervalo de gatilho configurado num Lakeflow Spark Declarative Pipeline serverless. A resposta virou a explicação de uma otimização chamada Stream Pipelining: em queries de streaming elegíveis, múltiplos micro-batches podem ficar em voo ao mesmo tempo, em vez de sempre esperar um terminar completamente antes do próximo começar.

Na prática, isso ataca um gargalo clássico de Spark Structured Streaming: sem pipelining, um micro-batch lento vira um funil que atrasa tudo depois dele, mesmo que o motor tivesse capacidade sobrando pra já começar a processar o próximo. Com múltiplos micro-batches em voo, o motor aproveita melhor a capacidade disponível em vez de ficar ocioso esperando uma etapa terminar.

Pontos técnicos que valem registrar:
- A otimização se aplica a queries de streaming elegíveis dentro de Lakeflow Spark Declarative Pipelines serverless
- Resolve especificamente o cenário em que o processamento de um micro-batch ultrapassa o intervalo de gatilho configurado
- É uma otimização de execução, não uma mudança de API, o comportamento muda sem exigir reescrever a lógica do pipeline

**Minhas considerações:** esse é o tipo de detalhe que só aparece quando alguém debuga um problema real de latência em produção, não em documentação de lançamento de feature. Vale a pena acompanhar esse tipo de conteúdo técnico vindo direto de quem trabalha com cliente, porque frequentemente é onde aparece o "porquê" por trás de um comportamento que a documentação oficial só descreve por cima.

**Fonte:** https://community.databricks.com/t5/technical-blog/triggered-vs-continuous-mode-a-deep-dive-into-serverless/ba-p/164327

#Databricks #Lakeflow #SparkStreaming
