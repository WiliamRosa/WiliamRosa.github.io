---
title: "Databricks CLI agora autentica no GitHub Actions sem guardar segredo nenhum"
date: 2026-09-17T09:00:00-03:00
draft: false
tags: ["Databricks", "Databricks CLI", "Segurança", "CI/CD"]
summary: "O Databricks CLI passou a suportar workload identity federation via OIDC, então um workflow do GitHub Actions consegue autenticar num service principal do Azure Databricks sem nunca guardar client secret no repositório."
ShowToc: false
---

Mais um segredo de longa duração sumindo do pipeline de CI/CD.

O Databricks MVP Maria Vechtomova documentou uma novidade que evita justamente isso: o Databricks CLI agora suporta workload identity federation via OpenID Connect (OIDC), então um workflow do GitHub Actions consegue autenticar num service principal do Azure Databricks sem nunca guardar um client secret no repositório.

O mecanismo depende de três peças conversando entre si. A permissão `id-token: write` no workflow habilita o GitHub a emitir um token OIDC de curta duração. A variável `DATABRICKS_AUTH_TYPE=github-oidc` diz pro CLI trocar esse token pela autenticação real no Azure Databricks. E o `DATABRICKS_CLIENT_ID` identifica qual service principal está sendo usado, sem ser segredo nenhum, já que a confiança inteira mora na federation policy configurada antecipadamente.

Pontos técnicos que valem atenção:
- É preciso criar a federation policy no service principal antes de rodar o workflow, usando o Databricks CLI, vinculando repositório e ambiente específicos (por exemplo, "prod")
- `id-token: write` é o que permite ao workflow pedir o token OIDC do próprio GitHub
- `DATABRICKS_CLIENT_ID` aponta o service principal, mas não carrega nenhum segredo
- Azure DevOps e outros provedores OIDC também são suportados pelo mesmo mecanismo
- O resultado prático é um client secret a menos pra armazenar, rotacionar e eventualmente vazar

**Minha ressalva:** eliminar segredo de longa duração do CI/CD é sempre bem-vindo, mas a segurança inteira do esquema passa a depender de como a federation policy foi configurada. Uma política que não restringe bem repositório e ambiente vira uma porta aberta pra qualquer workflow do GitHub assumir aquele service principal, então vale revisar essa configuração com o mesmo cuidado que se dava ao segredo que ela substitui.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/dev-tools/auth/provider-github

#Databricks #DatabricksCLI #CICD
