---
title: "OpenSharing agora compartilha tabela Iceberg e schema inteiro vindo de fonte externa via federação"
date: 2026-09-13T08:00:00-03:00
draft: false
tags: ["Databricks", "OpenSharing", "Delta Lake", "Opinião"]
summary: "Duas novidades GA no OpenSharing: compartilhar tabela Iceberg federada de catálogo externo via Lakehouse Federation, inclusive pra cliente Iceberg de fora do Databricks, sem copiar dado; e compartilhar schema ou tabela inteira federada de fonte externa, essa última materializando o dado do lado do provedor e gerando custo extra de compute e armazenamento."
ShowToc: false
---

A Databricks tornou GA duas extensões do OpenSharing que ampliam o alcance de quem já usa Lakehouse Federation pra unificar acesso a dado espalhado fora do Databricks.

A primeira permite compartilhar tabela Iceberg federada de um catálogo Iceberg externo através do OpenSharing, incluindo pra quem consome usando um cliente Iceberg de fora do ecossistema Databricks, sem precisar copiar o dado pra dentro da plataforma antes de compartilhar. A segunda vai além: permite compartilhar schema inteiro ou tabela federada vinda de fonte de dado externa qualquer via Lakehouse Federation, não só Iceberg, mas aqui existe uma diferença importante de custo, porque compartilhar schema ou tabela externa dessa forma materializa o dado do lado do provedor, o que gera custo de compute e armazenamento que o compartilhamento de tabela Iceberg federada normalmente não exige.

Na prática, isso amplia o OpenSharing de "compartilhar o que já está nativamente no Unity Catalog" pra "compartilhar o que está federado de fora", incluindo banco relacional e outro data warehouse acessado via Lakehouse Federation, sem forçar uma ingestão completa antes.

Pontos técnicos:

- Compartilhamento de tabela Iceberg federada de catálogo Iceberg externo via OpenSharing, GA, sem cópia de dado, compatível com cliente Iceberg externo ao Databricks
- Compartilhamento de schema ou tabela federada de fonte externa qualquer via Lakehouse Federation, GA, mas com materialização do dado do lado do provedor
- Materialização de schema/tabela externa compartilhada gera custo adicional de compute e armazenamento, ao contrário do caminho de tabela Iceberg federada
- Ambos os recursos dependem de a fonte já estar configurada via Lakehouse Federation antes de poder ser incluída num share

**Minha ressalva:** a diferença de custo entre os dois caminhos, um sem materialização e outro que materializa do lado do provedor, é o tipo de detalhe que pode passar despercebido até a fatura de compute chegar maior que o esperado. Antes de expor schema externo inteiro via OpenSharing pra múltiplos recipientes, vale simular o volume de dado envolvido e entender que aquele compartilhamento específico não é gratuito do jeito que compartilhar uma tabela Unity Catalog nativa costuma ser.

Fonte: https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#sharing-foreign-iceberg-tables-with-opensharing-is-now-generally-available

#Databricks #OpenSharing #AzureDatabricks
