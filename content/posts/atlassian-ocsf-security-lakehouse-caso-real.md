---
title: "Atlassian normalizou 44 bilhões de eventos por dia em OCSF, e a consulta que levava 45 segundos passou pra 3"
date: 2026-10-16T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Segurança", "OCSF", "Lakehouse"]
summary: "Já vimos a arquitetura geral da Data Intelligence for Cybersecurity da Databricks (Agent Bricks, Lakebase, OCSF sobre Delta Lake). Agora a Atlassian mostra como isso funciona na prática em 44 bilhões de eventos por dia: 80% de redução de custo de ingestão, consulta de 45 segundos pra 2-3 segundos, e um schema tipado em Go que rejeita log fora do padrão já na compilação."
ShowToc: false
---

Já cobri aqui a arquitetura geral da Data Intelligence for Cybersecurity da Databricks, que propõe tratar telemetria de segurança como dado de lakehouse governado em vez de silo caro de SIEM. O que faltava era ver isso provado em escala real, e a Atlassian, com 20 anos de aquisições e cada negócio adquirido trazendo seu próprio formato de log, é um teste de estresse e tanto: 44 bilhões de evento de segurança por dia, sem schema comum entre eles.

A decisão central da Atlassian foi padronizar tudo em OCSF (Open Cybersecurity Schema Framework), escolhido sobre alternativas como ECS e UDM por ser totalmente aberto, fortemente tipado e mantido pela Linux Foundation, e processar via ETL (transformar o dado em trânsito) em vez de ELT, o que viabiliza detecção em tempo real e não amarra a empresa a um único fornecedor de SIEM.

Pontos técnicos do caso:

- O schema OCSF (cerca de 40 mil campos) é embutido direto em struct do Go, então log fora de conformidade falha já na compilação, antes de chegar ao lakehouse; essa rigidez também reduziu alucinação no fluxo agêntico de transformação de log
- Pipeline de seis fases que antes era manual foi automatizado: um analista pede um dataset, o fluxo gera o mapeamento e o DAG, testa localmente, faz deploy canário via pull request, observa em produção por um tempo e só então promove, com teste de regressão no caminho
- Detecção saiu do modelo um-alerta-por-evento pra alerta baseado em sinal e risco, agrupando achados por valor OCSF compartilhado (como o usuário que praticou a ação), via uma ferramenta própria chamada Alert Explorer
- Infraestrutura: transação ACID (facilita migração de versão de schema), cluster Spark com autoscaling, particionamento com Z-ORDER, cluster Graviton com Photon, e Liquid Clustering já planejado como próximo passo

Os números falam por si: redução de 80% no custo de ingestão, mais de 500 sinais de detecção de ameaça em produção, aumento de 60% na produtividade do analista, e consulta que levava cerca de 45 segundos agora roda em 2 a 3 segundos, uma melhora de até 95%. Mapear os dados também acelerou: um terço do volume de dado levou um ano pra mapear, os dois terços restantes levaram dois meses.

**Minha ressalva:** o caso é rico em métrica de resultado, mas pouco específico sobre como a validação de schema em Go se conecta ao Unity Catalog e à governança de linha e coluna que o artigo geral sobre a plataforma promete, o texto nem cita Delta Lake ou Unity Catalog pelo nome, só menciona "transação ACID nativa". Isso não invalida o resultado, 44 bilhões de eventos por dia normalizados é prova de escala real, mas vale ler esse caso como validação do conceito de Security Lakehouse, não como blueprint técnico detalhado de como reproduzir a integração de governança ponta a ponta.

**Fonte:** https://www.databricks.com/blog/reducing-noise-how-atlassian-built-ocsf-security-lakehouse-databricks

#AzureDatabricks #Seguranca #OCSF
