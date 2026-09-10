---
title: "Um modelo de busca que decide sozinho quando vale a pena procurar de novo"
date: 2026-09-10T10:00:00-03:00
draft: true
tags: ["Databricks", "IA", "Mosaic Research", "Busca", "Opinião"]
summary: "A Databricks publicou o Adaptive Instructed-Retriever, um modelo de recuperação treinado com aprendizado por reforço que decide quando vale a pena buscar de novo, entregando qualidade de ponta com até metade da latência."
ShowToc: false
---

Busca em múltiplos passos custuma ser mais precisa e mais lenta. A Mosaic Research da Databricks treinou um modelo que só paga esse custo quando o ganho compensa.

A Databricks apresentou o Adaptive Instructed-Retriever, um modelo de recuperação que combina a velocidade da busca paralela com a qualidade da busca sequencial, mantendo limite estrito de custo e latência. O modelo é treinado com aprendizado por reforço online usando CISPO (Clipped Importance Sampling Policy Optimization), com uma recompensa que pesa qualidade da trajetória contra custo de busca: o modelo é recompensado por trajetória de alta performance e penalizado por passo de busca extra que não traz ganho correspondente de resultado.

Pontos técnicos que valem atenção:
- Decide em tempo real se um passo de busca adicional compensa, em vez de sempre buscar o número fixo de vezes
- Ajustar o peso da penalidade durante o treino gera diferentes checkpoints posicionados ao longo de uma fronteira entre qualidade e latência
- Isso permite escolher o ponto de operação certo por carga de trabalho: priorizar velocidade em uso interativo ou qualidade em recuperação offline complexa
- A promessa divulgada é qualidade de ponta com até metade da latência frente a modelos concorrentes

**Minha ressalva:** "decidir quando buscar de novo" é exatamente o tipo de comportamento que parece ótimo no benchmark e se comporta de um jeito diferente em produção, onde a distribuição de pergunta muda com o tempo. Antes de trocar um pipeline de busca sequencial fixo por esse modelo adaptativo, vale medir a variância da latência p99 na sua carga real, não só a média, porque um modelo que decide dinamicamente quantos passos dar também introduz variabilidade dinâmica no tempo de resposta.

**Fonte:** https://www.databricks.com/blog/adaptive-instructed-retriever-frontier-quality-search-2x-lower-latency

#Databricks #IA #MosaicResearch
