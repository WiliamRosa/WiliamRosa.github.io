---
title: "Lakehouse//RT promete SQL em milissegundos pra milhares de usuários simultâneos"
date: 2026-07-01T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Lakehouse RT", "Power BI", "SQL Warehouse", "Opinião"]
summary: "Um novo tipo de SQL warehouse serverless mirando latência sub-segundo em alta concorrência, o Lakehouse tentando entrar em terreno que sempre foi de banco operacional."
ShowToc: false
---

O Lakehouse//RT entrou em beta como um novo tipo de SQL warehouse serverless, desenhado especificamente pra latência sub-segundo em consultas de leitura contra tabelas do Unity Catalog, com alta concorrência, pensado pra servir dashboards de Power BI e analytics operacional pra centenas ou milhares de usuários simultâneos.

Isso é uma categoria de warehouse diferente da que a maioria já usa. Warehouse serverless comum é ótimo pra consulta analítica esporádica; Lakehouse//RT mira o cenário de "milhares de pessoas atualizando o mesmo dashboard ao mesmo tempo, toda hora".

Por que vale acompanhar:
- Dashboard de Power BI lento por causa de concorrência é uma reclamação clássica de quem serve BI em escala
- Separar warehouse "analítico esporádico" de warehouse "operacional de alta concorrência" é reconhecer que são cargas de trabalho diferentes, não a mesma coisa em tamanhos diferentes
- Se performar como anunciado, reduz a pressão pra exportar dado do Lakehouse pra um banco separado só pra servir dashboard rápido

**Minha ressalva:** "sub-segundo" em beta e "sub-segundo" em produção sob pico real de usuários raramente são a mesma promessa. Antes de migrar um dashboard crítico, eu testaria concorrência real, não só o benchmark de lançamento.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/june

#AzureDatabricks #LakehouseRT #PowerBI
