---
title: "Lakebase Search junta busca vetorial e busca por palavra-chave dentro do próprio Postgres"
date: 2026-09-16T09:00:00-03:00
draft: true
tags: ["Databricks", "Lakebase", "Azure Databricks", "AI"]
summary: "Lakebase Search chega como camada de busca híbrida dentro do Lakebase: lakebase_vector faz busca semântica compatível com pgvector e lakebase_text faz busca por palavra-chave com BM25, os dois combináveis via Reciprocal Rank Fusion sem sair do banco operacional."
ShowToc: false
---

Buscar por significado e buscar pela palavra exata sempre exigiram dois sistemas diferentes, até agora dentro do Lakebase.

O Azure Databricks lançou o Lakebase Search, um jeito de habilitar busca vetorial e busca por texto direto dentro de um projeto Lakebase, sem precisar de um banco vetorial separado nem de um índice de busca à parte. É uma extensão real do que já existia: o lakebase_vector aparecia como uma das três opções de vector store do Databricks, ainda em beta; agora ele ganha um parceiro dedicado a texto, o lakebase_text, e uma forma oficial de combinar os dois numa busca híbrida.

O mecanismo é feito de duas extensões de Postgres. O lakebase_vector adiciona busca aproximada por vizinho mais próximo via um novo tipo de índice, compatível com pgvector no mesmo tipo de dado e operador de distância, mas usando particionamento IVF com quantização RaBitQ, o que sustenta índice acima de um bilhão de vetores e constrói de 50 a 100 vezes mais rápido que HNSW. O lakebase_text adiciona busca por palavra-chave com ranking BM25 sobre o tipo tsvector padrão do Postgres, com pushdown que recupera só os K resultados mais relevantes em vez de pontuar cada linha da tabela.

Pontos técnicos que valem atenção:
- lakebase_vector é compatível com pgvector, mesmo tipo de coluna e mesmo operador de distância, então código existente não precisa mudar
- lakebase_text usa BM25 sobre tsvector, com pushdown Block-Max WAND pra não escanear a tabela inteira em cada busca
- Dá pra sincronizar tabela do Unity Catalog pro Lakebase via synced tables e já indexar a coluna sincronizada, sem duplicar pipeline de ingestão só pra busca
- Busca híbrida se monta combinando os top-K de cada busca com Reciprocal Rank Fusion, sem exigir um terceiro serviço
- Ativar Lakebase Search reinicia todo compute do projeto e a decisão é irreversível

**Minha ressalva:** a irreversibilidade de ativar o recurso, mais a exigência de Postgres 16 ou superior, pede um teste em ambiente isolado antes de ligar num projeto que já está em produção. É um recurso novo o bastante pra eu preferir ver mais gente rodando em carga real antes de recomendar de olhos fechados.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/lakebase-search

#Databricks #Lakebase #AzureDatabricks
