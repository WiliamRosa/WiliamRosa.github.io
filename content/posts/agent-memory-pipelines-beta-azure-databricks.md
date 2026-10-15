---
title: "Agentes no Azure Databricks ganharam memória de longo prazo, destilada por um LLM a cada 24 horas"
date: 2026-10-14T12:00:00-03:00
draft: false
tags: ["Azure Databricks", "Agentes de IA", "LLM"]
summary: "Agent memory pipelines, em Beta, conectam um session store a um memory store e usam um LLM para destilar fato, preferência e decisão de conversas passadas em entradas de memória que o agente recupera depois, rodando sob demanda ou a cada 24 horas."
ShowToc: false
---

Um agente de IA no Azure Databricks agora pode lembrar de uma conversa de semana passada sem que ninguém tenha salvo isso manualmente em lugar nenhum.

Agent memory pipelines, lançado em Beta, resolve um problema bem concreto de agente conversacional: cada sessão de chat normalmente morre sozinha, e qualquer preferência ou decisão que o usuário comunicou ali se perde na próxima conversa. O mecanismo conecta um session store, onde ficam as conversas brutas, a um memory store separado. A cada execução do pipeline, seja sob demanda ou numa recorrência de aproximadamente 24 horas, um LLM lê as conversas acumuladas e destila delas fato, preferência e decisão durável, gravando isso como entrada de memória que o próprio agente consulta em conversas futuras. Na prática, é uma camada de resumo e curadoria automática entre a conversa crua e o que realmente vale persistir.

Esse desenho separa dois problemas que normalmente ficam misturados em implementação caseira de memória de agente: o que guardar (uma inferência de LLM, sujeita a erro de interpretação) e onde e quando persistir isso (um pipeline com cadência previsível, não um processo acoplado a cada chamada de inferência). Isso também significa que a qualidade da memória do agente depende diretamente da qualidade do LLM usado pra destilar, e que existe uma defasagem inerente de até 24 horas entre o que o usuário disse e o que o agente efetivamente vai "lembrar" na próxima conversa, caso o pipeline não seja disparado manualmente.

Pontos técnicos da feature:

- Arquitetura de duas peças: session store (conversa bruta) alimentando um memory store (fato, preferência, decisão já destilados).
- Destilação feita por um LLM a cada execução do pipeline, não por regra determinística.
- Cadência configurável: sob demanda ou recorrência de aproximadamente 24 horas.
- Memória recuperada pelo próprio agente em conversas futuras, fechando o ciclo sem intervenção manual.
- Recurso em Beta no Azure Databricks.

**Minha ressalva:** memória destilada por LLM é também memória sujeita a alucinação do próprio LLM, um "fato" mal interpretado numa conversa pode virar entrada permanente que o agente trata como verdade em toda interação seguinte, sem o tipo de revisão humana que normalmente se aplicaria a dado persistido sobre usuário. Some a isso a defasagem de até 24 horas no modo de cadência padrão, e um agente pode estar agindo sobre preferência já desatualizada num cenário que muda rápido. Antes de ligar isso em produção, eu quereria entender exatamente que governança o Unity Catalog aplica sobre esse memory store, porque memória de agente sobre usuário real é dado sensível por definição, e o anúncio não detalha isso.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/october#agent-memory-pipelines-are-in-beta

#AzureDatabricks #AgentesDeIA #LLM
