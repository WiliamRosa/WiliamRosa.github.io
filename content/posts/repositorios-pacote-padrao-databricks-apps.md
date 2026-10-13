---
title: "Repositório de pacote padrão por workspace: um Secret Scope resolve index-url pra todo app, notebook e pipeline de uma vez"
date: 2026-10-10T14:00:00-03:00
draft: false
tags: ["Azure Databricks", "Databricks Apps", "Governança"]
summary: "Admin de workspace agora configura repositório privado de pacote Python, npm e Maven uma vez só, via um Secret Scope com nome fixo, e notebook, job, pipeline e Databricks App herdam isso automaticamente, sem precisar declarar index-url em cada app.yaml."
ShowToc: false
---

Quem já gerenciou dependência interna em múltiplos projetos Databricks conhece o problema: cada notebook, cada app, cada pipeline precisa declarar de novo o índice de pacote privado da empresa, geralmente copiado e colado de um lugar pro outro, até alguém esquecer de atualizar uma cópia quando a credencial muda.

A solução agora é um repositório de pacote padrão configurado uma única vez no nível do workspace, usando a mesma infraestrutura de Databricks secrets que já protege outras credenciais. Python se aplica a notebook, job, pipeline do Lakeflow e Databricks App ao mesmo tempo; Maven se aplica a instalação de biblioteca em nível de cluster no Databricks Runtime 18.3 ou superior; npm se aplica só a Databricks Apps.

Pontos técnicos do mecanismo:

- Tudo gira em torno de um Secret Scope com nome fixo obrigatório, `databricks-package-management`, e chaves também fixas: `pip-index-url`, `pip-extra-index-urls`, `pip-cert`, `maven-repositories`, `npm-rc`
- Depois de criar o scope, o admin precisa dar `READ` pra `users` e manter `MANAGE` só pra `admins`, via `databricks secrets put-acl`, isso garante que ninguém altera o repositório compartilhado sem permissão
- Se o código, notebook ou `app.yaml` do app já declarar seu próprio `index-url` ou registro npm, esse valor específico tem precedência sobre o padrão do workspace, o padrão só preenche a lacuna quando nada foi declarado
- Pra Maven, o admin pode configurar um repositório primário mais até cinco adicionais, cada um com usuário, senha e realm opcionais; configurar um primário remove o Maven Central da cadeia de resolução, então vale revisar se alguma dependência pública ainda é necessária antes de migrar
- A aplicação da mudança depende do tipo de workload: notebook e job serverless pegam a mudança ao reconectar o compute; notebook e job clássico só depois de reiniciar o compute; pipeline do Lakeflow só na próxima execução; Databricks App só no próximo build e deploy
- Configurar Maven ainda está em Private Preview e exige contato com o time de conta da Databricks; o resto (Python em pipeline, Python em cluster via API ou UI, e habilitar a configuração pra Databricks Apps) já está em disponibilidade geral

**Minhas considerações:** o detalhe que realmente evita dor de cabeça aqui é a precedência: time que já declara index-url explícito no próprio app continua funcionando sem mudar nada, o padrão de workspace só entra pra quem nunca declarou nada. Isso significa que adotar esse recurso não exige auditoria de todo app existente de uma vez, só dos times que ainda vivem copiando e colando configuração de repositório manualmente, que é exatamente o público que mais se beneficia disso.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/admin/workspace-settings/default-package-repositories

#AzureDatabricks #DatabricksApps #Governanca
