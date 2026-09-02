---
title: "O Spark 4.2 finalmente entende o que é uma métrica de negócio, não só uma coluna"
date: 2026-08-03T09:00:00-03:00
draft: false
tags: ["Databricks", "ApacheSpark", "MetricViews", "Opinião"]
summary: "Metric Views trazem semântica nativa pro Spark SQL: dimensão e medida viram objeto de primeira classe que o motor entende, então dashboard, relatório e agente de IA calculam a mesma métrica do mesmo jeito."
ShowToc: false
---

Dashboard reporta uma receita, agente de IA reporta outra, e os dois estão olhando pro mesmo dado.

O Databricks MVP P Shekhar Shukla resumiu o problema clássico que motivou a novidade: quando cada consumidor de dado recalcula a mesma métrica de negócio à sua maneira, especialmente em razão, contagem distinta ou retenção, calculadas em grão diferente, o número diverge mesmo partindo da mesma tabela. O Spark 4.2 ataca isso trazendo semântica nativa pro Spark SQL através de Metric Views.

O mecanismo funciona via CREATE VIEW ... WITH METRICS, transformando dimensão (como agrupar o dado) e medida (o que precisa ser calculado) em objetos de primeira classe que o próprio motor entende e preserva a semântica de agregação pretendida, em vez de deixar cada ferramenta reinterpretar a lógica por conta própria. Uma vez definida, a Metric View carrega metadado semântico junto (nome de exibição, formato, sinônimo), então dashboard, relatório, aplicação e agente de IA consomem a mesma definição de métrica, com a mesma lógica de agregação, ao consultar o mesmo objeto.

Pontos técnicos que valem registrar:
- Sintaxe nova: CREATE VIEW ... WITH METRICS, dimensões e medidas declaradas explicitamente
- Resolve especialmente métrica sensível a grão de agregação: razão, contagem distinta, retenção
- Carrega metadado semântico (nome de exibição, formato, sinônimo) junto da definição técnica
- Funciona através de SQL, ferramenta de BI e aplicação externa consumindo o mesmo objeto

**Minhas considerações:** a promessa de "uma definição, todo mundo usa a mesma" só se sustenta se a organização realmente centralizar a criação de Metric View em vez de deixar cada time continuar definindo métrica solta em notebook ou dashboard próprio. A tecnologia resolve o problema de onde a definição pode viver; ela não resolve sozinha o problema de governança de quem tem autoridade pra decidir qual é a definição "certa" de receita quando dois times discordam.

**Fonte:** https://www.databricks.com/blog/introducing-apache-spark-42

#Databricks #ApacheSpark #MetricViews
