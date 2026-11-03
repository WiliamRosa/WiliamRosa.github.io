---
title: "Unity Gateway ganhou um dashboard pronto pra responder quem está gastando o quê"
date: 2026-10-28T11:00:00-03:00
draft: true
tags: ["Unity Gateway", "Azure Databricks", "FinOps"]
summary: "O Databricks MVP Derar Alhussein destacou o Unity Gateway Usage Dashboard v1.0, painel pronto que consolida adoção de coding agent, uso de harness, gasto estimado por sessão e atribuição de custo por tag sobre a system table de uso do gateway."
ShowToc: false
---

O Unity Gateway ganhou um dashboard pronto pra responder quem está gastando o quê com agente de código.

O Databricks MVP Derar Alhussein destacou a chegada do Unity Gateway Usage Dashboard v1.0, um painel pronto pra uso que consolida adoção de coding agent, uso de harness, gasto estimado por sessão e atribuição de custo por tag, tudo sobre a mesma system table que já alimentava consulta manual via SQL.

O dashboard é gerado a partir da system.ai_gateway.usage, já existente, mas em vez de exigir que cada time escreva sua própria consulta, a Databricks publicou um template com abas prontas: Overview, Spend, Coding Agents, MCPs, Skills e Performance. A aba de Coding Agents em particular permite comparar adoção por agente, sessão por harness e ranquear sessão individual por gasto estimado, enquanto a aba Spend atribui custo por tag de serviço ou de requisição, a mesma tag que já existia pro orçamento do Unity Gateway.

Pontos técnicos que valem atenção:
- Account admin cria o dashboard via Govern e Create Usage Dashboard, escolhendo escopo de conta ou de workspace
- Aba Coding Agents mostra adoção por agente, uso de harness, sessão e subagente, com ranking de sessão por gasto estimado
- Aba Spend atribui custo por tag de serviço e de requisição, além de comparar consumo de token com e sem cache
- Atualização de dado agendada roda a cada seis horas, com opção de atualização automática quando um template novo é publicado
- Atualizar o dashboard sobrescreve customização feita na cópia anterior; recomenda-se salvar cópia antes de atualizar

**Minhas considerações:** dar um dashboard pronto em vez de deixar cada time reinventar a própria consulta sobre a mesma system table é o tipo de polimento que só aparece depois que o recurso já tem adoção suficiente pra justificar o investimento. O detalhe que mais acho prático aqui é separar o gasto por tag de requisição, não só por serviço, isso é o que realmente permite cobrar centro de custo de verdade.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/ai-gateway/usage-tracking#built-in-usage-dashboard

#UnityGateway #AzureDatabricks #FinOps
