---
title: "Testei o juiz de correção do MLflow e um 'ou' a menos virou a diferença entre passar e reprovar"
date: 2026-09-14T09:00:00-03:00
draft: true
tags: ["Databricks", "MLflow", "Avaliação de Agentes", "Foundation Model APIs"]
summary: "O Databricks MVP Gary Nakanelua testou o juiz de correção do MLflow contra duas Foundation Model APIs e descobriu que remover uma única palavra de um fato esperado, sem mudar a resposta do modelo, foi suficiente pra virar o veredito de reprovado pra aprovado."
ShowToc: false
---

Trocar uma palavra num fato esperado, sem mudar a resposta do modelo, foi o suficiente pra fazer a mesma linha do dataset dourado passar de reprovada pra aprovada.

O Databricks MVP Gary Nakanelua pegou o padrão de avaliação em dois loops que a Databricks descreveu no case da Zepto, um loop de desenvolvimento e um de produção ligados por um portão de qualidade, e rodou dois endpoints das Foundation Model APIs contra ele. O objetivo era simples: testar se um dataset dourado próprio passava de um limiar de 80% de acurácia. Os modelos não foram o problema, o dataset foi.

O juiz de correção do MLflow exige que toda entrada listada em `expected_facts` esteja presente na resposta, sem crédito parcial. Linhas carregando três fatos esperados passaram só duas vezes em sessenta tentativas ao longo de cinco execuções; linhas com dois fatos passaram pouco mais da metade das vezes. Pra isolar a causa, ele congelou uma resposta e não mudou nada nela, só editou o texto de um fato esperado, apagando a palavra "ou". Isso bastou pra virar aquela linha de reprovada pra aprovada, com a resposta do modelo idêntica em ambos os casos.

Pontos técnicos do experimento:

- O juiz não dá crédito parcial: falhar em um único fato listado reprova a linha inteira
- Ao longo de cinco execuções, os dois modelos testados trocaram de posição entre si, um sinal de que aquele ranking específico era ruído, não diferença real de qualidade
- A lista de fatos esperados, não o modelo avaliado, foi a variável que mais influenciou o resultado
- O teste inteiro roda no Databricks Free Edition em cerca de 90 segundos, com notebook publicado pra qualquer um reproduzir no próprio workspace
- A conclusão prática: ser estrito e literal é o comportamento certo pra um portão de qualidade, mas isso exige tratar o limiar de aprovação e a redação do fato esperado como uma coisa só, não duas

**Minha ressalva:** esse achado é um lembrete incômodo de que boa parte do trabalho de avaliação de agente de IA está em escrever bem o dataset dourado, não só em escolher o modelo certo ou ajustar o prompt. Qualquer número de acurácia publicado por aí, incluindo os que a própria Databricks divulga em case de cliente, merece a pergunta: quem escreveu os fatos esperados, e quão sensível o resultado é à forma exata dessa redação.

**Fonte:** https://www.linkedin.com/in/gnakan/#mlflow-juiz-correcao-golden-dataset

#Databricks #MLflow #AvaliacaoDeAgentes
