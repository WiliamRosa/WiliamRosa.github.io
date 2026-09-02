---
title: "Reprocessar a tabela inteira só pra atualizar duas partições? Existe um padrão pra isso"
date: 2026-07-02T09:00:00-03:00
draft: false
tags: ["Databricks", "Liquid Clustering", "Delta Lake", "Opinião"]
summary: "O Databricks MVP Bartosz Konieczny detalha o Dynamic Data Overwriter: usar partitionOverwriteMode dinâmico ou liquid clustering com INSERT INTO...REPLACE USING pra substituir só o subconjunto de dados afetado, sem tocar no resto da tabela."
ShowToc: false
---

O Databricks MVP Bartosz Konieczny detalhou um padrão batizado de Dynamic Data Overwriter, evolução do clássico "Data Overwrite" que ele já documentava no livro "Data Engineering Design Patterns": se sua tabela é particionada ou clusterizada, você não precisa dizer explicitamente quais partições substituir, o engine consegue descobrir isso sozinho a partir dos próprios dados de entrada.

O mecanismo central é a detecção automática de escopo: o `partitionOverwriteMode=dynamic` do Apache Spark, o `INSERT INTO ... REPLACE USING` do liquid clustering do Databricks, e a estratégia incremental `insert_overwrite` do dbt implementam essa ideia nativamente. Quando não existe uma chave de partição clara, um `MERGE` bem construído com um identificador único de linha reproduz o mesmo comportamento.

Por que esse padrão resolve um atrito real:
- Elimina reprocessamento desnecessário de dados que não mudaram, só porque a lógica de overwrite tradicional exige reescrever a tabela inteira
- Funciona nativamente com liquid clustering, sem precisar desenhar esquema de particionamento manual
- Reduz o custo de compute em pipelines que hoje já fazem overwrite completo por simplicidade, não por necessidade real

**Minha ressalva:** o próprio Bartosz já sinaliza os problemas que essa técnica não resolve sozinha, dado atrasado (late data) que chega fora da janela esperada, visibilidade real do que mudou entre execuções, e o trade-off de performance quando o escopo detectado automaticamente é maior do que o esperado. Detecção automática de escopo é ótima até o dia em que ela decide reprocessar mais partições do que você imaginava, e a fatura de compute chega maior sem aviso.

**Fonte:** https://www.waitingforcode.com/data-engineering-patterns/data-engineering-design-patterns-dynamic-data-overwriter/read

#Databricks #LiquidClustering #DeltaLake
