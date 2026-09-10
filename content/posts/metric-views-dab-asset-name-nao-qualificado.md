---
title: "Metric view implantada via bundle em ambiente diferente quebra por causa de um nome qualificado a mais"
date: 2026-09-10T13:00:00-03:00
draft: true
tags: ["Databricks", "Metric Views", "Declarative Automation Bundles", "Opinião"]
summary: "O Databricks MVP Geir E. Alstad identificou uma pegadinha real ao implantar metric views via Declarative Automation Bundles em múltiplos ambientes: o asset_name do dashboard precisa ficar não qualificado no arquivo versionado, ou a implantação em outro ambiente falha."
ShowToc: false
---

Um dashboard que implanta liso em dev e quebra em produção, só porque um nome de asset estava qualificado demais no arquivo errado.

O Databricks MVP Geir E. Alstad notou um detalhe que não fica claro na documentação de metric views ao implantar dashboard e metric view via Declarative Automation Bundles (ex-Databricks Asset Bundles) em mais de um ambiente com Git: o arquivo `.lvdash.json` que fica versionado no repositório precisa manter o `asset_name` sem qualificação de catálogo e schema. É só depois do `bundle deploy`, já dentro do ambiente alvo, que o nome se resolve pra forma totalmente qualificada. Editar o arquivo já qualificado diretamente pelo workspace não é uma prática confiável, porque o processo de implantação espera encontrar a versão não qualificada como ponto de partida.

Pontos técnicos que valem atenção:
- O arquivo `.lvdash.json` versionado no Git deve conter `asset_name` sem catálogo e schema (forma não qualificada)
- A qualificação completa (catálogo.schema.tabela) só acontece depois do `bundle deploy`, no ambiente de destino
- Variável de bundle (como `schema_name`, com valor padrão pra dev e sobrescrita pra produção) resolve a parametrização entre ambiente sem duplicar arquivo
- Editar a versão já qualificada direto pelo workspace quebra o fluxo de implantação subsequente via bundle

**Minha ressalva:** esse é exatamente o tipo de detalhe que só aparece depois de bater a cabeça numa implantação que falhou sem mensagem de erro clara, e a documentação oficial de metric views não deixa isso óbvio pra quem está montando o primeiro pipeline de CI/CD com Git. Vale tratar esse achado como um checklist obrigatório antes de replicar metric view via bundle pra mais de um ambiente, não como detalhe opcional de estilo.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/uc-semantics/metric-views/create

#Databricks #MetricViews #DeclarativeAutomationBundles
