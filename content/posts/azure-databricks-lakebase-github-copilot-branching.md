---
title: "Lakebase chega ao Azure com branch de banco pra debugar agente do GitHub Copilot"
date: 2026-06-17T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Lakebase", "GitHub Copilot", "Postgres", "Opinião"]
summary: "A combinação Lakebase + branching de banco resolve um problema bem específico: como debugar um agente em produção sem tocar nos dados reais."
ShowToc: false
---

O Lakebase chegou ao Azure Databricks com um caso de uso bem concreto: branch de banco de dados para debugar agentes do GitHub Copilot em produção sem risco de compliance.

A ideia é simples de explicar e difícil de fazer bem: você cria uma cópia leve (branch) do banco transacional, deixa o agente investigar ou reproduzir o problema nessa cópia, e descarta depois — sem nunca expor dado real de produção ao processo de debug.

Por que isso resolve uma dor real:
- Debugar agente em produção hoje geralmente significa "olhar log e torcer" ou replicar o ambiente manualmente
- Branch de banco transacional, historicamente, é operação cara e lenta — aqui vira rotina
- Times de compliance ganham uma resposta pronta pra "como vocês testam agente sem tocar em dado sensível"

**Minha ressalva:** branch fácil de criar é branch fácil de esquecer de apagar. Antes de adotar isso em escala, eu perguntaria como fica o ciclo de vida desses branches — quem garante que uma cópia de debug não vira um banco órfão rodando fatura sem ninguém saber.

**Fonte:** https://www.databricks.com/blog/unifying-data-and-governance-agentic-era-whats-new-azure-databricks

#AzureDatabricks #Lakebase #GitHubCopilot
