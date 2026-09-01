---
title: "Um job falhou às 3h da manhã? Agora dá pra reabrir a sessão sem rodar tudo de novo"
date: 2026-08-18T09:15:00-03:00
draft: false
tags: ["Azure Databricks", "Serverless", "Jobs", "Opinião"]
summary: "Session Restore recupera variáveis Python e sessão Spark de um job serverless que falhou, direto num notebook interativo — sem precisar reprocessar tudo pra investigar."
ShowToc: false
---

❗ Azure Databricks agora consegue restaurar, num notebook interativo novo, as variáveis Python e a sessão Spark de um job serverless que falhou, rodou 30 minutos ou mais, ou foi cancelado. O snapshot de estado é capturado automaticamente e fica disponível por 7 dias após o run terminar.

Quem já debugou falha de job em produção conhece o ciclo frustrante: job falha de madrugada, você chega de manhã, e pra investigar direito precisa reprocessar o pipeline inteiro só pra chegar no mesmo estado que causou o problema — gastando tempo e compute só pra reproduzir o contexto.

Por que isso muda o dia a dia de quem sustenta pipeline em produção:
- Debug vira "abrir o snapshot e inspecionar", não "reprocessar e torcer pra reproduzir"
- Reduz o custo de investigação de falhas intermitentes, que são justamente as mais caras de reproduzir manualmente
- Captura automática significa que ninguém precisa lembrar de configurar isso antes da falha acontecer

❗ Minha ressalva: um snapshot de estado guardado por 7 dias é, por definição, uma cópia de dado que estava em memória no momento da falha — inclusive dado sensível que talvez nunca devesse ficar persistido nem temporariamente. Vale entender exatamente o que esse snapshot guarda antes de habilitar em workspace com dado regulado.

🔗 Fonte: https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/august

#AzureDatabricks #Serverless #DataEngineering
