---
title: "40 indústrias, 80 modelos de dado prontos: a Databricks publicou um ponto de partida pra quem não quer desenhar schema do zero"
date: 2026-09-03T10:30:00-03:00
draft: true
tags: ["Databricks", "Modelagem de Dados", "Unity Catalog", "Opinião"]
summary: "O Databricks MVP Derar Alhussein resgatou os Industry Data Models, biblioteca com modelo de dado de referência pra mais de 40 indústrias, gerada por um agente de modelagem e pensada pra virar a camada Silver do seu Lakehouse."
ShowToc: false
---

O Databricks MVP Derar Alhussein chamou atenção pra um recurso que resolve um problema chato e recorrente: começar a modelar dado de um domínio de negócio do zero, sem nenhuma referência.

Os Industry Data Models são uma biblioteca de modelo de dado pronto pra mais de 40 indústrias, publicada num repositório de referência da Databricks. Cada indústria sai em duas versões, um modelo conceitual mais enxuto (MVM) e um modelo corporativo mais completo (ECM), cobrindo entidade central, relacionamento, convenção de nome e padrão específico do domínio. A escala chama atenção: ao todo são 80 modelos somando as duas versões, mais de 23 mil tabelas, quase 900 mil atributos, mais de 150 mil chave estrangeira e mais de 11 mil metric view já definida. Cada modelo segue um conjunto de mais de 200 regras estruturais distribuídas em 14 domínio de modelagem diferente, o que dá uma base consistente entre indústrias, e foi gerado pelo agente Vibe Data Modeling em vez de desenhado manualmente indústria por indústria.

A proposta não é usar isso engessado. A Databricks recomenda tratar como camada Silver inicial, adaptável ao vocabulário e à regra específica de cada organização, com repositório incluindo notebook, orquestrador, harness de teste e guia de integração e qualidade.

Pontos técnicos que valem atenção:
- Mais de 40 indústrias, cada uma em duas versões, MVM (mais simples) e ECM (mais completo)
- 80 modelos ao todo, mais de 23 mil tabelas e mais de 11 mil metric view já mapeada
- Ruleset de mais de 200 regras em 14 domínio de modelagem garante consistência estrutural entre indústrias
- Gerado pelo agente Vibe Data Modeling, não desenhado manualmente modelo por modelo
- Pensado como ponto de partida pra camada Silver, customizável, não como modelo final fixo

**Minha ressalva:** modelo gerado por agente em escala de 80 modelos e quase 900 mil atributos é difícil de auditar um por um antes de adotar. "Produção-grade desde o dia zero" é a promessa, mas a responsabilidade de validar se a regra de 14 domínios realmente reflete a realidade regulatória e de negócio da sua indústria específica continua sendo sua, não do agente que gerou o modelo. Vale tratar como acelerador de rascunho, não como modelo pronto pra rodar sem revisão de arquiteto de dado humano.

**Fonte:** https://www.databricks.com/blog/jumpstart-your-data-modeling-databricks-industry-data-models

#Databricks #ModelagemDeDados #UnityCatalog
