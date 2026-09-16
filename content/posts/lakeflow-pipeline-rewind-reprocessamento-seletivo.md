---
title: "Pipeline com dado errado desde ontem? Agora dá pra voltar só até esse ponto e reprocessar"
date: 2026-09-15T09:15:00-03:00
draft: true
tags: ["Databricks", "Lakeflow", "Engenharia de Dados", "Azure Databricks"]
summary: "O Pipeline Rewind do Lakeflow permite voltar uma pipeline a um ponto anterior a um problema conhecido e reprocessar só o dado afetado, restaurando versão de tabela, offset de origem e estado do operador juntos."
ShowToc: false
---

Até agora, corrigir uma pipeline que quebrou no meio do caminho normalmente significava reprocessar tudo de novo ou remendar manualmente o pedaço afetado.

O Databricks MVP Soufiane Darraz destacou o lançamento do Pipeline Rewind no Lakeflow, recurso pensado justamente pra esse cenário: uma transformação com bug, um lote malformado ou uma mudança de schema que deixou as tabelas erradas a partir de um ponto conhecido. Em vez de reconstruir a pipeline inteira, o Pipeline Rewind volta a pipeline pra um estado anterior ao problema e reprocessa apenas os dados afetados a partir dali.

O que diferencia isso de um simples "rodar de novo" é que o rewind trata versão de tabela, offset da fonte e estado do operador como uma unidade só, restaurando os três juntos. Isso evita tanto duplicar registro quanto pular dado durante o replay, inclusive em consultas com estado, como join e agregação.

Pontos técnicos:
- Restaura versão de tabela, offset de origem e estado do operador de forma coordenada, não isoladamente
- Reprocessa só o dado afetado a partir do ponto de retomada, não o histórico inteiro
- Evita registro duplicado ou dado pulado durante o replay
- Funciona com Delta, Kafka, Auto Loader e fluxos de CDC
- Compatível com consultas com estado, como join e agregação

**Minhas considerações:** esse é o tipo de recurso que só mostra seu valor de verdade no dia em que alguém detecta uma transformação errada às três da manhã. A dúvida prática que fica é até que ponto o rewind lida bem com pipelines que têm múltiplos consumidores downstream lendo o mesmo estado intermediário, já que voltar uma etapa no meio do grafo pode exigir coordenar o rewind em mais de um lugar ao mesmo tempo.

**Fonte:** https://learn.microsoft.com/azure/databricks/ldp/rewind

#Databricks #Lakeflow #EngenhariaDeDados
