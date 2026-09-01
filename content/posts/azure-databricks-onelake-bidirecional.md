---
title: "Azure Databricks e OneLake agora conversam nos dois sentidos"
date: 2026-06-18T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "OneLake", "Microsoft Fabric", "Unity Catalog", "Opinião"]
summary: "Federação de catálogo virou GA e o armazenamento nativo de Delta tables no OneLake entrou em beta, pela primeira vez a via de mão dupla entre Databricks e Fabric é oficial."
ShowToc: false
---

A relação entre Azure Databricks e Microsoft Fabric deixou de ser só "ler os dados do outro" e virou uma via de mão dupla.

De um lado, a federação de catálogo do OneLake atingiu GA: o Unity Catalog consulta dados que vivem no OneLake sem copiar nada. Do outro, entrou em beta a capacidade de o Databricks armazenar Delta tables gerenciadas *nativamente* dentro do próprio OneLake.

Por que isso importa pra quem vive entre os dois mundos (Fabric no time de BI, Databricks no time de engenharia):
- Acaba a pergunta "onde é a fonte da verdade", os dois lados podem apontar pro mesmo storage
- Menos pipeline de sincronização só pra levar dado de um lado pro outro
- Governança via Unity Catalog passa a valer também pro que fica fisicamente no OneLake

**Minha ressalva:** "sem cópia" não é sinônimo de "sem latência". Vale testar o desempenho de consulta federada sob carga real antes de assumir que substitui integração nativa, histórico de federação de catálogo entre plataformas diferentes costuma ter pegadinha de performance que só aparece em produção.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/june

#AzureDatabricks #OneLake #MicrosoftFabric
