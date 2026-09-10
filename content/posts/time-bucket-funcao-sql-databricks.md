---
title: "Uma função SQL nova pra quando o intervalo de tempo não bate com dia, mês ou ano"
date: 2026-09-09T10:00:00-03:00
draft: true
tags: ["Databricks", "SQL", "Azure Databricks"]
summary: "A função time_bucket chegou ao SQL do Azure Databricks pra alinhar timestamp a um intervalo de largura fixa e origem escolhida, útil quando a janela de tempo não é uma unidade de calendário, como 15 minutos ou 3 meses."
ShowToc: false
---

date_trunc resolve bem hora, dia ou mês. Mas e quando o intervalo que importa é de 15 em 15 minutos, ou de 3 em 3 meses?

O Azure Databricks lançou a função SQL `time_bucket`, que retorna o início do intervalo de largura fixa em que um timestamp cai, alinhado a uma origem escolhida por quem escreve a consulta. A diferença em relação ao já conhecido `date_trunc` é que este último só trabalha com unidade de calendário fixa (hora, dia, mês, ano), enquanto `time_bucket` aceita qualquer largura de intervalo e qualquer ponto de origem, cobrindo caso como bucket de 15 minutos pra série temporal de sensor ou bucket de 3 meses pra relatório trimestral que não segue o calendário fiscal padrão.

Pontos técnicos que valem atenção:
- Substitui `date_trunc` quando a largura do intervalo ou o ponto de início não é uma unidade de calendário
- Aceita origem configurável, então o bucket não precisa começar à meia-noite ou no primeiro dia do mês
- Útil pra agregação de série temporal com granularidade fora do padrão de calendário, como janela de 15 minutos
- Documentado na referência de função da linguagem SQL do Azure Databricks

**Minha ressalva:** função de bucket de tempo parece trivial até você precisar migrar uma consulta que já usava `date_trunc` combinado com aritmética manual de intervalo, tipo dividir minuto por 15 e multiplicar de volta. Vale revisar consulta antiga que faz esse tipo de gambiarra de agregação e trocar por `time_bucket`, não só usar a função nova só em consulta nova daqui pra frente.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#time_bucket-sql-function-aligns-timestamps-to-fixed-width-time-buckets

#Databricks #SQL #AzureDatabricks
