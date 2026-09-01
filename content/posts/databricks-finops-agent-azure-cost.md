---
title: "Um agente que responde 'quanto vai custar isso' antes de você rodar em produção"
date: 2026-08-02T09:00:00-03:00
draft: true
tags: ["Databricks", "FinOps", "Azure", "Agentes de IA", "Opinião"]
summary: "O Databricks MVP Casper Lubbers construiu um agente de FinOps focado em avaliação de custo Azure + Databricks, do tipo de pergunta que hoje normalmente só se responde depois do fato, olhando a fatura."
ShowToc: false
---

O Databricks MVP Casper Lubbers construiu um agente de FinOps voltado especificamente pra avaliação de custo em ambientes Azure e Databricks, capaz de responder perguntas como "quanto custaria capturar toda a tabela de auditoria do Unity Catalog num workspace do Log Analytics" ou "quanto realmente custa, de forma estática, um Azure Firewall rodando" antes de qualquer coisa ser de fato provisionada.

O que diferencia essa abordagem da calculadora de custo genérica de qualquer provedor de nuvem é o escopo: em vez de estimar preço de um recurso isolado, o agente foi pensado pra responder a pergunta que times de plataforma realmente fazem, "se eu montar esse desenho específico de arquitetura, qual o custo esperado", cruzando múltiplos serviços de uma vez.

Por que esse tipo de ferramenta resolve uma dor real de quem opera Databricks:
- Custo de nuvem hoje é descoberto majoritariamente de forma reativa, olhando a fatura do mês, não de forma preditiva antes do deploy
- Perguntas de custo que cruzam múltiplos serviços (Firewall + Databricks + Log Analytics) normalmente exigem juntar manualmente várias calculadoras diferentes
- Expor isso como algo que se pode "conversar" (via MCP, por exemplo) reduz a barreira de quem não é especialista em FinOps mas ainda assim precisa tomar decisão de arquitetura com custo em mente

**Minha ressalva:** um agente que estima custo é só tão confiável quanto sua capacidade de acompanhar mudanças de preço e SKU da própria nuvem, e isso muda com frequência. Eu trataria a saída desse tipo de agente como uma estimativa de ordem de grandeza pra apoiar decisão rápida, não como substituto da calculadora oficial do provedor na hora de aprovar orçamento formal.

**Fonte:** https://www.linkedin.com/in/casper-lubbers/

#Databricks #FinOps #Azure
