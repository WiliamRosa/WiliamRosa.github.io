---
title: "GPU chegou ao compute serverless do Databricks com o AI Runtime"
date: 2026-03-20T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "AI Runtime", "GPU", "Machine Learning", "Opinião"]
summary: "AI Runtime traz suporte a GPU pro serverless em preview público, pra tarefas single-node, a promessa é treinar sem gerenciar cluster, mas ainda com pé atrás no treinamento distribuído."
ShowToc: false
---

O AI Runtime entrou em preview público trazendo suporte a GPU pro compute serverless do Databricks, mas, por enquanto, só pra tarefas single-node. A API de treinamento distribuído multi-GPU segue em beta, um degrau atrás.

Isso é significativo porque GPU serverless remove uma fricção histórica de quem faz deep learning no Databricks: gerenciar cluster com GPU manualmente, escolher tipo de instância, lidar com fila de provisionamento. Serverless promete abstrair tudo isso, você só pede compute com GPU e o Databricks resolve o resto.

Por que vale ficar de olho nesse rollout gradual:
- Single-node já cobre boa parte de fine-tuning e inferência que hoje é feita "artesanalmente" em cluster dedicado
- Separar GPU serverless single-node (preview) de multi-GPU distribuído (beta) é sinal de que a Databricks está sendo conservadora exatamente na parte mais difícil de acertar
- Menos gerenciamento de infraestrutura de GPU significa menos motivo pra time de ML manter conhecimento profundo de configuração de cluster

**Minha ressalva:** preview público de GPU serverless costuma vir com fila de disponibilidade e variação de custo que só aparecem quando o volume de uso sobe. Antes de migrar workload de treinamento crítico pra cá, eu testaria com carga real e acompanharia custo por algumas semanas, não só o cenário de demonstração.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/march

#AzureDatabricks #AIRuntime #MachineLearning
