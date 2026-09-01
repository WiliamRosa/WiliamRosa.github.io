---
title: "Packaged Clean Rooms virou GA, compartilhar lógica sem compartilhar código"
date: 2026-08-01T09:00:00-03:00
draft: true
tags: ["Databricks", "Clean Rooms", "Unity Catalog", "Governança", "Opinião"]
summary: "Diferente do Clean Rooms tradicional (GA desde 2025), o modo 'packaged' permite que um provedor distribua notebooks, JARs e dados prontos, sem o consumidor nunca ver o código ou os dados de origem."
ShowToc: false
---

O Databricks MVP Jaco van Gelder chamou atenção pro Packaged Clean Rooms, que atingiu disponibilidade geral em 31 de julho de 2026, descrevendo o Databricks como um "wrecking ball para silos de dados". É um modo diferente do Clean Rooms tradicional (que já era GA desde fevereiro de 2025): aqui, um provedor empacota notebooks, JARs e dados prontos para uso, e o consumidor roda esse pacote contra os próprios dados dele, sem nunca enxergar o código ou os dados de origem do provedor.

O Clean Rooms tradicional já permitia colaboração segura trazendo dado de fora do Databricks (Synapse, Snowflake, Redshift, BigQuery, desde que governados por Unity Catalog); o modo packaged estende isso pra lógica de processamento também, não só dado.

Por que essa distinção entre os dois modos importa:
- Clean Rooms tradicional resolve "duas partes analisam dado combinado sem uma ver o dado bruto da outra"
- Packaged Clean Rooms resolve um problema diferente: "um fornecedor distribui um produto de análise pronto sem expor propriedade intelectual (o código) nem pedir acesso aos dados de quem consome"
- Isso abre caminho pra um modelo de "produto de dados empacotado", parecido com vender um relatório pronto, mas rodando dentro do ambiente governado do próprio cliente

**Minha ressalva:** empacotar lógica pra rodar no ambiente de terceiros sempre levanta a pergunta inversa de proteção de dados, o provedor consegue auditar o que o consumidor está de fato fazendo com o pacote rodando no ambiente dele? Delta Sharing e Clean Rooms resolvem bem o problema de "não vazar dado bruto", mas a garantia de que o pacote não está sendo mal utilizado do outro lado é uma camada de confiança contratual, não só técnica.

**Fonte:** https://docs.databricks.com/aws/en/release-notes/product/2026/july

#Databricks #CleanRooms #UnityCatalog
