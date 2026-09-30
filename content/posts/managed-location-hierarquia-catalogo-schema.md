---
title: "Onde sua managed table mora não precisa mais ser decisão do metastore inteiro"
date: 2026-09-29T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Azure Databricks", "Governança"]
summary: "A Databricks publicou um guia detalhando o comando SET MANAGED LOCATION em três níveis de hierarquia, metastore, catálogo e schema, cada um sobrepondo o anterior, além de ALTER CATALOG/SCHEMA para redirecionar tabela nova sem afetar a existente e ALTER TABLE para converter external em managed copiando o dado."
ShowToc: false
---

Até pouco tempo atrás, decidir onde o dado gerenciado do Unity Catalog fica fisicamente armazenado era praticamente uma decisão de metastore inteiro, difícil de segmentar por time ou por exigência de residência de dado.

A Databricks detalhou como o controle de localização de managed table no Unity Catalog funciona em três níveis de hierarquia, cada um mais específico que o anterior: metastore, o padrão mais amplo; catálogo, que sobrepõe o metastore; e schema, o nível mais específico, que sobrepõe o catálogo. A regra é direta, o nível mais específico sempre vence, então uma equipe consegue segmentar onde o dado fica sem precisar reconfigurar o metastore inteiro pra isso.

Pontos técnicos que valem registrar:
- `SET MANAGED LOCATION` funciona nos três níveis, metastore, catálogo e schema, com precedência do mais específico sobre o mais amplo
- `ALTER CATALOG` ou `ALTER SCHEMA ... SET MANAGED LOCATION` redireciona só tabela nova pro storage novo, sem mexer na tabela que já existe
- `ALTER TABLE ... SET MANAGED LOCATION` converte uma external table em managed table copiando o dado pro local de destino
- O dado managed continua acessível via Iceberg REST Catalog e Unity Catalog Open APIs pra ferramenta externa como Spark, Trino e Flink, mesmo depois da conversão
- Cobre os três provedores de nuvem, S3, ADLS e GCS

**Minhas considerações:** o ganho real aqui não é uma feature nova de armazenamento, é dar às equipes de governança uma ferramenta de segmentação que já deveria existir desde o início do Unity Catalog. Empresa com exigência de residência de dado por região, ou que quer isolar custo de storage por time, ganha uma forma nativa de fazer isso sem workaround de external table. O único cuidado é a conversão via `ALTER TABLE`: como ela copia o dado, vale medir o tamanho da tabela antes de rodar isso em produção, não é uma operação instantânea de metadado.

**Fonte:** https://www.databricks.com/blog/your-data-your-storage-your-rules-2026-guide-storing-unity-catalog-managed-tables

#Databricks #UnityCatalog #AzureDatabricks
