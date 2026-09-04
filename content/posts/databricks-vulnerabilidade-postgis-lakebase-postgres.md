---
title: "Uma falha no PostGIS expôs todo tenant do Lakebase Postgres, e a Databricks corrigiu antes de qualquer exploração"
date: 2026-09-02T08:30:00-03:00
draft: true
tags: ["Databricks", "Lakebase", "Segurança", "Opinião"]
summary: "Um pesquisador encontrou uma falha de bounds-check na extensão address_standardizer do PostGIS, explorável por qualquer usuário comum do Lakebase Postgres e do Neon, e a Databricks corrigiu antes da divulgação pública."
ShowToc: false
---

Um pesquisador de segurança achou uma falha que qualquer usuário comum do Lakebase Postgres, sem privilégio nenhum, conseguia explorar.

A Databricks publicou os detalhes de uma vulnerabilidade de memória encontrada na extensão address_standardizer do PostGIS, usada em bancos Postgres para normalizar endereço. A falha permitia que qualquer usuário com acesso normal ao banco, sem privilégio administrativo, acionasse um comportamento de estouro de limite na extensão, o tipo de brecha que em tese poderia ser usada para acessar memória fora do escopo esperado da consulta.

O que chama atenção não é só a falha em si, mas o processo em volta dela. A Databricks detectou o comportamento de teste do pesquisador de segurança Mehmet Ince de forma proativa, colaborou com ele durante a investigação, corrigiu o problema em produção rapidamente para proteger cliente do Lakebase Postgres e de outras plataformas que usam a mesma extensão, como o Neon, e depois contribuiu a correção completa de volta para o projeto PostGIS. O pesquisador, por sua vez, doou a recompensa do bug bounty para mantenedores voluntários de projeto open source.

Pontos técnicos que valem registrar:
- Falha de bounds-check na extensão address_standardizer do PostGIS, acionável por usuário comum, sem privilégio elevado
- Afetava qualquer plataforma de Postgres gerenciado que carregasse essa extensão, incluindo Lakebase Postgres e Neon
- Databricks identificou o teste do pesquisador antes da divulgação pública e já tinha corrigido quando o relatório formal chegou
- Correção completa contribuída de volta ao projeto PostGIS, beneficiando qualquer usuário da extensão, não só cliente Databricks

**Minha ressalva:** extensão de terceiro dentro de um Postgres gerenciado é superfície de ataque que a plataforma não controla sozinha. O processo de divulgação responsável funcionou bem dessa vez, mas o episódio é um lembrete de que rodar Postgres com extensão como PostGIS, mesmo dentro de um serviço gerenciado como o Lakebase, herda o risco de segurança do ecossistema de extensão que ninguém audita sozinho. Vale perguntar ao seu fornecedor de banco gerenciado, Databricks incluso, qual é o processo de auditoria de extensão de terceiro antes de habilitar qualquer uma em produção.

**Fonte:** https://www.databricks.com/blog/collaboration-makes-us-all-stronger

#Databricks #Lakebase #Seguranca
