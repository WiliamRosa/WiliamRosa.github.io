---
title: "Uma extensão de navegador mostra o custo em dólar antes de você criar o cluster"
date: 2026-09-22T09:00:00-03:00
draft: false
tags: ["Databricks", "FinOps", "Azure Databricks"]
summary: "O Databricks MVP Maksim Pachkouski lançou o FinOpsWay, uma extensão gratuita de navegador que injeta custo em tempo real dentro da própria interface do Azure Databricks, mostrando gasto por SKU, cluster, job e SQL warehouse sem precisar abrir dashboard de billing separado."
ShowToc: false
---

Configurar um SQL warehouse e ver o custo em dólar aparecer ao lado do tamanho escolhido, em vez de descobrir o valor só na fatura do mês seguinte, virou possível com uma extensão de navegador gratuita.

O Databricks MVP Maksim Pachkouski, junto com Ilya Aniskovets, lançou o FinOpsWay: uma extensão para Chrome, Edge e Firefox que injeta informação de custo direto na interface do Azure Databricks, no mesmo lugar onde o engenheiro toma a decisão, sem exigir abrir outra aba nem consultar dashboard de billing separado. A ideia central é encurtar a distância entre a decisão técnica (que tamanho de cluster escolher, se vale a pena rodar aquele job de novo) e a visibilidade do custo que essa decisão gera.

A extensão roda inteiramente no navegador, sem backend nem telemetria: ela lê as próprias tabelas de sistema do workspace conectado e injeta um badge de custo que muda de acordo com a página, custo do SKU específico ao configurar um SQL warehouse, custo do cluster ao lado dos nós, custo agregado por job, pipeline ou execução individual. Quando o dado de faturamento da nuvem ainda não chegou (o que é normal, já que a fatura tem atraso natural), o badge mostra uma barra tracejada em vez de exibir zero, deixando claro que a informação está incompleta, não ausente.

Pontos técnicos que valem atenção:
- Extensão de navegador (Chrome, Edge, Firefox) sem backend nem coleta de telemetria
- Mostra custo por SKU nas últimas 24 horas, 7 dias, 14 dias ou período customizado
- Injeta badge de custo em cluster, execução de job, job, pipeline e na tela de configuração de novo cluster
- Preço de nuvem já vem embutido na extensão, sem depender de chamada externa à API do provedor de nuvem

**Minhas considerações:** o ponto mais interessante aqui não é a extensão em si, é o que ela revela sobre uma lacuna que a própria interface do Databricks ainda tem. Hoje o workspace mostra número de worker, memória, CPU e minuto de execução, mas não custo, então o engenheiro naturalmente otimiza pra velocidade, não pra gasto. Uma ferramenta de comunidade preenchendo esse vão é útil, mas também é um sinal de que essa visibilidade deveria estar nativa na plataforma, não depender de plugin de terceiro mantido de graça por dois MVPs.

**Fonte:** https://finopsway.com/

#Databricks #FinOps #AzureDatabricks
