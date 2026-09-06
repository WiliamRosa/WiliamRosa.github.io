---
title: "Skill ou app no Databricks: quando cada um vale a pena pra relatório"
date: 2026-09-05T09:00:00-03:00
draft: false
tags: ["Databricks", "Databricks Apps", "Omnigent", "Opinião"]
summary: "O Databricks MVP Domonkos Pal publicou um guia prático sobre quando um skill de agente basta pra gerar relatório e quando vale migrar pra um Databricks App, com skill e app compartilhando a mesma camada de governança."
ShowToc: false
---

Nem todo relatório precisa virar um app, mas trocar esse momento de decisão dá pra errar caro dos dois lados.

O Databricks MVP Domonkos Pal publicou um comparativo prático entre usar uma skill de agente ou construir um Databricks App quando o objetivo é gerar relatório, e o ponto central dele não é qual tecnologia é melhor, é em que momento faz sentido migrar de uma pra outra.

A régua que ele propõe é direta: uma skill resolve bem experimento rápido, com poucos usuários e revisão humana obrigatória a cada rodada. Já o app entra em cena quando o número de usuários cresce, o relatório passa a ser recorrente e o resultado começa a influenciar decisão crítica que exige aprovação formal antes de valer. O detalhe que sustenta essa migração sem dor é que skill e app não vivem em mundos separados, os dois herdam a mesma camada de governança do Databricks, então trocar de um pro outro é graduar dentro da mesma camada semântica versionada, não reconstruir do zero.

Pontos técnicos que valem atenção:
- Skill: setup rápido, poucos usuários, revisão humana obrigatória em cada execução
- App: usuários em crescimento, relatório recorrente, saída que impacta decisão crítica e precisa de sign-off
- Skill e app compartilham a mesma governança no Databricks: Unity Catalog, Unity AI Gateway e Omnigent
- Ele publicou um repositório de skill builder que deixa criar uma skill de relatório simples e depois graduar ela pra app sem reescrever a camada semântica

**Minhas considerações:** o critério que mais me chamou atenção não foi usuário nem recorrência, foi o "sign-off formal". No fim das contas, o que decide entre skill e app é quem assume a responsabilidade pelo resultado, não a tecnologia usada pra gerar ele. É uma régua que serve pra qualquer decisão de arquitetura de agente, não só relatório.

**Fonte:** https://medium.com/databrickscommunity/skills-for-speed-and-learning-apps-for-trust-and-scale-924de1ee24db

#Databricks #DatabricksApps #Omnigent
