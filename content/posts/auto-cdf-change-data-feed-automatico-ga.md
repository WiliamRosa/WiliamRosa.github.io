---
title: "Change Data Feed automático chega à disponibilidade geral, sem precisar ligar nada tabela por tabela"
date: 2026-09-02T09:00:00-03:00
draft: true
tags: ["Databricks", "Delta Lake", "Azure Databricks", "Opinião"]
summary: "Automatic Change Data Feed (Auto CDF) atingiu disponibilidade geral no Azure Databricks: calcula mudança de linha na hora da consulta usando row tracking, sem exigir habilitar change data feed manualmente em cada tabela."
ShowToc: false
---

Ativar change data feed tabela por tabela deixou de ser necessário: agora o Databricks calcula a mudança de linha na hora em que alguém pergunta por ela.

O Azure Databricks anunciou a disponibilidade geral do Automatic Change Data Feed (Auto CDF), recurso que calcula mudança de linha usando row tracking no momento da consulta, sem exigir que você habilite change data feed manualmente em cada tabela Delta Lake ou Apache Iceberg v3.

A diferença em relação ao change data feed tradicional está em quando o custo é pago. Em vez de gravar dado extra de rastreamento de mudança a cada escrita, o Auto CDF calcula isso só quando alguém efetivamente consulta a mudança, removendo a sobrecarga de escrita em tabela que raramente é lida por esse ângulo. O recurso funciona em consulta batch, em Structured Streaming e em Delta Lake Sharing, e exige Databricks Runtime 19 LTS ou superior com row tracking habilitado.

Pontos técnicos que valem atenção:
- Calcula mudança de linha, insert, update e delete, na hora da consulta, usando row tracking, em vez de gravar changelog a cada escrita
- Funciona em consulta batch, Structured Streaming e Delta Lake Sharing
- Exige Databricks Runtime 19 LTS ou superior com row tracking habilitado
- A Databricks reporta operação de MERGE e UPDATE cerca de 15% mais rápida em tabela consultada por mudança, já que a sobrecarga de escrita deixa de acontecer antecipadamente

**Minhas considerações:** o ganho de desempenho aqui não vem de um MERGE ou UPDATE mais esperto, vem de mover o custo de "sempre que escreve" pra "só quando alguém de fato consulta a mudança". Isso favorece claramente tabela que raramente é lida via CDC, mas pra tabela consultada com frequência por streaming downstream vale medir se calcular a mudança a cada consulta não acaba custando mais do que o antigo rastreamento feito na escrita.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#automatic-change-data-feed-is-now-generally-available

#Databricks #DeltaLake #AzureDatabricks
