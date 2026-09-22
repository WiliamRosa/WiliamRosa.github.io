---
title: "A tabela de histórico de consulta do Unity Catalog saiu do beta"
date: 2026-09-22T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Observability", "Azure Databricks"]
summary: "O system.query.history chegou à disponibilidade geral: uma system table única, em nível de conta, com todo o histórico de consulta rodado em SQL warehouse ou compute serverless, incluindo status de execução, duração e origem da consulta."
ShowToc: false
---

Quem já caçou uma query lenta espalhada entre workspace diferente sabe o quanto essa tabela faltava.

O Azure Databricks confirmou a disponibilidade geral da system table system.query.history, que centraliza em nível de conta o registro de toda consulta rodada em SQL warehouse ou compute serverless. Antes esse tipo de dado ficava espalhado entre a UI de histórico de consulta de cada workspace, sem um jeito direto de consultar via SQL e cruzar com o resto das system tables de billing e auditoria.

Ter isso como tabela consultável muda o tipo de pergunta que dá pra responder sem exportar nada nem abrir uma UI por workspace. Em vez de investigar workspace por workspace, dá pra rodar uma única consulta que cruza execução de query com o restante do sistema de observabilidade que a Databricks já vem consolidando nas system tables ao longo do ano.

Pontos técnicos que valem atenção:
- Cobre execução em SQL warehouse e em compute serverless, num único lugar em nível de conta
- Traz status de execução, métrica de duração e origem da consulta, de onde ela partiu
- Dá pra cruzar com outras system table de billing, job e auditoria pra montar dashboard de FinOps ou de performance
- Faz parte da mesma leva de lançamentos que trouxe retenção configurável entre 30 e 3.650 dias pras system tables suportadas

**Minhas considerações:** é uma peça pequena, mas fecha uma lacuna real de quem administra conta com muitos workspaces. O padrão continua o mesmo que vem se repetindo esse ano: cada vez menos motivo pra manter view própria só pra agregar dado que já devia estar centralizado de fábrica.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/admin/system-tables/query-history

#Databricks #UnityCatalog #Observability
