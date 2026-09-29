---
title: "Achar PII escondido em PDF e formulário escaneado virou pipeline, não mais busca manual"
date: 2026-09-16T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Governança", "Azure Databricks"]
summary: "O Databricks MVP Dilorom Abdullah documentou um padrão composável que junta ai_parse_document e ai_classify para achar e marcar PII dentro de documento não estruturado, PDF, formulário escaneado, texto livre, rodando inteiro dentro do perímetro de segurança do workspace."
ShowToc: false
---

Encontrar dado sensível escondido dentro de PDF e formulário escaneado deixou de depender de ferramenta externa de OCR e virou uma combinação de duas funções nativas do Azure Databricks.

O Databricks MVP Dilorom Abdullah descreveu um padrão que resolve uma pergunta recorrente de líder de dado em setor regulado: como achar e marcar PII que não está numa tabela, mas dentro de texto livre, imagem de formulário ou documento escaneado. A resposta não é um botão único, é uma composição de duas funções de IA nativas do Unity Catalog encadeadas numa pipeline.

A primeira etapa, ai_parse_document, quebra o documento em elementos estruturados, parágrafo, tabela, campo de formulário, preservando a posição de cada pedaço dentro do arquivo original. A segunda etapa, ai_classify, aplica classificação customizada em cima desses elementos, incluindo categoria de PII definida pelo próprio time, CPF, endereço, dado de saúde, o que fizer sentido pro caso de uso. O resultado é uma pipeline governada e repetível que roda inteira dentro do perímetro de segurança do workspace, sem mandar documento pra serviço externo de document intelligence.

Pontos técnicos que valem atenção:
- ai_parse_document decompõe o documento em elementos estruturados antes de qualquer classificação
- ai_classify aplica categoria de PII definida pelo usuário sobre cada elemento decomposto
- A tag de classificação se aplica no nível de volume do Unity Catalog, não linha a linha
- Todo o processamento roda dentro do perímetro de segurança do workspace, sem chamada a serviço externo de OCR

**Minha ressalva:** a decisão de aplicar a tag de classificação no nível de volume, não por documento nem por elemento, empurra a responsabilidade de arquitetura pra antes da implementação. Se o time não segregar volume por sensibilidade ou não camada uma metadata de governança por cima, o controle de acesso vira uma aproximação grosseira em vez de granular, e aí a promessa de "dado governado desde a origem" some no meio do caminho.

**Fonte:** https://www.linkedin.com/in/diloromabdullah/

#Databricks #UnityCatalog #Governança
