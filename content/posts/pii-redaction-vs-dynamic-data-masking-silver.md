---
title: "Redação de PII na Silver não elimina o dado sensível, só muda onde ele mora"
date: 2026-09-29T08:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Data Governance", "PII"]
summary: "O Databricks MVP Gary Nakanelua rodou um benchmark comparando redação permanente de PII na camada Silver contra Dynamic Data Masking via Unity Catalog, e mediu custo de escrita, leitura e reversão em cada abordagem."
ShowToc: false
---

Redigir o CPF na Silver parece resolver o problema de privacidade, até alguém perguntar como recuperar aquele dado para uma investigação de fraude.

O Databricks MVP Gary Nakanelua pegou um debate recorrente no fórum da comunidade Databricks, redigir ou mascarar PII na Silver, e transformou isso em benchmark. De um lado, redação permanente, apagar ou hashear o dado sensível direto na Silver. Do outro, manter o PII intacto na Silver e aplicar Dynamic Data Masking via column mask do Unity Catalog só na hora da leitura, na Gold ou em uma view. A recomendação oficial da Databricks é a segunda opção, e ele quis colocar número nisso.

A partir de uma tabela Bronze sintética com 100 mil clientes, cada um com SSN e e-mail, ele construiu as duas versões da Silver no Databricks Free Edition. O custo de escrita foi praticamente igual nos dois casos, cerca de 2,1 segundos. Mas a Silver mascarada ficou 75% maior em tamanho, e um scan completo nela levou 812 ms contra 636 ms na Silver redigida. A diferença que mais importa aparece quando alguém precisa trazer o SSN de volta: na versão redigida isso significa reconstruir as 100 mil linhas do zero, enquanto na versão mascarada basta uma mudança de grupo de acesso, sem reescrever uma única linha.

Pontos técnicos do experimento:

- Escrever a Silver custou o mesmo nos dois padrões, cerca de 2,1 segundos para 100 mil linhas
- A Silver com Dynamic Data Masking ficou 75% maior em disco que a versão com redação permanente
- Um scan completo levou 812 ms na versão mascarada contra 636 ms na redigida
- Recuperar o SSN redigido exige reescrever as 100 mil linhas; na versão mascarada, uma mudança de grupo resolve sem reescrever nada
- Em ambos os padrões, a Bronze continuou devolvendo o SSN real até receber a mesma máscara

**Minha leitura:** o benchmark explica por que a Databricks recomenda manter o PII na Silver atrás de column mask em vez de redigir de forma permanente: redação parece mais seguro, mas na prática só move o dado sensível pra Bronze e troca um problema de governança reversível por um de rebuild caro. Vale revisar pipeline que hoje redige PII cedo demais achando que isso resolve compliance, porque pode estar só escondendo o dado em outra camada.

**Fonte:** https://www.linkedin.com/in/gnakan/#pii-redaction-vs-dynamic-data-masking-silver

#Databricks #UnityCatalog #DataGovernance
