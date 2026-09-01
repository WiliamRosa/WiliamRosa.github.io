---
title: "Databricks ainda não rastreia a evolução do schema de uma tabela — mas dá pra construir isso com Delta Lake"
date: 2026-07-16T09:00:00-03:00
draft: true
tags: ["Databricks", "Delta Lake", "Unity Catalog", "Governança", "Opinião"]
summary: "O Databricks MVP Jaco van Gelder construiu uma função PySpark que reconstrói o histórico completo de mudanças de schema de uma tabela — útil pra auditoria financeira, algo que o Databricks não oferece pronto."
ShowToc: false
---

O Databricks MVP Jaco van Gelder resolveu um problema que o Databricks ainda não oferece pronto: uma forma nativa e simples de rastrear como o schema de uma tabela evoluiu ao longo do tempo. Ele construiu uma função em PySpark que usa a funcionalidade de histórico do Delta Lake pra reconstruir a linha do tempo completa de mudanças de schema de uma lista de tabelas — não só a linhagem de dado, mas a linhagem da própria estrutura.

O caso de uso que ele destaca é auditoria, principalmente em setor financeiro: saber exatamente quando uma coluna foi adicionada, removida ou teve o tipo alterado é o tipo de pergunta que auditoria anual cobra, e que hoje normalmente exige reconstrução manual a partir de log de mudança ou memória de quem mexeu na tabela.

Por que essa lacuna (e a solução pra ela) merece atenção:
- Governança de dado geralmente foca em quem acessou o quê, mas raramente em como a própria estrutura dos dados mudou ao longo do tempo
- O histórico do Delta Lake já guarda essa informação — o trabalho de Jaco foi extrair e organizar algo que tecnicamente já existia, só não estava exposto de forma consumível
- Ele mesmo apontou uma inconsistência interessante: remover coluna e adicionar coluna geram estruturas de array diferentes no histórico, o que deixou a query mais complexa do que deveria

**Minha ressalva:** uma solução comunitária pra uma lacuna de plataforma é útil, mas é exatamente esse tipo de funcionalidade que deveria eventualmente virar recurso nativo — linhagem de schema junto com linhagem de dado, dentro do próprio Unity Catalog. Até lá, quem depender dessa função precisa tratar a manutenção dela (e a compatibilidade com futuras mudanças no formato de histórico do Delta Lake) como responsabilidade própria, não como algo garantido pela plataforma.

**Fonte:** https://github.com/jacovg91/linkedinstuff/blob/main/code-snippets/schema-evolution2.py

#Databricks #DeltaLake #Governança
