---
title: "Filtrar array com Higher-Order Function no Spark SQL pode ser mais lento que explode seguido de filter"
date: 2026-10-28T09:00:00-03:00
draft: false
tags: ["Databricks", "Apache Spark", "Spark SQL", "Azure Databricks"]
summary: "O Databricks MVP Bartosz Konieczny testou filtrar array direto com a higher-order function filter() do Spark SQL contra o padrão explode seguido de filter, e o plano de execução gerado pelo Catalyst mostrou o oposto do que a intuição sugeria."
ShowToc: false
---

Um benchmark que devia confirmar a função mais moderna do Spark SQL acabou mostrando o contrário.

O Databricks MVP Bartosz Konieczny testou um padrão que parece óbvio na teoria: filtrar elemento de array direto com a higher-order function filter() do Spark SQL deveria ser mais rápido que explodir o array em linha, filtrar linha por linha e recolher o resultado de volta depois. Konieczny foi direto no plano de execução gerado pelo Catalyst pra confirmar essa hipótese, e encontrou o oposto.

O motivo está no whole-stage codegen do Spark. Quando a consulta usa explode seguido de filter, o Catalyst consegue fundir a conversão de Parquet pra linha, o explode e o filter numa única unidade de execução, um só loop compilado, sem material intermediário entre as etapas. Quando a filtragem acontece dentro da higher-order function, ela roda depois da conversão columnar-to-row, numa etapa separada do pipeline fundido, perdendo justamente a otimização que fazia a diferença de performance.

Pontos técnicos que valem atenção:
- filter() e outras higher-order functions, como transform e exists, operam sobre o valor do array já materializado como linha, fora do loop fundido pelo codegen
- O padrão explode seguido de filter e depois collect_list (ou group by) permanece dentro da mesma unidade de execução compilada, do scan ao resultado final
- O artigo não traz número de benchmark, a evidência vem direto do plano de execução gerado pelo Catalyst, não de medição de tempo
- A diferença só importa em volume alto de linha ou array grande; pra array pequeno e consulta ocasional, a legibilidade da higher-order function ainda compensa

**Minha ressalva:** isso é um daqueles casos em que a API mais nova e mais elegante não é sinônimo de mais rápida, e vale olhar o plano de execução antes de assumir que a sintaxe moderna ganha por padrão. Pra pipeline que roda uma vez por dia sobre um array de três elementos, a troca não compensa a perda de legibilidade do código.

**Fonte:** https://www.waitingforcode.com/apache-spark-sql/filtering-arrays-apache-spark-sql/read

#ApacheSpark #SparkSQL #AzureDatabricks
