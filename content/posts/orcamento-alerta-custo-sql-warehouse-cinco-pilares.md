---
title: "Cinco pilares pra controlar gasto de SQL warehouse: atribuição, orçamento, alerta, dashboard e otimização"
date: 2026-10-08T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "FinOps", "SQL Warehouse"]
summary: "A Databricks publicou um guia estruturado em cinco pilares pra controlar gasto de SQL warehouse: tag de warehouse e de consulta alimentando system table, orçamento por workspace ou tag no Account Console, alerta de SQL rodando sobre essa mesma system table, e otimização via auto-stop e predictive optimization."
ShowToc: false
---

A Databricks publicou um guia prático sobre controle de gasto de SQL warehouse, e o que chama atenção não é nenhuma feature isolada, é a estrutura: cinco pilares (atribuição, orçamento, alerta, dashboard e otimização) que juntos respondem a pergunta que todo time de dado acaba enfrentando, quem está gastando o quê, e o que fazer quando o gasto sai da curva esperada.

A base técnica de tudo isso são duas tags diferentes alimentando duas system tables diferentes: tag de warehouse entra em `system.billing.usage`, permitindo agrupar consumo de DBU por time, centro de custo ou caso de uso, e tag de consulta entra em `system.query.history`, carregando contexto de negócio pra cada instrução SQL individual. Sem política nativa que force o uso dessas tags, o guia recomenda provisionar via Terraform, Declarative Automation Bundles ou API REST, justamente pra não depender de disciplina manual de cada usuário marcando seu próprio warehouse.

Pontos técnicos do guia:

- Orçamento é configurado no Account Console (Usage > Budgets), com escopo por workspace ou por tag, e dispara notificação por email
- O próprio material é explícito numa limitação importante: orçamento monitora gasto, não impõe teto rígido de gasto
- Alerta de SQL rodando sobre as system tables permite alerta de ritmo (pacing), projetando o gasto do mês inteiro a partir do consumo parcial, com sugestão de rodar essa projeção a cada quatro horas e mandar o resultado pro Slack ou email
- Auto-stop de compute serverless tem padrão de 10 minutos, redutível pra 5 minutos via interface ou 1 minuto via API
- Predictive optimization já vem ativado por padrão em conta criada a partir de 11 de novembro de 2024
- Uma limitação explícita: custo de atualização de materialized view aparece como uso de pipeline serverless, não como uso de warehouse, então quem olha só consumo de warehouse perde essa fatia de custo

**Minha leitura:** o ponto mais honesto do guia é admitir, por escrito, que orçamento aqui é mecanismo de monitoramento, não de corte automático de gasto. Isso muda a expectativa de quem está implantando esse controle: não é "configurei orçamento e agora o gasto não passa disso", é "configurei orçamento e alerta pra saber rápido quando o gasto está saindo da curva, pra alguém agir". Pra time que já lida com surpresa de fatura, o pilar que mais vale priorizar primeiro não é o dashboard bonito, é fechar o buraco de consulta sem tag, porque sem atribuição completa todo o resto do controle fica incompleto.

**Fonte:** https://www.databricks.com/blog/set-budgets-and-alerts-cloud-data-warehouse-costs

#AzureDatabricks #FinOps #SQLWarehouse
