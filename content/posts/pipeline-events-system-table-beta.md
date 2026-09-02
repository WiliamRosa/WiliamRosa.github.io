---
title: "Uma system table só pra saber o que aconteceu dentro do seu pipeline Lakeflow"
date: 2026-09-01T09:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow", "Observabilidade", "Opinião"]
summary: "A pipeline_events system table (Beta) centraliza log de evento de todo pipeline Lakeflow da conta numa única tabela consultável, transição de estado, progresso de flow, métrica de qualidade e erro incluídos."
ShowToc: false
---

A Databricks colocou em Beta a system table pipeline_events, que reúne numa tabela só o log de evento de todo pipeline Lakeflow rodando na conta, em qualquer workspace da região.

O ponto central é sair da situação em que investigar falha de pipeline significa abrir a interface de um workspace por vez e caçar log espalhado. Com pipeline_events, transição de ciclo de vida do pipeline, progresso de cada flow, métrica de qualidade de dado e erro operacional passam a ser linha de uma tabela padrão, com o mesmo modelo de consulta SQL que já se usa pra qualquer outra system table de auditoria ou billing. Isso muda investigação de falha de "abrir tela e procurar" pra "escrever query e filtrar", e também abre a porta pra montar alerta automatizado em cima de padrão de falha recorrente, em vez de depender de alguém notar o problema primeiro.

O que dá pra fazer com isso na prática:
- Consultar histórico de atividade de pipeline de forma centralizada, cruzando múltiplos workspaces da mesma região numa query só
- Montar alerta próprio sobre falha de pipeline, correlacionando com outras system tables de Lakeflow em vez de depender só de notificação nativa
- Auditar comportamento de pipeline ao longo do tempo, útil pra time de dado que responde por SLA de ingestão

**Minha ressalva:** feature em Beta de system table costuma amadurecer bem, mas o valor real só aparece quando alguém efetivamente constrói o dashboard ou o alerta em cima dela, o dado sozinho parado numa tabela não muda nada operacionalmente. Vale tratar isso como convite pra revisar a estratégia de observabilidade de pipeline do zero, não só ligar o preview e seguir com o processo manual de sempre.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/admin/system-tables/pipeline-events

#Databricks #Lakeflow #Observabilidade
