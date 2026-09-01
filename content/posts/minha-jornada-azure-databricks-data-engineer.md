---
title: "Minha jornada até a certificação Azure Databricks Data Engineer Associate"
date: 2026-08-31T21:29:11-03:00
draft: false
tags: ["Databricks", "Azure", "Certificação", "Carreira"]
summary: "Como me preparei para a certificação, o que mais me surpreendeu no exame e por que decidi documentar publicamente minha jornada em dados."
ShowToc: true
---

## Introdução

Recentemente conquistei a certificação **Microsoft Certified: Azure Databricks Data Engineer Associate**, somando-se às minhas credenciais como **Databricks Certified Machine Learning Professional** e **Microsoft Certified Trainer (MCT)**. Neste primeiro post quero compartilhar como foi essa jornada de estudos, os principais aprendizados e por que decidi começar a documentar publicamente meu trabalho com dados, algo que já faço como líder do **São Paulo Databricks User Group** e palestrante no **TDC**, mas que até agora não tinha um espaço próprio.

## Por que essa certificação

Já atuava com Databricks no dia a dia, como Databricks Certified Machine Learning Professional, líder do São Paulo Databricks User Group e MCT, mas boa parte do meu trabalho real acontece especificamente na integração entre **Databricks e Azure**: Unity Catalog governando dados que vivem no Azure Data Lake Storage, autenticação via Microsoft Entra ID, segredos no Key Vault, monitoramento pelo Azure Monitor. O DP-750 é a certificação que valida exatamente essa combinação, e como meu objetivo é contribuir cada vez mais com a comunidade Microsoft, fazia sentido formalizar esse conhecimento com uma credencial oficial da própria Microsoft, e não só da Databricks.

## Como me preparei

Como já vinha da prática diária com a plataforma, o estudo foi mais um processo de **mapear lacunas e formalizar conceitos** do que aprender do zero:

- Revisão do **Study Guide oficial da Microsoft Learn** para o DP-750, objetivo por objetivo.
- Prática hands-on no **Databricks Free Edition**, recriando cenários de governança no Unity Catalog, pipelines com Lakeflow Jobs e Lakeflow Declarative Pipelines, e ingestão com Auto Loader.
- Revisão profunda de otimização em Delta Lake: `OPTIMIZE`, `VACUUM`, `Z-ORDER`, leitura de Spark UI e DAGs, e Adaptive Query Execution (AQE), tópicos que pesam bastante na prova.
- Estudo dos pontos de integração com Azure: ADLS, Key Vault, Microsoft Entra ID e Azure Monitor.

## Principais tópicos do exame

O exame é fortemente prático e cobre principalmente:

- **Unity Catalog**: governança, permissões e linhagem de dados.
- **Delta Lake**: internals, otimização de performance (`OPTIMIZE`, `VACUUM`, `Z-ORDER`) e MERGE/upserts.
- **Lakeflow Jobs e Lakeflow Spark Declarative Pipelines**: orquestração e pipelines declarativos de produção.
- **Auto Loader**: ingestão incremental de dados.
- **Databricks Asset Bundles**: deploy e CI/CD de projetos Databricks.
- **Integrações Azure**: Azure Data Lake Storage, Key Vault, Microsoft Entra ID e Azure Monitor.

Vale destacar: os domínios de **construção e deploy de pipelines de dados** concentram a maior parte da prova, então mais importante que decorar conceito é ter mão na massa.

## O que mais me surpreendeu

O quanto o exame é **cenário-based** e não teórico: em vez de perguntar "o que é o Unity Catalog", ele coloca um problema real de governança ou de pipeline quebrando em produção e pede a melhor solução. Também me chamou atenção o peso dado a **Databricks Asset Bundles**, um sinal claro de que a maturidade de Databricks no Azure já é tratada como engenharia de software de verdade, com CI/CD, e não só como notebooks avulsos.

## Próximos passos

A partir de agora pretendo publicar regularmente sobre Azure Databricks e Data Platform, compartilhando tanto conteúdo técnico (arquitetura, otimização, boas práticas) quanto opiniões sobre o ecossistema de dados. Se você trabalha ou está estudando a mesma área, me siga e vamos trocar experiências.
