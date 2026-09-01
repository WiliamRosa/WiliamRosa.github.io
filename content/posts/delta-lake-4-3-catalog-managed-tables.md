---
title: "Delta 4.3 faz até CREATE TABLE passar pelo catálogo, não só a leitura"
date: 2026-06-23T09:00:00-03:00
draft: true
tags: ["Databricks", "Delta Lake", "Unity Catalog", "Apache Iceberg", "Opinião"]
summary: "Delta 4.3 expande as catalog-managed tables para que operações de escrita, CREATE, REPLACE, ALTER TABLE, também passem por validação de commit do lado do catálogo, não só a leitura."
ShowToc: false
---

O Databricks MVP Jacek Laskowski chamou atenção pro Delta Lake 4.3, que avança sobre as catalog-managed tables com as Unity Catalog Delta REST APIs: agora operações de tabela, carregamento, CREATE, CTAS, REPLACE, CREATE OR REPLACE, RTAS, evolução de schema via DML, e ALTER TABLE suportado, passam por APIs unificadas de catálogo, com validação de commit do lado do servidor. Antes, era comum que só a leitura se beneficiasse de um catálogo central; agora a escrita também fica sujeita à mesma validação.

A versão também melhora o UniForm, a conversão incremental e atômica pra Iceberg: o modo experimental IcebergCompatV3 passa a suportar deletion vectors e UniForm na mesma tabela, uma combinação que antes exigia escolher entre um recurso ou outro.

Por que isso é mais relevante do que "mais uma versão do Delta":
- Validação de commit do lado do catálogo pra operações de escrita fecha uma lacuna que existia entre "o catálogo sabe o que existe" e "o catálogo garante que a escrita seguiu as regras"
- Apache Spark, DuckDB, Apache Flink e clientes Delta-Kernel conseguem compartilhar a mesma tabela através de um catálogo único, interoperabilidade que historicamente era o ponto fraco do formato
- Deletion vectors + UniForm juntos significa que dá pra ter performance de delete moderna sem abrir mão da compatibilidade com Iceberg

**Minha ressalva:** interoperabilidade multi-engine sobre o mesmo catálogo é ótima na teoria, mas cada engine adicional que escreve na mesma tabela é mais uma superfície de comportamento pra testar, a promessa de "qualquer engine, mesma tabela" só se sustenta na prática se cada implementação respeitar de fato as mesmas garantias de commit. Eu testaria com cuidado antes de misturar múltiplos engines de escrita na mesma tabela em produção.

**Fonte:** https://delta.io/blog/2026-06-22-delta-4-3-release/

#Databricks #DeltaLake #ApacheIceberg
