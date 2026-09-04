---
title: "Metric Views agora atravessam metastore diferente via OpenSharing"
date: 2026-09-04T09:00:00-03:00
draft: false
tags: ["Databricks", "Metric Views", "OpenSharing", "Azure Databricks", "Opinião"]
summary: "O Azure Databricks liberou em beta o compartilhamento de metric views via OpenSharing: quem recebe o share consulta a definição de métrica compartilhada com a função MEASURE(), sem reimplementar a lógica de negócio."
ShowToc: false
---

A métrica de negócio definida numa metric view do Unity Catalog agora pode ser compartilhada com outro metastore ou outra conta, não só consumida dentro de casa.

O Azure Databricks liberou em beta o compartilhamento de metric views via OpenSharing, o protocolo aberto que sucedeu o Delta Sharing. Antes, metric view era um recurso preso ao Unity Catalog de quem criou ela; agora dá pra empacotar essa definição de métrica dentro de um share e distribuir pra usuário de outro metastore ou de outra conta do Azure Databricks.

O ponto central é que o que atravessa a fronteira não é só o dado agregado, é a própria definição semântica: dimensão, medida e a lógica de cálculo por trás da métrica. Quem recebe o share lê a metric view compartilhada e consulta ela com a função MEASURE(), do mesmo jeito que consultaria uma metric view local, sem reimplementar a lógica de negócio na outra ponta.

Pontos técnicos que valem registrar:
- Beta no Azure Databricks a partir de 3 de setembro de 2026
- Compartilha a definição da metric view, não só um snapshot do dado agregado
- Quem recebe consulta a métrica compartilhada com a mesma função MEASURE() usada em metric view local
- Complementa o rebranding recente do Delta Sharing para OpenSharing como protocolo de distribuição de dado entre metastores e contas

**Minha ressalva:** compartilhar a definição de uma métrica de negócio entre organizações diferentes é mais delicado do que compartilhar uma tabela. Duas empresas raramente concordam sobre o que significa "receita líquida" ou "usuário ativo" da mesma forma, então receber a metric view de outra conta não garante que a métrica calculada vá bater com a definição interna de quem recebe. Vale tratar a metric view recebida via OpenSharing como ponto de partida pra alinhamento, não como fonte de verdade automática.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#share-metric-views-with-opensharing-beta

#Databricks #MetricViews #OpenSharing
