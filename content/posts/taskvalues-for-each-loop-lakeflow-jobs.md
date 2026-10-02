---
title: "taskValues conseguem alimentar um For Each loop inteiro no Lakeflow Jobs"
date: 2026-10-02T17:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow Jobs", "Orquestração", "DevOps"]
summary: "O Databricks MVP Hubert Dudek mostrou que o Databricks taskValues pode passar uma lista Python direto para um For Each loop no Lakeflow Jobs, permitindo gerar a lista de forma dinâmica e reaproveitar a mesma task para cada país, tabela ou arquivo."
ShowToc: false
---

Gerar a lista de iteração de um For Each loop na hora, em vez de deixar ela fixa na definição do job, é o tipo de ajuste pequeno que elimina um job duplicado inteiro.

O Databricks MVP Hubert Dudek apontou que o Databricks taskValues pode passar uma lista Python diretamente para dentro de um For Each loop no Lakeflow Jobs. Na prática, isso significa que uma task anterior no mesmo job pode calcular dinamicamente quais itens serão processados, e o For Each loop consome essa lista sem que ela precise estar hardcoded na definição do job.

O ganho prático aparece em qualquer cenário onde a lista de iteração varia de execução para execução: processar um conjunto de países, tabelas ou arquivos que muda com o tempo, sem precisar editar e redeployar o job cada vez que a lista muda. Em vez de manter um job por país ou um array fixo na definição, uma task upstream calcula a lista atual, passa ela via taskValues, e a mesma task roda uma vez para cada item.

Pontos técnicos relevantes:

- taskValues já existe no Lakeflow Jobs para passar valores entre tasks de um mesmo job
- A novidade é usar esse mecanismo para alimentar diretamente a lista de iteração de um For Each loop
- A lista pode ser calculada dinamicamente por uma task anterior, em vez de ficar fixa na definição do job
- O mesmo padrão serve para reaproveitar uma única task genérica em vários países, tabelas ou arquivos
- Elimina a necessidade de manter jobs duplicados ou listas hardcoded que exigem redeploy a cada mudança

**Minha leitura:** é o tipo de recurso que não aparece em keynote, mas resolve um atrito real de quem mantém pipeline com lista de iteração que muda com frequência. Vale revisar jobs existentes que hoje simulam esse comportamento com um array fixo na definição ou com jobs duplicados por item, porque essa é exatamente a dívida técnica que esse padrão remove.

**Fonte:** https://www.linkedin.com/in/hubertdudek/#taskvalues-for-each-loop-lakeflow-jobs

#Databricks #LakeflowJobs #DataEngineering
