---
title: "Um orçamento só não basta para controlar gasto com IA"
date: 2026-08-18T00:05:00-03:00
draft: false
tags: ["Databricks", "FinOps", "Coding Agents", "LinkedIn", "Opinião"]
summary: "Por que dividir o controle de gasto com IA em orçamento diário e mensal resolve dois problemas que um limite único não resolve sozinho."
ShowToc: false
---

❗ A própria Databricks tinha um problema que a maioria dos times de engenharia finge não ter: gasto de coding agents crescendo rápido demais pra caber num único limite.

A solução interna que eles compartilharam foi dividir o orçamento em dois:
- Orçamento diário: pega gasto descontrolado rápido, com aumento self-service quando o uso é claramente legítimo
- Orçamento mensal: governa gasto extraordinário, com aprovação do gestor por projeto

Como todo agente passa pelo mesmo gateway, o controle vale pra qualquer ferramenta e modelo — sem depender de qual agente cada time escolheu usar.

❗ O que eu adicionaria: essa divisão resolve muito bem o "quanto" se gasta, mas não o "com o quê". Um agente pode ficar dentro do orçamento e ainda assim gastar tokens em tarefa de baixo valor. Limite de gasto é controle financeiro — qualidade de uso ainda depende de observabilidade e cultura de engenharia.

🔗 Fonte: https://www.databricks.com/blog/how-databricks-manages-its-own-coding-agent-spend-unity-ai-gateway-budgets

#Databricks #FinOps #EngenhariaDeIA
