---
title: "O conector de SharePoint do Lakeflow Connect parou de ser só leitura de PDF solto"
date: 2026-06-06T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "SharePoint", "Lakeflow Connect", "Opinião"]
summary: "Ingestão estruturada, metadados de arquivo e schema evolution chegaram ao conector de SharePoint — ele deixou de ser um caso de uso de nicho pra virar ingestão de verdade."
ShowToc: false
---

❗ O conector gerenciado de SharePoint no Lakeflow Connect ganhou suporte a ingestão de arquivo estruturado (CSV, JSON, XML, Excel, Parquet, Avro, ORC), metadados de arquivo, filtros e schema evolution — substituindo a abordagem anterior, que só lidava com conteúdo não-estruturado.

Isso muda o que dá pra fazer: antes, SharePoint no pipeline era basicamente "jogar PDF pra dentro de um volume e extrair texto depois". Agora, planilha e arquivo estruturado dentro de biblioteca de documentos do SharePoint entram na esteira de ingestão do mesmo jeito que uma tabela de banco relacional.

Por que isso é mais relevante do que parece à primeira vista:
- Muita empresa ainda trata SharePoint como "banco de dados informal" de área de negócio
- Schema evolution automático evita quebrar pipeline toda vez que alguém adiciona uma coluna na planilha
- Metadados de arquivo (quem criou, quando modificou) viram linhagem, não só o conteúdo

❗ Minha ressalva: formalizar ingestão de SharePoint estruturado é reconhecer que dado de negócio crítico vive fora do Lakehouse, em planilha compartilhada sem controle de versão de schema. A ferramenta resolve o sintoma; o problema de governança de "quem pode criar uma coluna nova numa planilha que alimenta um pipeline" continua sendo humano.

🔗 Fonte: https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/june

#AzureDatabricks #SharePoint #LakeflowConnect
