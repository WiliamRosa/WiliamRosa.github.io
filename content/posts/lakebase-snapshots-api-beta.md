---
title: "Snapshot de branch do Lakebase agora se cria, lista e restaura por API, sem passar pela UI"
date: 2026-09-16T07:15:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Postgres", "Azure Databricks"]
summary: "A Lakebase snapshots API, em beta, permite criar, listar e apagar snapshots pontuais de um branch de projeto Lakebase, e restaurar um snapshot criando um branch novo a partir dele, tudo de forma programática."
ShowToc: false
---

Gerenciar snapshot de branch do Lakebase até agora significava passar pela interface, o que não combina bem com automação de pipeline ou CI/CD.

A Databricks lançou a Lakebase snapshots API, em beta, permitindo gerenciar snapshots pontuais de um branch programaticamente. A API cobre o ciclo básico: criar um snapshot de um branch de projeto num determinado momento, consultar e listar os snapshots existentes, apagar os que não são mais necessários, e restaurar um snapshot criando um branch novo a partir dele.

O ganho prático é integrar snapshot de banco a fluxo de automação existente, seja pra checkpoint antes de uma migração arriscada, seja pra criar ambiente de teste reprodutível a partir de um estado conhecido, sem depender de alguém clicar na UI no momento certo.

Pontos técnicos:
- Operações disponíveis: criar, obter, listar e apagar snapshot de um branch
- Restaurar um snapshot cria um branch novo a partir dele, em vez de sobrescrever o branch original
- Recurso está em beta

**Minhas considerações:** dado que Lakebase já se apoia em branch com cópia zero como diferencial de arquitetura, expor snapshot via API é o passo natural pra quem quer tratar banco operacional como parte de pipeline versionado, no estilo de infraestrutura como código. Fico com a dúvida de como fica o custo de armazenamento conforme o número de snapshots cresce ao longo do tempo, algo que normalmente só fica claro quando o recurso sai do beta e a política de retenção é documentada com mais detalhe.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/snapshots

#Databricks #Lakebase #Postgres
