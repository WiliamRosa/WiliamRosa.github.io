---
title: "Rastreamento automático de chamada MCP achou bug que custava quase 500 mil dólares por ano"
date: 2026-09-02T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity AI Gateway", "MCP", "Observabilidade"]
summary: "A Databricks publicou um caso interno onde o rastreamento OpenTelemetry nativo do Unity AI Gateway, cruzado com pergunta em linguagem natural no Genie One, achou sete bugs de ferramenta MCP responsáveis por quase 1,2 milhão de dólares por ano em token e hora de engenharia desperdiçados."
ShowToc: false
---

Um bug de formatação numa ferramenta de integração com Jira custava sozinho quase meio milhão de dólares por ano em token desperdiçado.

A Databricks publicou um relato interno mostrando como usou o rastreamento automático que o Unity AI Gateway já gera pra cada chamada de ferramenta MCP, sem precisar instrumentar nada a mais, pra encontrar falha silenciosa em produção. Toda chamada de ferramenta feita por um agente passa pelo gateway, que grava nome da ferramenta, argumento, erro, token consumido, latência e sessão numa tabela unificada.

Em vez de vasculhar log manualmente, o time usou o próprio Genie One, em linguagem natural, pra perguntar direto sobre essa tabela de rastreamento, tipo quais ferramentas falham mais e quanto isso custa. Esse cruzamento achou sete bugs em uma amostra de 24 horas.

Pontos técnicos que valem atenção:
- 1.409 falhas por dia identificadas nesses sete bugs somados
- Maior bug isolado: ferramenta de Jira esperava string separada por vírgula, mas recebia array JSON, gerando 535 falhas por dia e média de 12 turnos de conversa até o modelo conseguir contornar sozinho
- Custo estimado de token desperdiçado, cerca de 499 mil dólares por ano, mais cerca de 12 mil horas de engenharia perdidas, total próximo de 1,2 milhão de dólares por ano
- Correção do bug principal saiu em uma hora, da análise até o deploy
- Princípio de design reforçado pelo caso: ferramenta MCP deveria tolerar o jeito que modelo naturalmente chama ela, com coerção de tipo e valor default, em vez de simplesmente falhar

**Minhas considerações:** esse caso é um bom contraponto pra discussão de custo de IA que geralmente foca só em qual modelo é mais barato, aqui o desperdício real estava em ferramenta mal desenhada, não em escolha de modelo. Observabilidade nativa sem instrumentação extra parece ser o tipo de investimento que se paga sozinho quase imediatamente.

**Fonte:** https://www.databricks.com/blog/how-we-eliminated-1-million-year-wasted-ai-agent-spend-one-hour

#Databricks #UnityAIGateway #Observabilidade
