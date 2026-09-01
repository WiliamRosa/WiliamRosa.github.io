---
title: "Lakebase ganhou CDC de graça — e o Postgres nem percebe"
date: 2026-06-02T09:00:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Unity Catalog", "CDC", "Opinião"]
summary: "Lakebase Change Data Feed (ex-Lakehouse Sync) usa uma extensão de WAL do Postgres pra replicar toda escrita direto pra tabelas Delta no Unity Catalog, sem tocar na aplicação."
ShowToc: false
---

❗ O Lakebase ganhou uma capacidade de CDC (change data capture) nativa — hoje chamada Lakebase Change Data Feed, batizada inicialmente como Lakehouse Sync. O mecanismo: uma extensão chamada `wal2delta` roda dentro do próprio compute do Lakebase, faz logical decoding do write-ahead log do Postgres, e escreve cada insert/update/delete direto numa tabela Delta gerenciada no Unity Catalog — em lotes de aproximadamente 15 segundos.

O que chama atenção aqui não é "mais um conector de CDC" — é que a aplicação que escreve no Lakebase não precisa saber que isso está acontecendo. Não tem trigger pra configurar, não tem outbox pattern pra implementar, não tem job de ingestão pra agendar.

Por que isso resolve uma dor recorrente:
- CDC tradicional geralmente exige configurar replicação lógica manualmente ou manter uma ferramenta terceira só pra essa ponte
- Aqui, cada tabela de origem ganha automaticamente uma tabela de histórico (`lb_<nome>_history`) no Unity Catalog, com status de sincronização visível
- Dá pra inspecionar o estado da sincronização direto via SQL (`SELECT * FROM wal2delta.tables`), sem depender de dashboard externo

❗ Minha ressalva: CDC "invisível pra aplicação" é ótimo até o dia em que você precisa debugar por que uma linha não chegou no Delta a tempo. Ferramenta de CDC que roda por baixo dos panos tende a virar caixa-preta justamente no momento em que você mais precisa entender o que está acontecendo — eu documentaria desde já o processo de troubleshooting antes de depender disso pra decisão de negócio em tempo quase real.

🔗 Fonte: https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/lakehouse-sync

#Databricks #Lakebase #CDC
