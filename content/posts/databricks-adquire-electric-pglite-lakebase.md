---
title: "Databricks compra a Electric e leva Postgres em WASM pra dentro do sandbox de agente"
date: 2026-08-12T09:30:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Agentes de IA", "Opinião"]
summary: "A Databricks adquiriu a Electric, criadora do PGlite, um Postgres compilado para WebAssembly que roda embutido dentro de sandbox de agente, sincronizado em tempo real com o Lakebase central."
ShowToc: false
---

Rodar um banco Postgres inteiro dentro do sandbox de um agente de IA, sem depender de rede, é a aposta por trás da aquisição da Electric.

A Databricks anunciou a aquisição da Electric, empresa por trás do PGlite, um Postgres compilado para WebAssembly que roda embutido dentro de aplicação ou sandbox, sem precisar de servidor externo. A Electric também mantém um motor de sincronização em tempo real que mantém esse banco embutido consistente com uma fonte central.

A lógica por trás da compra é que agente de IA não se comporta como aplicação tradicional: ele roda em ambiente isolado e efêmero, muitas vezes vários ao mesmo tempo, e precisa de estado rápido e local sem abrir mão de auditoria depois. A arquitetura que a Databricks está montando usa PGlite como banco leve dentro de cada sandbox de agente, cuidando do contexto imediato daquela execução, enquanto o motor de sincronização da Electric espelha continuamente esse estado de volta pro Lakebase central, que vira o repositório durável e governado.

Pontos técnicos que valem registrar:
- PGlite é um Postgres compilado para WASM, e cresceu de 1 milhão para 13 milhões de downloads semanais em 12 meses
- Arquitetura de duas camadas: PGlite local no sandbox do agente, Lakebase central como fonte de verdade durável
- Sincronização contínua entre o banco embutido e o Lakebase, sem a aplicação precisar orquestrar isso manualmente
- Pensado para workflow multiagente, onde cada sandbox precisa de contexto rápido sem esperar round-trip de rede

**Minhas considerações:** aquisição de infraestrutura de banco embutido é um sinal claro de para onde a Databricks está apontando o Lakebase, não só banco operacional pra aplicação, mas peça de infraestrutura pra agente que precisa de estado rápido, descartável e ainda assim auditável depois. Vale acompanhar se essa camada local vai expor as mesmas garantias de governança do Unity Catalog, ou se vira um ponto cego até sincronizar de volta pro Lakebase.

**Fonte:** https://www.databricks.com/blog/electric-joins-databricks-bring-wasm-postgres-ai-agent-sandboxes

#Databricks #Lakebase #AgentesDeIA
