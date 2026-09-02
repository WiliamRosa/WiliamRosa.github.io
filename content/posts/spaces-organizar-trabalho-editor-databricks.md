---
title: "Spaces chega ao editor do Databricks pra resolver o problema da aba que some"
date: 2026-08-04T09:00:00-03:00
draft: false
tags: ["Databricks", "Produtividade", "Opinião"]
summary: "A nova feature Spaces deixa organizar abas abertas por pasta ou projeto no editor do Databricks, então dá pra alternar entre um pipeline e um bundle sem perder o contexto de cada um. O Databricks MVP Ajay Kumar Pandey notou a chegada."
ShowToc: false
---

O Databricks MVP Ajay Kumar Pandey chamou atenção para uma mudança pequena no editor do Databricks que resolve um incômodo bem concreto de quem trabalha em mais de um projeto ao mesmo tempo: a chegada de Spaces.

O mecanismo é direto. Antes, todo mundo que já trabalhou num workspace do Databricks por um tempo conhece a sensação de abrir uma pasta de projeto novo e ver as dez abas do projeto anterior ainda ali, competindo por espaço na tela. Spaces resolve isso deixando você focar numa pasta ou projeto específico enquanto preserva as abas abertas daquele contexto separadamente. Trocar de Space significa trocar de contexto de trabalho inteiro, não só de pasta visível na árvore de arquivos, o que é diferente de simplesmente fechar e reabrir abas manualmente toda vez que muda de tarefa.

Detalhes que fazem diferença no dia a dia:
- Cada Space guarda seu próprio conjunto de abas abertas, então voltar pra um projeto antigo restaura exatamente onde você parou
- Isso ajuda especialmente quem alterna entre notebook interativo, pipeline declarativo e projeto de bundle no mesmo workspace
- É um ajuste de ergonomia, não uma feature com API ou flag de configuração nova para aprender

**Minhas considerações:** é o tipo de feature que não vira manchete de nenhum release notes, mas que economiza minutos reais todo dia, principalmente pra quem faz consultoria e circula entre workspace de clientes diferentes ou entre múltiplos projetos internos na mesma semana. Vale menos como anúncio técnico e mais como lembrete de que produtividade de plataforma de dados também se ganha em detalhe de UX, não só em feature de Genie ou de IA.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/notebooks/spaces

#Databricks #Produtividade
