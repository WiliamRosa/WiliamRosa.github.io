---
title: "Testar contra banco de verdade, não mock, cada agente com sua própria cópia instantânea do banco"
date: 2026-09-10T11:00:00-03:00
draft: true
tags: ["Databricks", "Lakebase", "Agentes de IA", "DevOps", "Opinião"]
summary: "A Databricks lançou o Consort, um framework agêntico de código aberto que usa branching de banco do Lakebase Postgres pra levar teste de integração de verdade pro loop interno de desenvolvimento, com agentes assumindo papéis como arquiteto, DBA e desenvolvedor."
ShowToc: false
---

Banco de dado nunca teve branch como código tem. Isso forçava todo mundo a testar contra mock ou contra um staging compartilhado que ninguém confia de olhos fechados.

A Databricks, através da equipe de Field Engineering, lançou o Consort, um framework agêntico de código aberto para desenvolvimento orientado a teste usando a capacidade de branching por copy-on-write do Lakebase Postgres. O framework atribui papel de desenvolvimento (dono de produto, arquiteto, DBA, estrategista de teste e par de desenvolvedores) a agentes de IA que colaboram através de um "condutor" determinístico, criando branch isolado de banco em tempo constante em vez de depender de mock que diverge do comportamento real ou de ambiente de staging compartilhado.

Pontos técnicos que valem atenção:
- Opera em duas trilhas: uma trilha de design (especificação congelada antes de codificar) e uma trilha de build (ciclo completo de red-green-refactor contra branch de banco vivo)
- Cada agente recebe um pacote de contexto restrito, só com o teste e requisito relevante pra aquela tarefa
- Experimento roda em paralelo usando Git worktree isolado e branch de banco isolado ao mesmo tempo
- Plugin de VS Code mostra branch de Git e de Lakebase pareados, com diff unificado de código e schema
- O "condutor" impõe barreiras de fluxo determinísticas em vez de deixar a decisão de escopo a critério do agente

**Minhas considerações:** a parte que mais chama atenção não é orquestrar agente, é o branching de banco em tempo constante sustentando teste de integração real dentro do loop interno, algo que sempre foi caro demais pra fazer a cada commit. Ainda assim, vale ceticismo saudável sobre quanto disso é maturidade de produto e quanto é framework early-stage: "condutor determinístico" resolvendo scope creep de agente é uma promessa que só se prova depois de meses rodando em projeto real, não em demo controlada.

**Fonte:** https://www.databricks.com/blog/introducing-consort-test-driven-development-branching-database

#Databricks #Lakebase #AgentesDeIA
