---
title: "Omnigent: a Databricks aposta que orquestrar agentes importa mais do que escolher um só"
date: 2026-08-25T08:30:00-03:00
draft: false
tags: ["Databricks", "Omnigent", "Agentes de IA", "Multi-agente", "Arquitetura", "Opinião"]
summary: "O Omnigent propõe uma camada compartilhada para orquestrar múltiplos agentes de código sem perder contexto entre eles. Acho que essa é a pergunta certa, mas a resposta ainda depende de execução."
ShowToc: true
---

## O que a Databricks anunciou

A Databricks apresentou o **Omnigent**, descrito como um "meta-harness" open-source: uma camada compartilhada que permite trocar de agente de código sem perder contexto, rotear tarefas de forma inteligente, definir políticas contextuais e controles de gasto, e inserir aprovação humana onde for necessário. O anúncio veio junto com uma conversa entre Youssef Mrini, Quentin Ambard e o cofundador e CTO da Databricks, Matei Zaharia.

Fonte original: [post da Databricks no LinkedIn](https://lnkd.in/gsrXgEhk)

## Por que isso importa na prática

Quem usa mais de um agente de código no dia a dia (Copilot para uma coisa, Claude Code para outra, um agente proprietário para uma terceira) sabe o custo invisível de trocar de ferramenta: o contexto do que já foi decidido, testado e descartado fica preso na ferramenta anterior. Cada troca de agente hoje é, na prática, um recomeço de contexto.

O Omnigent ataca esse problema por baixo, como uma camada de orquestração e não como "mais um agente competindo pela sua atenção". Isso é coerente com o outro anúncio da Databricks sobre orçamento de gasto com coding agents (veja [minha análise aqui](/posts/databricks-governanca-gastos-ia-coding-agents/)): se você quer controlar custo e política *através* de várias ferramentas de agente, precisa de uma camada abaixo delas, não de mais uma ferramenta ao lado.

## Minha opinião

A pergunta que o Omnigent tenta responder — "como você orquestra vários agentes sem que cada troca de ferramenta vire um recomeço" — é, na minha visão, uma das perguntas mais subestimadas do momento em engenharia de IA. A maior parte do mercado ainda está competindo em "qual agente é melhor", enquanto o problema real de quem opera múltiplos agentes em produção é de orquestração, não de escolha de modelo.

Dito isso, sou cauteloso com "meta-harness" como categoria. Já presenciei esse padrão de "camada universal que integra tudo" prometer mais do que entrega quando o ecossistema por baixo muda rápido demais — e agentes de código são hoje o ecossistema que mais muda rápido. O real teste de fogo do Omnigent não é a demonstração em vídeo com o Matei Zaharia, é: daqui a seis meses, quando surgir um agente de código totalmente novo, o Omnigent consegue absorver ele com o mesmo nível de contexto compartilhado, ou vira mais uma integração para manter?

Sendo open-source, pelo menos existe transparência para a comunidade avaliar isso na prática — e é esse código que pretendo revisar antes de recomendar adoção em produção para quem pergunta no grupo de usuários que lidero em São Paulo.

## Para saber mais

- Post original: https://lnkd.in/gsrXgEhk
- Documentação oficial do Databricks: https://docs.databricks.com/
