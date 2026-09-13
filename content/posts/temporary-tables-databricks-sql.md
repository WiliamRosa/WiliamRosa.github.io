---
title: "Databricks SQL ganhou tabela temporária de verdade, escopada por sessão e com limpeza automática"
date: 2026-09-14T18:00:00-03:00
draft: true
tags: ["Databricks", "Databricks SQL", "Delta Lake", "Opinião"]
summary: "CREATE TEMPORARY TABLE cria uma tabela Delta física que existe só durante a sessão que a criou, com limite máximo de sete dias de vida, usando a mesma infraestrutura de cache e performance de uma tabela padrão, mas sem exigir limpeza manual nem poluir o catálogo com objeto de vida curta."
ShowToc: false
---

A Databricks lançou suporte nativo a tabela temporária no Databricks SQL, fechando uma lacuna que forçava analista e engenheiro a criar tabela permanente só pra armazenar resultado intermediário e depois lembrar de apagar depois.

A tabela criada com `CREATE TEMPORARY TABLE` (ou `CREATE TEMP TABLE`) é uma tabela Delta física de verdade, guardada num local interno do Unity Catalog atrelado ao workspace, usando o mesmo cache e as mesmas otimizações de performance de uma tabela Delta comum. A diferença é o ciclo de vida: ela existe só enquanto a sessão que a criou estiver ativa, com um teto absoluto de sete dias mesmo que a sessão continue aberta além disso, e um serviço de limpeza remove o objeto automaticamente quando a sessão termina ou esse limite é atingido.

Isso resolve um padrão comum em pipeline SQL exploratório e em análise ad hoc: materializar um resultado intermediário pra reaproveitar em consulta seguinte sem pagar o custo de recalcular do zero, mas sem precisar criar uma tabela permanente que alguém vai ter que lembrar de derrubar depois, ou que vai aparecer indevidamente em listagem de catálogo pra outras pessoas do time.

Pontos técnicos:

- Criação via `CREATE TEMPORARY TABLE` / `CREATE TEMP TABLE`, com variante `CREATE OR REPLACE TEMPORARY TABLE` pra substituir uma já existente
- Suporta tanto tabela vazia com schema definido quanto tabela criada a partir do resultado de uma consulta
- Escopo de sessão: tabela some quando a sessão termina, com limite máximo absoluto de sete dias de vida
- Fisicamente é uma tabela Delta, armazenada em local interno do Unity Catalog atrelado ao workspace, com mesmo cache e otimização de performance de tabela padrão
- Limpeza é automática via serviço dedicado, sem exigir `DROP TABLE` manual ao final do trabalho

**Minhas considerações:** o ganho de não poluir o catálogo com tabela de vida curta é real, mas o teto de sete dias pode surpreender quem tem sessão de notebook ficando aberta por dia demais, ou pipeline job de longa duração que depende de reaproveitar uma tabela temporária entre execuções separadas, esse tipo de padrão vai continuar exigindo tabela permanente mesmo com a novidade.

Fonte: https://www.databricks.com/blog/introducing-temporary-tables-databricks-sql

#Databricks #DatabricksSQL #AzureDatabricks
