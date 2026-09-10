---
title: "Environment version 6 chegou, e ele confirma que o Databricks Runtime 19 já existe"
date: 2026-09-04T09:00:00-03:00
draft: true
tags: ["Databricks", "Serverless", "Databricks Runtime", "Azure Databricks"]
summary: "A versão 6 do ambiente serverless e de compute clássico standard já está disponível no Azure Databricks, e ela é a primeira confirmação pública de que o Databricks Runtime 19 já está em campo, sucessor do Runtime 18 LTS."
ShowToc: false
---

Uma nova versão de ambiente que parece atualização de rotina, mas esconde a confirmação de que o Runtime saltou de versão.

O Azure Databricks liberou a environment version 6 como base de ambiente pra compute serverless e standard clássico. O Databricks MVP Hubert Dudek notou o detalhe que passa despercebido na nota de release: essa nova versão de ambiente é o primeiro sinal público de que o Databricks Runtime 19 já está disponível, sucessor do Runtime 18 que virou LTS há pouco tempo. A confirmação aparece de forma indireta em outra nota de release da mesma leva, que já lista Runtime 19 LTS como requisito mínimo pra um recurso novo de change data feed automático.

Pontos técnicos que valem atenção:
- Environment version 6 pode ser selecionada como base de ambiente pra serverless e pra compute standard clássico
- É a primeira aparição pública do Databricks Runtime 19 num requisito de outro recurso já documentado
- Vem pouco tempo depois do Runtime 18 ter virado LTS, com unificação de release notes sem mais versão menor pra decorar
- Ainda não há nota de release dedicada exclusivamente ao Runtime 19 detalhando o que muda de fato em relação ao 18

**Minha ressalva:** confirmar a existência de uma versão de Runtime só por citação indireta em outra nota de release é o tipo de sinal que vale acompanhar de perto, mas não vale migrar workload de produção baseado nisso ainda. Esperar a nota de release dedicada ao Runtime 19, com lista completa de mudança e quebra de compatibilidade, é mais prudente do que assumir que "novo environment version" significa "pronto pra promoção ampla".

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#environment-version-6-is-now-available

#Databricks #Serverless #AzureDatabricks
