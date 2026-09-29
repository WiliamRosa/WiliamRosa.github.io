---
title: "A Microsoft desligou a ponte que fazia o Power BI ler Metric Views do Databricks"
date: 2026-09-16T11:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "BI", "Azure Databricks"]
summary: "O Databricks MVP Mani Kandasamy documentou que a Microsoft removeu o BI compatibility mode que traduzia consulta do Power BI pra lógica de Metric Views do Unity Catalog, e que o mesmo problema atinge Snowflake Semantic Views no conector do Power BI: cada fornecedor de BI trata semântica alheia como tabela de segunda classe."
ShowToc: false
---

Uma ponte que traduzia consulta do Power BI direto pra lógica de negócio governada dentro do Databricks parou de funcionar, e a explicação oficial da Microsoft é simplesmente falta de prioridade.

O Databricks MVP Mani Kandasamy detalhou que o Databricks Metric Views tinha um recurso chamado BI compatibility mode, que reescrevia a consulta vinda do Power BI pra respeitar a lógica de métrica governada definida no Unity Catalog. A Microsoft removeu a opção de conector do Power BI que sustentava esse fluxo, e relatórios que dependiam dele pararam de funcionar. Segundo o que o próprio time de Power BI da Microsoft afirmou publicamente em abril, não existe plano de fazer o Power BI funcionar com semantic model de outro fornecedor, porque o esforço de manter isso é grande e o retorno é considerado pequeno. Não é bug, é decisão de produto.

O problema não é exclusivo do Databricks. Snowflake Semantic Views também não tem suporte nativo e geral no Power BI hoje: o que existe é um conector Fabric em beta com problema de autenticação e um conector de comunidade que quebra quando a semantic view usa granularidade mista entre colunas. Nos dois casos, tanto Databricks quanto Snowflake já resolveram o caminho contrário, importar um arquivo do Power BI e converter a lógica de DAX pra dentro da própria camada semântica (via Genie Code, no caso do Databricks), mas nenhum dos dois tem porta de volta nativa e mantida pelo lado do Power BI.

Pontos técnicos que valem atenção:
- BI compatibility mode reescrevia consulta do Power BI pra respeitar a lógica de Metric Views do Unity Catalog
- A opção de conector que sustentava esse fluxo foi removida pela Microsoft, quebrando relatório que dependia dela
- Snowflake Semantic Views sofre problema equivalente: sem suporte nativo geral no Power BI, só conector Fabric em beta ou conector de comunidade limitado
- O caminho inverso (importar arquivo do Power BI e converter DAX para dentro da camada semântica nativa) já existe tanto no Databricks quanto no Snowflake

**Minha ressalva:** o argumento de "esforço grande, retorno pequeno" da Microsoft é coerente do ponto de vista de quem já tem instalação dominante de Power BI, mas empurra o custo de manter métrica sincronizada pra fora do fornecedor de BI e pra dentro de quem paga a licença. Toda empresa que definiu métrica de negócio no Unity Catalog pensando em reuso multiplataforma precisa saber, antes de investir mais nisso, que essa reusabilidade depende da boa vontade comercial de cada ferramenta de BI, não só da qualidade técnica da camada semântica.

**Fonte:** https://www.linkedin.com/in/manikandasamy/

#Databricks #UnityCatalog #BI
