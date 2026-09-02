---
title: "Rotear pergunta ambígua pra um modelo de reasoning não compensou, e os números provam"
date: 2026-06-02T09:00:00-03:00
draft: false
tags: ["Databricks", "FoundationModelAPIs", "FinOps", "Opinião"]
summary: "Um experimento comparando modelo base e modelo de reasoning em três níveis de complexidade nas Foundation Model APIs do Databricks mostrou que reasoning só compensa em tarefa de lógica multi-etapa, não em classificação ambígua."
ShowToc: false
---

A hipótese mais óbvia sobre quando usar um modelo de reasoning acabou não se sustentando quando testada com número real.

O Databricks MVP Gary Nakanelua partiu de uma pergunta prática que aparece cada vez mais em time usando Databricks: quais tarefas realmente justificam rotear pra um modelo de reasoning em vez de um modelo base mais barato? A hipótese de partida era que reasoning compensaria em tarefa de classificação ambígua, porque "raciocinar melhor" pareceria ajudar justamente onde o sinal é misto. Os dados mataram essa hipótese.

O teste rodou databricks-gpt-oss-120b com reasoning_effort alto contra databricks-meta-llama-3-3-70b-instruct em três níveis de complexidade (extração estruturada simples, aritmética multi-etapa, classificação de sinal misto), cinco itens por tarefa, nas Foundation Model APIs do Databricks. Onde reasoning realmente valeu a pena foi só na aritmética multi-etapa: o modelo base acertou 2 de 5 com respostas erradas e confiantes, contra 5 de 5 do modelo de reasoning. Já na classificação de sinal misto, o modelo base rotulou em 2 tokens e o modelo de reasoning gastou 110 tokens pro mesmo resultado, sem ganho de qualidade que justificasse o custo.

O que vale reter do experimento:
- Reasoning compensa em tarefa com lógica multi-etapa ou aritmética, onde o modelo base erra com confiança
- Classificação baseada em rubrica bem definida não precisa de reasoning, um modelo base instruído já resolve em poucos tokens
- O critério certo de roteamento não é "quão ambígua parece a tarefa", é "quantas etapas de lógica ela exige"

**Minhas considerações:** esse é o tipo de experimento barato (poucos minutos, poucas dezenas de chamadas) que qualquer time rodando Foundation Model APIs no Databricks deveria replicar antes de decidir uma política de roteamento por padrão. É fácil assumir que "mais raciocínio" ajuda em qualquer cenário confuso, mas o dado aqui sugere o oposto: gastar reasoning em tarefa que não exige lógica multi-etapa é desperdício de token sem ganho de acerto.

**Fonte:** https://www.linkedin.com/in/gnakan/

#Databricks #FoundationModelAPIs #FinOps
