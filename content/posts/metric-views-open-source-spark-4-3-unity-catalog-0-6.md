---
title: "Metric Views saiu do Databricks e virou parte do Apache Spark e do Unity Catalog open source"
date: 2026-08-27T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Apache Spark", "Metric Views"]
summary: "O Databricks MVP Geir E. Alstad destacou que Metric Views chegou ao Apache Spark 4.3 e ao Unity Catalog 0.6 open source, levando a semântica de negócio definida em YAML e a função MEASURE() pra fora do Databricks hospedado."
ShowToc: false
---

O Databricks MVP Geir E. Alstad chamou atenção pra uma mudança que muda o alcance de uma feature que este blog já cobriu antes só dentro do Databricks: Metric Views deixou de ser exclusividade da plataforma hospedada e chegou à versão open source do Apache Spark 4.3 e do Unity Catalog 0.6.

A mecânica é a mesma já vista no Spark 4.2 dentro do Databricks: você define métrica de negócio uma vez, num arquivo YAML com fonte de dado, join, filtro, dimensão e medida, e a partir daí tanto pessoa quanto agente consultam a mesma definição em vez de cada um recalcular a métrica do seu jeito. A consulta usa a função `MEASURE()` pra pedir o valor de uma medida já nomeada, por exemplo `SELECT MEASURE(`Order Count`), MEASURE(`Total Revenue`) FROM orders_metric_view`, em vez de reescrever a lógica de agregação a cada relatório. O que muda agora é o alcance: rodando fora do Databricks, em qualquer ambiente Spark 4.3 com Unity Catalog 0.6, a mesma definição de métrica passa a valer pra time que não usa o Databricks hospedado, não só pra quem já está dentro do ecossistema.

Pontos técnicos que valem atenção:
- Requer Apache Spark 4.3 e Unity Catalog 0.6, ambos open source
- Definição em YAML cobre fonte, join, filtro, dimensão e medida numa peça só
- Função `MEASURE()` calcula a medida nomeada na hora da consulta
- Mesma definição serve pra consulta humana e pra agente, sem recalcular a métrica em cada lugar

**Minhas considerações:** complementando o que já vimos sobre Metric Views no Spark 4.2 dentro do Databricks, essa abertura pro open source parece menos sobre dar de graça uma feature e mais sobre tentar virar o padrão de fato pra camada semântica no ecossistema Spark, competindo direto com dbt Semantic Layer e ferramenta parecida. A pergunta que fica: quando a definição de métrica passa a rodar em qualquer motor Spark, quem garante que a mesma métrica calculada fora do Unity Catalog do Databricks continua governada com o mesmo rigor de permissão e auditoria que ela tem hospedada.

**Fonte:** https://unitycatalog.io/blogs/uc-metric-views/

#Databricks #UnityCatalog #ApacheSpark
