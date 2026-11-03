---
title: "Toda chamada de ferramenta MCP agora pode passar por um filtro de jailbreak"
date: 2026-10-22T09:00:00-03:00
draft: true
tags: ["Unity Gateway", "Seguranca", "Agentes de IA", "Azure Databricks"]
summary: "O Azure Databricks passou a permitir aplicar um guardrail de jailbreak sobre chamada de ferramenta MCP dentro do Unity Gateway, cobrindo tanto o pedido que o agente envia quanto a resposta que volta da ferramenta."
ShowToc: false
---

Toda chamada de ferramenta MCP agora pode passar por um filtro de jailbreak antes de executar.

O Azure Databricks passou a permitir a aplicação de um guardrail de jailbreak sobre chamada de ferramenta MCP dentro do Unity Gateway, cobrindo tanto o pedido que o agente envia pra ferramenta quanto a resposta que volta dela.

A tentativa de jailbreak via ferramenta MCP é um vetor diferente do jailbreak clássico direto num prompt de chat: o ataque chega embutido no retorno de uma ferramenta externa, por exemplo um texto malicioso escondido dentro do conteúdo de uma página que o agente buscou, esperando que o agente trate esse conteúdo como instrução legítima. Aplicar o guardrail no nível do Unity Gateway, em vez de depender só do próprio modelo resistir à injeção, significa que a barreira roda de forma consistente pra qualquer agente ou harness conectado àquele servidor MCP, sem depender da implementação de cada cliente.

Pontos técnicos que valem atenção:
- Guardrail configurável em entrada, saída ou nos dois sentidos, por servidor MCP registrado no Unity Gateway
- Aplicado através de uma Service Policy, o mesmo mecanismo já usado pra outros tipos de controle de governança sobre tráfego de modelo e ferramenta
- Recurso em Beta, atribuído a uma política que o admin anexa ao servidor MCP

**Minha ressalva:** um guardrail de jailbreak reduz risco, mas não é garantia; continua valendo a prática de nunca dar a um agente permissão maior do que a tarefa exige, o guardrail é uma camada extra, não substituto do princípio de menor privilégio no desenho da permissão do agente.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/service-policies/create-service-policy#use-a-built-in-policy

#UnityGateway #Seguranca #AgentesDeIA
