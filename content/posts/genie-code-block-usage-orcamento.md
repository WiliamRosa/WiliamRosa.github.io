---
title: "Genie Code agora pode bloquear uso de verdade quando o orçamento estoura, não só avisar"
date: 2026-09-14T17:00:00-03:00
draft: true
tags: ["Databricks", "Genie Code", "FinOps", "Opinião"]
summary: "A opção Block usage nos controles de orçamento do Genie Code impede o usuário de continuar usando o produto assim que o limite mensal, geral, por time ou por pessoa, é excedido, até o orçamento resetar no início do mês ou um admin liberar mais uso; antes só existia alerta, sem bloqueio efetivo."
ShowToc: false
---

O Databricks MVP Maksim Pachkouski apontou uma mudança pequena na superfície mas grande no efeito prático pra quem cuida de custo de IA generativa dentro da empresa.

Até aqui, orçamento de Genie Code só gerava alerta quando o limite era excedido, o que na prática significava que alguém precisava ver a notificação e agir manualmente pra impedir gasto continuar subindo. Com a opção Block usage habilitada, o próprio sistema impede o usuário de continuar usando o produto assim que o limite é ultrapassado, seja um limite compartilhado, por time ou por usuário individual, até o orçamento resetar no início do mês seguinte ou um administrador aumentar manualmente o limite daquela pessoa ou grupo.

O detalhe que merece atenção é como a prioridade funciona quando existe mais de um nível de limite configurado ao mesmo tempo: se o limite compartilhado (do time ou da organização) estourar e estiver com bloqueio ativado, todo mundo dentro daquele escopo é bloqueado, mesmo quem individualmente nem chegou perto do próprio limite pessoal. Do mesmo jeito, um usuário que bate no próprio limite individual é bloqueado mesmo que o pool compartilhado ainda tenha saldo sobrando.

Pontos técnicos:

- Block usage bloqueia uso de Genie Code assim que o limite configurado é excedido, até reset mensal ou aumento manual por um admin
- Limite pode ser configurado em nível compartilhado (organização/time) ou por usuário individual
- Limite compartilhado excedido com bloqueio ativo bloqueia todo mundo do escopo, mesmo quem não bateu o próprio limite pessoal
- Limite individual excedido bloqueia aquele usuário mesmo com saldo sobrando no pool compartilhado
- Uso gratuito mensal de cada usuário nunca é removido por configuração de orçamento
- Databricks recomenda manter só "Send alert" ativo e usar limite por usuário com override específico em vez de bloqueio geral, pra ter controle mais granular

**Minhas considerações:** a própria recomendação da Databricks de preferir alerta e limite individual em vez de bloqueio geral já é um sinal de que Block usage é uma ferramenta de última linha, útil pra estourar teto de orçamento em cenário real de descontrole, mas arriscada como configuração padrão porque pode travar time inteiro por causa do consumo de uma pessoa só dentro do mesmo pool compartilhado.

Fonte: https://learn.microsoft.com/en-us/azure/databricks/genie/budgets

#Databricks #GenieCode #AzureDatabricks
