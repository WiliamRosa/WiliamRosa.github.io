---
title: "A partir de 30 de setembro, todo workspace novo do Databricks nasce sem Hive metastore"
date: 2026-08-29T08:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Hive Metastore", "Governança", "Opinião"]
summary: "A partir de 30 de setembro de 2026, todo workspace novo do Databricks nasce sem DBFS root, DBFS mounts, Hive metastore ou cluster sem isolamento, restrito ao Unity Catalog desde o primeiro dia."
ShowToc: false
---

Workspace criado depois de 30 de setembro de 2026 simplesmente não vai ter Hive metastore pra usar, nem que você queira.

A Databricks MVP Dilorom Abdullah alertou pra um prazo concreto que muita equipe ainda trata como opcional: a partir de 30 de setembro de 2026, todo workspace novo do Databricks passa a nascer sem acesso a DBFS root, DBFS mounts, Hive metastore ou cluster compartilhado sem isolamento, ficando restrito ao Unity Catalog desde o primeiro dia.

O risco real não está no workspace que ainda vai ser criado, está no que já existe hoje e depende de Hive metastore sem ninguém perceber. Cluster, notebook, job e metastore externo podem continuar amarrados no Hive metastore legado mesmo depois de uma migração pra Unity Catalog considerada concluída, porque a migração de tabela não garante que toda dependência oculta foi identificada e cortada. Dilorom recomenda tratar isso como decisão de governança, não como tarefa de limpeza: validar dependência antes de desligar acesso legado, em vez de assumir que, se a tabela já está no Unity Catalog, o resto segue automaticamente.

Pontos técnicos que valem registrar:
- A partir de 30 de setembro de 2026, workspace novo nasce Unity-Catalog-only, sem DBFS root, DBFS mounts, Hive metastore nem cluster sem isolamento
- Workspace existente não é afetado automaticamente, mas a direção geral da plataforma já está definida
- Dependência oculta em cluster, notebook, job ou metastore externo pode manter o Hive metastore vivo mesmo após a tabela já estar migrada
- Recomendação prática: validar toda dependência antes de desligar o acesso legado, em vez de confiar só na migração de tabela como sinal de conclusão

**Minha ressalva:** prazo com data fixa tende a ser ignorado até faltar pouco tempo, e migração de metastore raramente é rápida quando aparece dependência escondida que ninguém documentou. Se seu workspace ainda tem qualquer coisa rodando sobre Hive metastore, vale tratar setembro de 2026 como prazo de verdade pra auditar isso agora, não como aviso genérico pra resolver depois.

**Fonte:** https://blog.dataengineerthings.org/the-hive-metastore-era-is-ending-close-it-on-your-terms-434231670b5c

#Databricks #UnityCatalog #Governanca
