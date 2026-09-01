---
title: "Como a própria Databricks controla o gasto de milhares de engenheiros usando coding agents"
date: 2026-08-18T08:30:00-03:00
draft: false
tags: ["Databricks", "FinOps", "Coding Agents", "Unity AI Gateway", "Governança", "Opinião"]
summary: "A Databricks dividiu o controle de gasto com IA em orçamento diário e mensal, cada um resolvendo um problema diferente. É um case interno pequeno, mas com uma lição de FinOps que qualquer time de engenharia pode copiar hoje."
ShowToc: true
---

## O que a Databricks anunciou

A Databricks compartilhou como controla internamente o gasto de milhares de engenheiros que usam coding agents diariamente — hoje uma das linhas de custo de P&D que mais cresce. A solução foi dividir o problema em dois orçamentos com propósitos diferentes:

1. Um **orçamento diário**, que barra gasto descontrolado (runaway spend), com aumento self-service quando o uso é claramente intencional.
2. Um **orçamento mensal**, que governa gasto extraordinário, com aumentos por projeto e aprovação do gestor.

Como todo coding agent passa pelo Unity AI Gateway, os mesmos controles valem para qualquer ferramenta e modelo, com o uso medido em um único lugar. O objetivo declarado não é frear a adoção de IA, é manter o gasto visível e controlado enquanto se dá espaço para os engenheiros construírem.

Fonte original: [post da Databricks no LinkedIn](https://lnkd.in/gj_ShPjZ)

## Por que isso importa na prática

A maioria dos times que conheço trata gasto com IA generativa com um único limite genérico (ou nenhum limite, até a fatura assustar alguém). O insight aqui é sutil, mas relevante: um único orçamento tenta resolver dois problemas com naturezas opostas ao mesmo tempo — pegar erro/abuso rápido (que precisa de um limite curto e sensível, o diário) e permitir investimento real em um projeto que legitimamente precisa de mais IA (que precisa de um processo de aprovação mais deliberado, o mensal). Um limite único acaba sendo ou frouxo demais para pegar abuso, ou rígido demais para permitir uso legítimo — a divisão em dois resolve as duas pontas ao mesmo tempo.

## Minha opinião

Esse é o tipo de anúncio "pequeno" que, na minha visão, tem mais aplicação prática imediata do que a maioria dos lançamentos de produto desta lista — porque qualquer time, usando Databricks ou não, pode copiar a lógica de dois orçamentos amanhã, independente de ferramenta. Não depende de comprar Unity AI Gateway, depende de entender que "limite de gasto com IA" não é um número único, são dois problemas diferentes.

O que eu adicionaria, com o chapéu de quem pensa em governança: a divisão diário/mensal ataca bem o *quanto* se gasta, mas não necessariamente o *com o quê*. Um agente pode ficar dentro do orçamento diário e ainda assim gastar tokens em tarefas de baixo valor — refatorar código que não precisava, ou repetir chamadas em loop por um prompt mal ajustado. Orçamento é controle financeiro; qualidade de uso é um problema de observabilidade e cultura de engenharia, que nenhum limite de gasto resolve sozinho.

Ainda assim, é um relato honesto vindo de quem realmente opera a escala descrita, e vale mais do que a maioria dos artigos genéricos de "FinOps para IA" que circulam por aí.

## Para saber mais

- Post original: https://lnkd.in/gj_ShPjZ
- Documentação oficial do Databricks: https://docs.databricks.com/
