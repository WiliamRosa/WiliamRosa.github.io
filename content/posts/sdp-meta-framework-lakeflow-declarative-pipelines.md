---
title: "DLT-META virou SDP-META, com CLI novo e MCP Server pra montar pipeline"
date: 2026-09-01T09:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow", "Databricks Labs", "Opinião"]
summary: "O framework de pipeline metadata-driven dos Databricks Labs mudou de nome, de DLT-META pra SDP-META, na versão 0.1.0, e ganhou CLI própria, Asset Bundles, app de configuração e um MCP Server pra scaffolding assistido por agente."
ShowToc: false
---

Framework mais adotado dos Databricks Labs pra construir pipeline bronze e prata trocou de nome e ganhou peças novas de uma vez.

O Databricks MVP Josue Bogran documentou o lançamento da versão 0.1.0 do SDP-META, a nova identidade do projeto que até então se chamava DLT-META, renomeado pra acompanhar a mudança de nome de Delta Live Tables pra Lakeflow Spark Declarative Pipelines dentro da plataforma.

A proposta do framework continua a mesma: em vez de escrever um notebook de pipeline pra cada tabela, você descreve fonte, destino, regra de CDC e regra de qualidade em configuração JSON ou YAML, e um pipeline genérico lê essa configuração e monta o grafo de processamento em tempo de execução. Isso reduz bastante código repetido em ambiente com dezenas ou centenas de tabelas seguindo o mesmo padrão de ingestão.

Pontos técnicos que valem atenção:
- Instalação via pip install databricks-labs-sdp-meta, com pacote de compatibilidade pra quem ainda usa dlt-meta
- CLI própria, databricks labs sdp-meta, com comando de bundle-init, onboard e deploy
- Suporte nativo a Databricks Asset Bundles pra empacotar e implantar o pipeline
- App de configuração no navegador (SDP-META App) pra montar e revisar metadado sem editar arquivo direto
- MCP Server novo, pra scaffolding assistido por agente de código como Claude Code ou Cursor
- Continua suportando Autoloader, Delta, Kafka, Event Hub e ingestão via snapshot, incluindo CDC multi-fonte

**Minhas considerações:** a Databricks troca nome de produto com uma frequência que já virou motivo de piada interna, mas nesse caso a essência do framework, pipeline guiado por metadado em vez de código repetido, continua sólida e vale a adoção pra time que sobe muitas tabelas parecidas. O MCP Server é o pedaço mais interessante pra quem já usa agente de código no dia a dia.

**Fonte:** https://pypi.org/project/databricks-labs-sdp-meta/

#Databricks #Lakeflow #DatabricksLabs
