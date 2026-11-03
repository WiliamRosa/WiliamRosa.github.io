---
title: "Databricks Apps ganhou verificação automática de vulnerabilidade de código"
date: 2026-11-02T08:00:00-03:00
draft: false
tags: ["Databricks Apps", "Seguranca", "Azure Databricks"]
summary: "O Databricks MVP Ajay Kumar Pandey destacou o Code Security Scanning para Databricks Apps, recurso que identifica vulnerabilidade e dependência vulnerável direto no código da aplicação durante o próprio fluxo de desenvolvimento."
ShowToc: false
---

Databricks Apps ganhou verificação automática de vulnerabilidade de código antes do app ir para produção.

O Databricks MVP Ajay Kumar Pandey destacou a chegada do Code Security Scanning para Databricks Apps, um recurso que identifica vulnerabilidade e dependência vulnerável diretamente no código da aplicação durante o próprio fluxo de desenvolvimento, sem exigir ferramenta externa de SAST plugada à parte.

A ideia central é mover a verificação de segurança pra dentro do mesmo laço de edição e deploy que já existe pra qualquer Databricks App, em vez de depender de um scanner de terceiro rodando só na pipeline de CI/CD, fora do radar de quem está escrevendo o código. Isso aproxima Databricks Apps de uma prática que já é padrão em ambiente de desenvolvimento moderno, mas que até agora dependia de integração manual com ferramenta externa.

Pontos técnicos que valem atenção:
- Escaneia o código da aplicação, conforme o runtime do app, e as dependências declaradas no manifesto
- Roda como parte do fluxo de desenvolvimento, não como um job isolado de segurança
- Identifica tanto vulnerabilidade no código do próprio app quanto em pacote de terceiro referenciado
- Resultado aparece integrado à interface de Databricks Apps, sem sair do workspace pra ver o relatório

**Minha ressalva:** scanner embutido reduz fricção, mas não substitui uma política de segurança que define o que fazer quando a vulnerabilidade aparece, bloquear deploy, abrir ticket ou só avisar. Vale confirmar se dá pra integrar esse resultado a uma Service Policy do Unity Gateway ou a um gate de CI/CD antes de contar com ele como controle único de segurança de app.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/dev-tools/databricks-apps/security-scanning

#DatabricksApps #Seguranca #AzureDatabricks
