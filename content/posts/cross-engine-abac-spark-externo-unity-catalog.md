---
title: "ABAC do Unity Catalog agora vale pra quem nem usa o Databricks como motor de consulta"
date: 2026-10-02T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Unity Catalog", "ABAC", "Governança"]
summary: "Cross-engine ABAC chegou em disponibilidade geral: Spark externo lendo tabela Delta ou Iceberg gerenciada do Unity Catalog agora tem política ABAC, row filter e column mask aplicados por uma camada serverless da Azure Databricks, mesmo sem o motor de consulta ser o próprio Databricks."
ShowToc: false
---

Já cobri várias vezes como o ABAC do Unity Catalog foi ganhando alcance: primeiro no nível de metastore, depois com atributo de identidade do Entra ID, depois Context Attributes pra distinguir agente de pessoa, depois DENY explícito, depois view. Em todos esses casos, a suposição implícita era que quem consulta o dado está dentro do Databricks. O Cross-engine ABAC quebra essa suposição.

Agora um cliente Apache Spark externo, rodando fora da plataforma, pode ler uma tabela gerenciada do Unity Catalog (Delta ou Iceberg) e ainda assim ter política ABAC, row filter e column mask aplicados, porque uma camada de enforcement serverless da própria Azure Databricks intercepta a consulta e devolve o dado já filtrado, antes que o motor externo veja qualquer linha que não devia ver.

Pontos técnicos do mecanismo:

- Só Spark é suportado como motor externo, em duas vias: Delta-Spark 4.1 ou superior com o conector Unity Catalog pra Spark 0.4 ou superior, ou Iceberg-Spark 1.11 ou superior com Spark 4.0 ou superior via o endpoint REST do Iceberg no Unity Catalog
- Exige acesso externo a dado habilitado no metastore, privilégio `EXTERNAL USE SCHEMA` concedido a quem consulta, e tabela gerenciada com catalog commits habilitado (Databricks Runtime 16.4 ou superior pra tabela nova, 18.0 ou superior pra promover tabela existente)
- É só leitura: quem escreve na tabela precisa estar isento da política ABAC, não dá pra escrever através dessa mesma camada de enforcement
- View dinâmica não é suportada, nem projeção de coluna do tipo VARIANT, nem filtro sobre coluna BINARY, nem column mask cujo tipo de retorno difere do tipo original da coluna
- A camada de enforcement serverless é cobrada separadamente, rastreável no system table de billing sob a categoria `EXTERNAL_COMPATIBILITY`
- Escrita concorrente durante o planejamento da consulta pode fazer self-join ou consulta com múltiplos scans ler snapshot diferente em cada parte, o que pode gerar resultado incorreto

**Minhas considerações:** depois de tanta expansão de escopo do ABAC dentro do próprio Databricks, esse é o primeiro passo pra fora da plataforma, e é um passo bem mais cauteloso do que os anteriores: só leitura, só Spark, e uma lista real de limitação técnica (self-join com snapshot inconsistente é séria o suficiente pra testar com cuidado antes de confiar em produção). Ainda assim, pra quem vive em ambiente multi-engine de verdade, onde nem todo consumidor de dado é um workspace Databricks, isso fecha uma lacuna de governança que não tinha solução nenhuma até agora, só política duplicada manualmente em cada motor externo.

**Fonte:** https://docs.databricks.com/aws/en/external-access/cross-engine-abac

**Fonte (Azure):** https://learn.microsoft.com/en-us/azure/databricks/external-access/cross-engine-abac

#AzureDatabricks #UnityCatalog #ABAC
