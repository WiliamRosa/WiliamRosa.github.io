---
title: "Kasal: montar um time de agentes arrastando caixinha, não escrevendo orquestrador do zero"
date: 2026-09-10T11:00:00-03:00
draft: true
tags: ["Databricks", "Databricks Labs", "AI Agents", "Azure Databricks"]
summary: "O Databricks MVP Josue Bogran mostrou o Kasal, projeto do Databricks Labs que dá uma interface visual pra desenhar, testar e publicar um grupo de agentes cooperando, sem escrever o código de orquestração na mão."
ShowToc: false
---

Desenhar um crew de agentes com papel, tarefa e ferramenta definidos costuma virar um arquivo de configuração gigante antes mesmo do primeiro teste rodar.

O Databricks MVP Josue Bogran gravou uma demonstração do Kasal, um projeto do Databricks Labs pensado pra reduzir essa fricção inicial. Em vez de escrever manualmente a definição de cada agente, tarefa e ferramenta num framework tipo CrewAI, o Kasal expõe uma tela visual onde dá pra montar o time de agentes arrastando blocos, ligando um agente ao seu papel e às tarefas que ele deve executar, e testar essa composição antes de publicar de verdade.

O ponto central é encurtar o ciclo entre "ideia de fluxo multiagente" e "primeiro teste rodando", que hoje costuma passar por escrever bastante código de cola só pra descobrir que a divisão de tarefas entre os agentes não fazia sentido. Depois de validado na interface, o fluxo pode ser publicado como Model Serving endpoint ou job dentro do próprio ambiente Databricks, reaproveitando a mesma governança de Unity Catalog que já vale pro resto da plataforma.

Pontos técnicos que valem atenção:
- Interface visual pra compor agente, papel, tarefa e ferramenta sem editar YAML na mão
- Pensado pra padrão de multiagente tipo crew, um agente coordenando ou colaborando com outros
- Permite testar a composição antes de publicar
- Publicação final vira Model Serving endpoint ou job dentro do Databricks
- É projeto do Databricks Labs, então sem SLA de suporte formal como um produto GA

**Minha ressalva:** interface visual pra multiagente ajuda muito no protótipo, mas a complexidade real de um sistema desses (o que acontece quando um agente trava, como depurar decisão errada de coordenação) não desaparece só porque a montagem inicial ficou mais fácil. Vale testar em cenário com falha de propósito antes de confiar isso em produção.

**Fonte:** https://youtu.be/iaZZCMDLr7s

#Databricks #DatabricksLabs #AIAgents
