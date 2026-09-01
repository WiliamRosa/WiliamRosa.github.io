---
title: "Testei três modelos atrás do mesmo Unity AI Gateway, e o custo de token variou cinco vezes pra pergunta idêntica"
date: 2026-07-02T09:00:00-03:00
draft: true
tags: ["Databricks", "UnityAIGateway", "FinOps", "Opinião"]
summary: "Um MVP apontou um Unity AI Gateway pra três modelos hospedados no Databricks e mediu guardrail bloqueando prompt injection 3 de 3 vezes, mas com uma diferença de até 5x no custo de token pro mesmo prompt entre modelos."
ShowToc: false
---

Unity AI Gateway promete governança unificada pra qualquer modelo, mas "unificado" não quer dizer "igual" na hora de pagar a conta.

O Databricks MVP Gary Nakanelua montou um experimento simples pra testar o que a unificação realmente remove: apontou uma única configuração de Unity AI Gateway pra três famílias de modelo hospedadas no Databricks (Claude Haiku, Llama 3.3 e GPT OSS), todas via Foundation Model APIs, pay-per-token, sem chave externa nenhuma.

O resultado técnico mais interessante não foi sobre funcionalidade, foi sobre custo escondido atrás da mesma barreira de segurança. A mesma configuração de guardrails bloqueou uma tentativa de prompt injection 3 de 3 vezes, antes mesmo de chegar em qualquer modelo, e o rastreamento de uso escreveu um ledger por modelo numa system table sem exigir nenhuma linha de código de log. Até aqui, unificação cumprindo a promessa. Mas o mesmo prompt, com as mesmas palavras, custou 21 tokens de entrada na Claude contra 115 tokens de entrada no GPT OSS, uma diferença de cinco vezes pro mesmo pedido.

Pontos que valem registrar do experimento:
- Guardrails aplicados uma vez cobriram os três modelos simultaneamente, sem configuração duplicada
- Bloqueio de prompt injection funcionou no lado de entrada, antes da chamada chegar em qualquer modelo externo
- Ledger de uso por token e por modelo foi gravado automaticamente numa system table
- Modelos pay-per-token compartilhados são endpoint de sistema compartilhado entre times, o que aponta pra necessidade de isolamento por time no futuro

**Minha ressalva:** governança unificada de acesso não é o mesmo que custo unificado, e esse experimento deixa isso bem claro. Se sua empresa está roteando tráfego pra múltiplos modelos achando que a diferença é só de qualidade de resposta, vale medir tokenização real por modelo antes de decidir qual usar por padrão, porque uma diferença de 5x em tokens de entrada muda a conta rapidamente em escala de produção.

**Fonte:** https://www.linkedin.com/in/gnakan/

#Databricks #UnityAIGateway #FinOps
