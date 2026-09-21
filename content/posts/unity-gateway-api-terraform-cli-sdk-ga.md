---
title: "Unity Gateway virou API gerenciável por Terraform, CLI e SDK, não só pela interface"
date: 2026-09-17T12:00:00-03:00
draft: false
tags: ["Databricks", "Unity AI Gateway", "Terraform", "Infraestrutura como Código"]
summary: "A API do Unity Gateway pra gerenciar model services, provedor de modelo externo e servidor MCP chegou à disponibilidade geral no Azure Databricks, com suporte oficial em Terraform, Databricks CLI e SDKs Python, Go, Java e JavaScript."
ShowToc: false
---

Configurar o Unity Gateway deixou de ser tarefa exclusiva de clicar na interface do workspace.

A API do Unity Gateway para gerenciar model services, model provider services e servidores MCP chegou à disponibilidade geral no Azure Databricks, com operações completas de criar, ler, atualizar, listar e apagar disponíveis em toda a cadeia de ferramentas de desenvolvedor oficiais. Isso significa que a configuração do gateway agora pode ser versionada e provisionada como qualquer outro recurso de infraestrutura, em vez de depender de configuração manual feita direto na interface.

O suporte chega simultaneamente em várias frentes: Terraform provider a partir da versão 1.132.0, Databricks CLI a partir da v1.17.0, e SDKs oficiais em Python (databricks-sdk 0.136.0 ou mais recente), Go (databricks-sdk-go v0.178.0 ou mais recente), Java (databricks-sdk-java 0.153.0 ou mais recente) e JavaScript (@databricks/sdk-aigateway 0.19.0 ou mais recente). Suporte via Declarative Automation Bundles, usando o Databricks CLI 1.17.0 ou mais recente, ainda está em Beta.

Pontos técnicos que valem atenção:
- Cobertura completa de CRUD (criar, ler, atualizar, listar, apagar) pra model services, model provider services e servidores MCP
- Terraform provider 1.132.0+ permite declarar a configuração do gateway junto com o resto da infraestrutura
- Declarative Automation Bundles com suporte ao Unity Gateway ainda em Beta, via CLI 1.17.0+
- Documentação de referência da API disponível em docs.databricks.com/api/workspace/aigateway
- SDKs cobrem as quatro linguagens mais comuns em automação de plataforma: Python, Go, Java e JavaScript

**Minhas considerações:** até agora, configurar o Unity Gateway dependia bastante da interface do workspace, o que dificultava reproduzir a mesma configuração entre ambientes de forma confiável. Ter isso como recurso nativo de Terraform e Asset Bundle facilita versionar a configuração do gateway junto com o resto da infraestrutura, o que importa bastante pra quem já trata o Azure Databricks como código em vez de depender de clique manual.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#unity-gateway-api-and-developer-tools-are-generally-available

#Databricks #UnityAIGateway #InfraestruturaComoCodigo
