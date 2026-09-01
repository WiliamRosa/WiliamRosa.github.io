---
title: "A flag --watch dos bundles resolve o problema de editar no Databricks mas viver no seu IDE local"
date: 2026-08-12T09:00:00-03:00
draft: true
tags: ["Databricks", "Declarative Automation Bundles", "DevOps", "Opinião"]
summary: "Quem prefere trabalhar num IDE local mas às vezes precisa editar ativo direto no Databricks agora tem uma flag que sincroniza essa mudança de volta pro projeto local."
ShowToc: false
---

Se você prefere trabalhar num IDE local mas em algum momento precisa editar um ativo direto no Databricks, a flag `--watch` dos bundles resolve exatamente esse cenário: ela sincroniza a mudança feita no workspace de volta pro seu IDE local, automaticamente.

É o problema espelhado do que resolvi comentar sobre o source-linked deployment: lá, a UI edita e o YAML do bundle acompanha; aqui, é o desenvolvedor local que às vezes precisa ir até o workspace fazer um ajuste rápido, sem perder a referência de que o código "de verdade" mora no IDE. Sem uma flag como essa, esse tipo de edição pontual no workspace vira uma mudança órfã, que alguém eventualmente sobrescreve sem querer no próximo deploy.

Por que isso resolve um atrito real de quem já usa bundles no dia a dia:
- Elimina a necessidade de copiar manualmente uma mudança feita no workspace de volta pro arquivo local
- Reduz o risco clássico de "esqueci de levar essa correção pro Git e ela sumiu no próximo deploy"
- Complementa (não substitui) a disciplina de sempre revisar o diff antes de comitar

**Minha ressalva:** sincronização automática em qualquer direção (workspace → local, ou local → workspace) sempre carrega o mesmo risco — ela facilita esquecer de revisar o que realmente mudou. `--watch` é uma ferramenta de produtividade, não um substituto para olhar o diff no Git antes de assumir que uma alteração feita "rapidinho" no workspace está correta.

**Fonte:** https://www.linkedin.com/posts/hubertdudek_dabs-if-you-like-to-work-in-a-local-ide-activity

#Databricks #DeclarativeAutomationBundles #DevOps
