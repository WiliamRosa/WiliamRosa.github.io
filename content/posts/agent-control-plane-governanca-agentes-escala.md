---
title: "Mil agentes de IA sem identidade nenhuma é um problema de governança, não de escala"
date: 2026-09-27T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Unity Gateway", "AI Governance"]
summary: "O Databricks MVP Mantu Samadder mapeou o Agent Control Plane emergente no Databricks, unindo Agent Registry, Agent Identity, Unity Gateway, Service Policies, Unity Catalog e MLflow com System Tables para governar agentes de IA como workloads corporativos accountable."
ShowToc: false
---

Construir um agente de IA é relativamente fácil. Operar milhares deles entre funções de negócio, domínios de dado, modelos e ferramentas diferentes é um problema de governança corporativa, não de engenharia isolada.

O Databricks MVP Mantu Samadder descreveu o Agent Control Plane que está emergindo dentro do Databricks como resposta a essa lacuna. A premissa é simples: assim como funcionário, aplicação e service account têm identidade, todo agente corporativo deveria ter uma identidade única, donos técnicos e de negócio, um propósito aprovado, permissões de dado e ferramenta definidas, limites de risco, custo e uso, e uma trilha de auditoria completa. Sem isso, não existe como uma empresa responder quem agiu, em nome de quem, usando qual dado e ferramenta, e a que custo.

No Databricks, esse controle já aparece distribuído entre peças que a maioria das equipes já conhece isoladamente, mas raramente pensa como um sistema único: Agent Registry cataloga agentes, ferramentas, skills e servidores MCP com dono e propósito declarados; Agent Identity estabelece responsabilidade e acesso de menor privilégio; Unity Gateway controla acesso a modelo e ferramenta, roteamento, uso e custo; Service Policies impõe guardrails de runtime centralizados; Unity Catalog governa os ativos de dado e IA acessíveis; e MLflow combinado com System Tables rastreia qualidade, performance, uso, custo e atividade de auditoria. Segundo ele, isso já está em produção: a própria Databricks governa os agentes de código de milhares de engenheiros através do Unity Gateway, com atribuição baseada em identidade, medição centralizada, limites de gasto e aprovações.

Pontos da arquitetura:

- Agent Registry: catálogo de agentes, ferramentas, skills, servidores MCP, donos e ciclo de vida
- Agent Identity: estabelece responsabilidade e acesso de menor privilégio
- Unity Gateway: controla acesso a modelo e ferramenta, roteamento, uso e custo
- Service Policies: impõe guardrails de runtime centralizados
- Unity Catalog: governa os ativos de dado e IA acessíveis a cada agente
- MLflow mais System Tables: rastreiam qualidade, performance, uso, custo e auditoria

**Minha leitura:** o paralelo com AWS Bedrock AgentCore, Google Gemini Enterprise e Microsoft Agent 365 mostra que essa não é uma arquitetura exclusiva da Databricks, é um padrão convergindo entre as grandes plataformas, o que sugere que virou requisito de mercado, não diferencial de produto. A pergunta de liderança deixa de ser "quantos agentes conseguimos construir" e passa a ser "conseguimos descobrir, identificar, governar, observar e parar cada agente que implantamos". Quem ainda não tem resposta clara pra essa segunda pergunta está acumulando dívida de governança mais rápido do que está acumulando valor dos agentes.

**Fonte:** https://www.linkedin.com/in/mantus/#agent-control-plane-governanca-agentes-escala

#Databricks #AIGovernance #AgenticAI
