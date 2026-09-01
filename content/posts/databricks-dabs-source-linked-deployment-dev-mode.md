---
title: "Editar job pela interface web e ver o YAML do bundle mudar sozinho — o melhor dos dois mundos, com uma ressalva"
date: 2026-09-01T06:15:00-03:00
draft: true
tags: ["Databricks", "Declarative Automation Bundles", "DevOps", "Opinião"]
summary: "Em modo de desenvolvimento com source-linked deployment, editar job ou pipeline pela UI propaga a mudança automaticamente pros arquivos YML do bundle — low-code e infra-como-código convivendo, mas exige atenção no Git."
ShowToc: false
---

O Databricks MVP Hubert Dudek notou um detalhe útil do modo de desenvolvimento dos bundles: trabalhando a partir da experiência web, com source-linked deployment ativado (o padrão no modo dev), editar um job ou pipeline direto na interface propaga a mudança automaticamente pros arquivos YML do bundle. Na prática, é o melhor dos dois mundos: baixo código pra quem quer ajustar rápido pela UI, e Infrastructure as Code pra quem depende de versionamento — ao mesmo tempo.

Esse tipo de sincronização bidirecional (UI edita YAML, e não só o contrário) resolve uma fricção clássica de quem usa bundles: historicamente, editar pela UI e editar pelo arquivo eram dois mundos separados, e misturar os dois sem cuidado gerava divergência silenciosa entre o que estava rodando e o que estava versionado.

Por que isso é útil, mas pede disciplina:
- Reduz o atrito de "preciso editar um YAML só pra testar uma mudança pequena"
- Mantém o bundle como fonte de verdade, mesmo quando a edição começou pela interface
- Só funciona em modo de desenvolvimento — não é o comportamento esperado (nem desejável) em produção

**Minha ressalva** — a mesma que o próprio Hubert Dudek levantou: revise sempre as mudanças no Git antes de assumir que elas capturam tudo — elementos que não passam pela UI, como variáveis e mutators, não necessariamente ficam refletidos automaticamente. Sincronização automática é ótima pra produtividade, mas não substitui revisão de diff antes de comitar.

**Fonte:** https://www.linkedin.com/posts/hubertdudek_when-working-from-the-web-experience-in-development-activity

#Databricks #DeclarativeAutomationBundles #DevOps
