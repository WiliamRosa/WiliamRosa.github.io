---
title: "LangGraph, Claude Agent SDK ou Deep Agents no Databricks: qual rastreia melhor e qual sobrevive a uma queda"
date: 2026-08-06T09:00:00-03:00
draft: false
tags: ["Databricks", "Agentes de IA", "MLflow", "LangChain", "Claude", "Opinião"]
summary: "Uma comparação prática entre LangGraph, Claude Agent SDK e Deep Agents mostra que a escolha de orquestração muda o que você ganha de graça em rastreamento MLflow e o quanto sobra pra você construir sozinho quando o agente trava no meio de uma tarefa longa."
ShowToc: false
---

Escolher framework de orquestração de agente parece decisão de biblioteca, mas na prática decide quanto de rastreamento e recuperação de falha você ganha de graça, e quanto sobra pra você construir na mão.

O Databricks MVP Shashank Shekhar comparou três caminhos para workflow agêntico no ecossistema Databricks, LangGraph, Claude Agent SDK e Deep Agents (da LangChain), olhando especificamente pra integração com MLflow, gerenciamento de estado de longa duração e esforço real de implementação, não só qual "parece" melhor em demo.

Na integração com MLflow, o LangGraph sai na frente: `mlflow.langchain.autolog()` entrega rastreamento nativo do grafo inteiro, já formatado para os frameworks de avaliação do Databricks. Deep Agents herda esse mesmo runtime do LangGraph por baixo, então aproveita esse rastreamento, só que com nomes de etapa um pouco mais genéricos. Já o Claude Agent SDK captura bem cada chamada de modelo isoladamente, mas pra ver o loop completo e os spans de skill é preciso exportar via OpenTelemetry manualmente, não tem autologging nativo de fábrica. No quesito recuperação de estado, LangGraph e Deep Agents se encaixam bem num desenho de checkpoint assíncrono sobre Lakebase, com estado persistindo a cada passo, o que é essencial pra workflow com humano no loop. O Claude Agent SDK espelha a transcrição da sessão via banco, mas sua fronteira de durabilidade é a invocação completa, então esperar uma ferramenta responder no meio de uma execução longa exige camada própria construída por quem implementa.

Pontos técnicos que valem registrar:
- LangGraph oferece rastreamento nativo do grafo completo via `mlflow.langchain.autolog()`, alinhado aos frameworks de avaliação do Databricks
- Deep Agents herda o runtime do LangGraph e seu rastreamento, mas com granularidade de etapa mais grosseira
- Claude Agent SDK exige exportação via OTel para capturar loop completo e spans de skill, sem autologging nativo
- LangGraph e Deep Agents se apoiam em checkpoint assíncrono compatível com Lakebase, mantendo estado a cada passo
- Claude Agent SDK tem fronteira de durabilidade na invocação completa, exigindo camada própria para espera longa de ferramenta
- LangGraph é o framework mais adotado e testado em produção, mas exige montar a própria estrutura de skills; Deep Agents pede menos esforço de implementação para arquitetura multiagente complexa, sendo porém o harness mais recente dos três

**Minha ressalva:** comparação desse tipo envelhece rápido, porque os três projetos evoluem toda semana, e o que hoje é uma lacuna do Claude Agent SDK em autologging pode fechar no próximo release. Ainda assim, o critério que ele usou, rastreamento nativo versus esforço manual, e durabilidade a nível de passo versus a nível de invocação completa, é o jeito certo de comparar framework de agente pra quem vai rodar isso em produção sobre Databricks, não a lista de features do marketing de cada um.

**Fonte:** https://www.linkedin.com/in/ishashankshekhar/#langgraph-claude-agent-sdk-deep-agents-databricks

#Databricks #AgentesIA #MLflow
