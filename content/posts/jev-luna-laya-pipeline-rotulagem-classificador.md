---
title: "Rotular com Jev, revisar com Luna, treinar Laya: o circuito completo de rotulagem ficou mais barato"
date: 2026-09-27T15:00:00-03:00
draft: false
tags: ["Databricks", "TypeSafe AI", "Data Labeling", "Machine Learning"]
summary: "O Databricks MVP Casper Lubbers fechou o ciclo completo de rotulagem e classificação usando Jev para rotular em massa, Luna para revisão em lote e Laya para treinar um classificador open source, gastando cerca de 100 dólares no processo."
ShowToc: false
---

Rotular um volume grande de dado costumava significar escolher entre gastar uma fortuna com um LLM genérico ou aceitar rótulos de qualidade inconsistente. O ciclo completo virou questão de cem dólares e uma noite de processamento.

O Databricks MVP Casper Lubbers testou o circuito que formou em volta do lançamento do Jev, da TypeSafe AI: rotular os dados em massa com Jev, revisar parte das rotulagens em lote com Luna, e usar esse dataset já curado para treinar Laya, um classificador open source. Ele descreveu o resultado como o ciclo completo de rotulagem e classificação fechando sozinho, e montou o pipeline inteiro usando Astra numa única execução noturna.

Os números que ele compartilhou dão a dimensão do ganho: cerca de 100 dólares gastos rotulando um volume grande de dados com Jev foi suficiente para gerar datasets que permitiram fazer fine-tuning do Laya, open source, com resultado funcional. Em produção, ele reporta conseguir processar cerca de 60 requisições por segundo contra o Laya numa máquina M5 de 128gb, mantendo a máquina livre para outras tarefas, com acurácia equivalente ou superior à do próprio Jev em algumas partes do problema.

Pontos técnicos do experimento:

- Pipeline de três etapas: rotulagem em massa com Jev, revisão em lote com Luna, treino do classificador Laya
- Custo total de aproximadamente 100 dólares para gerar o dataset de rotulagem
- O pipeline completo foi montado com Astra e executado numa única rodada noturna
- Laya, já treinado, sustenta cerca de 60 requisições por segundo numa máquina M5 de 128gb
- Acurácia do Laya ficou equivalente ou superior à do Jev em partes do problema, segundo o teste

**Minha leitura:** o que chama atenção aqui não é só o custo baixo, é o padrão arquitetural: usar um modelo caro e rápido só na etapa de geração de dataset, e distilar esse conhecimento para um modelo open source que sustenta o volume de produção sem depender de chamada de API a cada requisição. É o tipo de pipeline que vale revisar antes de assumir que todo problema de classificação em volume precisa de LLM rodando a cada chamada.

**Fonte:** https://www.linkedin.com/in/casper-lubbers/#jev-luna-laya-pipeline-rotulagem-classificador

#Databricks #MachineLearning #DataLabeling
