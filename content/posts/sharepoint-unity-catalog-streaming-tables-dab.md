---
title: "Ingestão de múltiplas pastas do SharePoint como streaming table, toda declarada em código"
date: 2026-09-26T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Unity Catalog", "Declarative Automation Bundles", "SharePoint"]
summary: "O Databricks MVP Abiola David demonstrou como ingerir dados de múltiplas pastas do SharePoint como streaming tables no Unity Catalog usando Declarative Automation Bundles, com schema evolution automática e deploy repetível em Azure Databricks."
ShowToc: false
---

Ingestão de SharePoint costuma significar script avulso rodando numa máquina esquecida. Declarar esse fluxo inteiro como código muda o jogo de manutenção.

O Databricks MVP Abiola David demonstrou como ingerir dados de múltiplas pastas do SharePoint diretamente como streaming tables no Unity Catalog, usando Declarative Automation Bundles (DAB) no Azure Databricks. A proposta é tratar o fluxo de ingestão inteiro, desde a conexão com o SharePoint até a tabela final governada, como infraestrutura declarada em código, em vez de um script que alguém roda manualmente quando lembra.

O ponto que mais chama atenção é o tratamento de schema evolution: como pastas do SharePoint tendem a receber arquivos com estrutura que muda com o tempo, a pipeline precisa se adaptar a essas mudanças de schema na origem sem quebrar o fluxo downstream. Isso é o tipo de detalhe que separa uma demonstração de algo realmente pronto para produção.

Pontos técnicos da demonstração:

- Ingestão de dados de múltiplas pastas do SharePoint como streaming tables no Unity Catalog
- Fluxo de ingestão ponta a ponta declarado como código via Declarative Automation Bundles
- Gestão dos recursos Databricks por uma abordagem totalmente declarativa, não imperativa
- Tratamento de schema evolution para lidar com mudanças na estrutura dos arquivos de origem
- Deploy repetível, escalável e pronto para produção, seguindo princípios de Infrastructure as Code

**Minha leitura:** SharePoint como fonte de dado corporativo é mais comum do que a maioria dos pipelines de dados assume, e normalmente é tratado como integração de segunda classe, resolvida com script manual. Declarar esse fluxo com DAB, incluindo a parte chata de schema evolution, é o tipo de disciplina de engenharia que faz a diferença entre um pipeline que sobrevive a uma mudança de estrutura no SharePoint e um que quebra silenciosamente.

**Fonte:** https://www.linkedin.com/in/abioladavid01/#sharepoint-unity-catalog-streaming-tables-dab

#AzureDatabricks #UnityCatalog #DataEngineering
