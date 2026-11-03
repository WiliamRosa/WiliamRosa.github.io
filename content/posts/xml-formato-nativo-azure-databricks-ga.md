---
title: "XML deixou de precisar de biblioteca externa pra entrar no lakehouse"
date: 2026-10-30T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Engenharia de Dados"]
summary: "O suporte nativo a arquivo XML no Azure Databricks atingiu disponibilidade geral, cobrindo ingestão, consulta e parsing em batch e streaming via Auto Loader, read_files, COPY INTO e as funções from_xml e schema_of_xml."
ShowToc: false
---

XML deixou de precisar de biblioteca externa ou gambiarra de regex pra entrar no lakehouse.

O suporte nativo a arquivo XML no Azure Databricks atingiu disponibilidade geral, cobrindo ingestão, consulta e parsing tanto em workload batch quanto streaming.

Antes desse suporte nativo, processar XML no Databricks normalmente passava por biblioteca externa de terceiro ou por conversão manual pra outro formato antes de carregar, com schema inferido de forma frágil e sujeito a quebra quando a estrutura do XML variava entre arquivo e arquivo. Com suporte nativo, o motor de leitura aplica a mesma lógica de inferência e evolução de schema que já usa pra JSON e outros formatos semiestruturados, e expõe funções SQL dedicadas pra quem prefere trabalhar com o XML como string dentro de uma coluna, em vez de só como arquivo de origem.

Pontos técnicos que valem atenção:
- Suporta Auto Loader, read_files e COPY INTO como caminho de ingestão, tanto batch quanto streaming
- Função from_xml converte string XML em struct tipado dentro de uma consulta SQL
- Função schema_of_xml infere a definição de schema a partir de uma amostra de XML, útil pra declarar schema fixo em vez de inferência automática recorrente
- Chega como GA direto, sem passagem documentada por Beta nas release notes

**Minhas considerações:** XML ainda é o formato padrão de muito sistema legado, em saúde e financeiro entre outros setores regulados, então ter suporte de primeira classe no motor, sem depender de biblioteca de terceiro mantida por fora, fecha uma lacuna que provavelmente afetava mais gente do que o anúncio sugere à primeira vista.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/query/formats/xml

#AzureDatabricks #EngenhariaDeDados
