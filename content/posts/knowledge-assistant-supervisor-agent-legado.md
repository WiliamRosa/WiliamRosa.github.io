---
title: "Knowledge Assistant e Supervisor Agent, que vimos num workflow real há pouco, agora são legado"
date: 2026-10-14T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Agent Bricks", "Genie", "Migração"]
summary: "Knowledge Assistant, Supervisor Agent e mais sete oferecimentos de agente viraram legado na documentação da Azure Databricks: pra agente sem código, use Genie Agents; pra agente escrito em código, use o Agent Bricks CLI com DurableAgentServer no Agent Runtime."
ShowToc: false
---

Há pouco tempo, mostrei aqui como o Databricks MVP Aarni Sillanpää usou o Agent Bricks Multi-Agent Supervisor com sete funções do Unity Catalog, mais um agente Knowledge Assistant, pra automatizar a criação e manutenção de Genie Spaces. Esse workflow continua funcionando, mas a documentação da Azure Databricks acabou de marcar os dois componentes centrais dele, Knowledge Assistant e Supervisor Agent, como legado.

Legado aqui não significa removido nem quebrado, significa que a Databricks não recomenda mais esses componentes pra agente novo, só mantém a documentação pra quem já tem algo em produção precisando migrar. A lista de oferecimentos marcados como legado é maior do que só esses dois: cobre também a Supervisor API, construção de sistema multi-agente customizado, o servidor de agente legado em Databricks Apps, criação de front-end de chat avulso, Custom Agent em Model Serving, criação de LLM agent customizado, memory store gerenciado antigo, e até o AI Playground.

Pontos técnicos da migração recomendada:

- Pra agente sem código: use Genie Agents, tanto no lugar do Knowledge Assistant (pra perguntas sobre documento e dado) quanto no lugar do Supervisor Agent (pra agente de baixo código)
- Pra coordenar múltiplos agentes em código: use o Agent Bricks CLI, que serve o agente via `DurableAgentServer` e implanta no Agent Runtime, em vez da Supervisor API antiga
- Pra dar a um agente outros Genie Agents como ferramenta: o comando `agentbricks tools add genie-agent` substitui a construção manual de sistema multi-agente customizado
- Pra LLM agent customizado antigo: a recomendação agora é usar AI Functions, como `ai_query`, direto em SQL
- Memory store gerenciado legado (incluindo a versão self-managed sobre Lakebase) migra pra agent memory e agent sessions, a dupla de recursos mais recente da plataforma

**Minha ressalva:** o próprio texto da documentação é claro que isso não é uma descontinuação com prazo definido, é um sinal de direção. Quem já construiu algo sólido com Knowledge Assistant ou Supervisor Agent não precisa migrar hoje, mas construir algo novo em cima de um componente que a própria Databricks já classificou como legado é assumir dívida técnica consciente. Vale usar esse tipo de lista de migração como checklist antes de começar qualquer projeto novo de agente na plataforma, não só quando o componente já parar de receber atualização.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/agents/legacy/

#AzureDatabricks #AgentBricks #Genie
