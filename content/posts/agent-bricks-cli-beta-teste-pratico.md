---
title: "Testei o Agent Bricks CLI em Beta: de pasta vazia a agente no ar em cinco comandos"
date: 2026-10-10T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Agent Bricks", "CLI"]
summary: "O Databricks MVP Gary Nakanelua testou o novo Agent Bricks CLI, em Beta, e levou cerca de 188 segundos de uma pasta vazia até um agente no ar com memória, sessão e rastreamento já conectados, encontrando dois pontos de atrito no caminho: um erro no primeiro deploy por causa dos stores de memória e sessão, e um projeto Lakebase que o comando de exclusão deixa para trás."
ShowToc: false
---

O Databricks MVP Gary Nakanelua testou na prática o Agent Bricks CLI, ferramenta de linha de comando em Beta para construir e implantar agente customizado direto do terminal, sem passar pela interface de workspace.

A proposta do CLI é resolver um trabalho que normalmente exige conectar várias peças manualmente: ambiente local, runtime do agente, armazenamento de memória e sessão, e rastreamento de execução via MLflow. O arquivo `agent.toml` funciona como fonte de verdade declarativa dessas peças, e três comandos cobrem o ciclo inteiro: `agentbricks init` monta o projeto a partir de um template de framework (LangGraph ou OpenAI Agents SDK), `agentbricks dev` roda o agente localmente contra o model serving do Azure Databricks para teste antes do deploy, e `agentbricks deploy` publica o agente no runtime de agente do Azure Databricks.

O que o teste prático mostrou:

- Do diretório vazio até um agente no ar levou 188 segundos depois do início do deploy
- O comando `agentbricks init` já entrega o agente com chat, memória, sessão e rastreamento MLflow conectados de uma vez, sem configuração manual de cada peça
- O primeiro deploy falhou em 3,6 segundos por causa dos stores de memória e sessão, e desvincular esses stores foi o que permitiu completar o deploy
- O comando de exclusão (`agentbricks deployments stop` ou equivalente) não limpa o projeto Lakebase criado para o agente, o que em ambiente Free Edition pode bloquear o próximo deploy até essa limpeza ser feita manualmente

**Minha leitura:** o ganho real de um CLI assim não é economizar linha de código, é economizar decisão. Toda vez que alguém monta agente do zero, memória, sessão e rastreamento acabam sendo decisões de arquitetura tomadas de forma improvisada, geralmente diferente a cada projeto. Ter um template que já resolve essas três peças de um jeito padronizado reduz a variação entre times, mas o detalhe do projeto Lakebase deixado para trás depois do delete é exatamente o tipo de atrito que só aparece quando alguém testa o fluxo completo de verdade, não só o caminho feliz de criar e publicar.

**Fonte:** https://docs.databricks.com/aws/en/agents/custom-agents/agent-bricks-cli

#AzureDatabricks #AgentBricks #CLI
