---
title: "Pipeline que passa inteira não significa número certo: teste unitário nativo chega ao Lakeflow"
date: 2026-10-13T09:00:00-03:00
draft: false
tags: ["Databricks", "Azure Databricks", "Lakeflow", "Data Engineering", "Testes"]
summary: "O Databricks MVP Shashank Shekhar documentou o teste unitário nativo (Beta) de Spark Declarative Pipelines: roda dentro do próprio editor, redireciona tabela pra um schema isolado com dado mockado via test_spark, executa refresh seletivo com TestPipeline.active() e checa resultado, pegando bug de lógica que passaria despercebido mesmo com toda expectation satisfeita."
ShowToc: false
---

Uma pipeline pode rodar do início ao fim sem erro nenhum e ainda assim entregar um número errado, e é exatamente esse tipo de falha silenciosa que expectation de linha não pega.

O Databricks MVP Shashank Shekhar documentou o teste unitário nativo de Spark Declarative Pipelines (SDP), agora em Beta, usando um exemplo concreto pra mostrar o problema: numa pipeline de pedido de varejo com join de SCD Type 2, cada linha histórica de cliente casava com o pedido, inflando a contagem de 14 pra 25 pedidos. Toda expectation de linha passava, porque cada linha individual era válida; só um teste sobre o agregado final pegava o erro.

O framework roda inteiro dentro do editor da pipeline, sobre o compute da própria pipeline, sem precisar de infraestrutura de teste separada. A peça central é o `test_spark`, uma fixture de sessão que redireciona nome de tabela totalmente qualificado pra um schema isolado por execução, então o teste lê dado mockado em vez de dado de produção; o dado mockado entra via `CREATE OR REPLACE TABLE ... AS SELECT * FROM VALUES`. A partir daí, `TestPipeline.active()` pega a pipeline aberta no editor, e `test_pipeline.run(session, tables)` executa um refresh seletivo só das tabelas listadas, retornando um status que precisa ser checado antes de qualquer asserção, porque uma falha de execução aparece disfarçada de "tabela não encontrada" se ninguém checar `status.is_success` primeiro.

Pontos técnicos que valem registrar:
- Roda dentro do editor da pipeline, sem exigir infraestrutura de teste à parte
- `test_spark` redireciona só nome de tabela totalmente qualificado; view é inlined e não precisa ser listada
- Padrão de asserção cobre contagem de linha, valor exato de agregado, igualdade de conjunto em saída categórica, e teste de expectation contando se a linha com chave nula foi descartada
- Chamar `run()` mais de uma vez entre inserções de linha testa comportamento incremental, útil pra validar lógica de SCD2/CDC que depende de ordem
- Recurso em Beta; integração com CLI e CI/CD está planejada como próximo passo, ainda não existe

**Minha ressalva:** o próprio autor frisa que teste unitário cobre lógica de transformação sobre entrada escolhida, não substitui expectation nem monitoramento sobre dado real; é fácil ler "teste unitário chegou" como "agora minha pipeline está testada de ponta a ponta" quando na verdade é mais uma camada, não uma substituição. A ausência de integração com CI/CD por enquanto também significa que esse teste ainda depende de alguém rodar manualmente no editor antes de cada deploy, não é gate automático de pipeline ainda.

**Fonte:** https://community.databricks.com/t5/data-engineering/how-to-unit-test-spark-declarative-pipelines/td-p/172364

#Databricks #AzureDatabricks #Lakeflow
