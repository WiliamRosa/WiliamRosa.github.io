---
title: "CI/CD pra Declarative Automation Bundles: quatro caminhos possíveis, e o que separa eles de verdade"
date: 2026-10-08T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Declarative Automation Bundles", "CI/CD", "DevOps"]
summary: "Depois que uma Declarative Automation Bundle funciona no notebook de alguém, o problema seguinte é sempre o mesmo: como fazer o deploy acontecer sem um token pessoal sentado num GitHub Secret pra sempre. Mapeei os quatro caminhos recomendados pelo Azure Databricks e o que realmente muda entre eles."
ShowToc: true
---

Toda equipe que adota Declarative Automation Bundles (o nome atual do que a documentação chamava de Databricks Asset Bundles) passa pelo mesmo rito de passagem: a bundle roda perfeitamente no notebook de alguém com `databricks bundle deploy`, todo mundo fica feliz, e aí vem a pergunta que ninguém respondeu ainda. Quem roda esse comando em produção? E com qual credencial?

É nesse ponto que a maioria das equipes improvisa uma solução ruim, geralmente um token de usuário pessoal guardado num secret do GitHub, que funciona até a pessoa trocar de time ou desativar a conta. O Azure Databricks tem pelo menos quatro caminhos documentados pra resolver isso de forma correta, e a escolha entre eles depende menos da ferramenta de CI/CD que você já usa e mais de uma pergunta anterior: você quer autenticação federada sem segredo de longa duração, ou aceita um token de service principal armazenado como secret.

## Antes de escolher a ferramenta, separe build de deploy

O fluxo recomendado pelo Azure Databricks para CI/CD tem sete etapas (versionar, codificar, build, deploy, testar, rodar, monitorar), mas a parte que determina a arquitetura do seu pipeline é a etapa de deploy. É aqui que a Declarative Automation Bundle entra como unidade de implantação: ela empacota jobs, pipelines e configuração de ambiente como arquivo versionável, e qualquer ferramenta externa de CI/CD só precisa saber rodar `databricks bundle deploy` apontando pro target certo.

Isso importa porque significa que GitHub Actions, Azure DevOps e Jenkins não competem entre si tecnicamente, eles resolvem a mesma coisa (disparar o CLI do Databricks contra um target de bundle) com integração diferente ao resto do seu ecossistema de CI/CD já existente.

## Caminho 1: GitHub Actions com federação de identidade (sem secret de longa duração)

A recomendação atual do Azure Databricks pra GitHub Actions é autenticação via OAuth token federation, que elimina a necessidade de guardar qualquer secret do Azure Databricks no repositório. Em vez de um token de acesso que alguém precisa gerar e rotacionar manualmente, o workflow troca o OIDC token do próprio GitHub Actions por uma sessão autenticada, usando uma política de federação configurada contra um service principal da conta.

O detalhe que trava muita gente na primeira tentativa: o subject da política de federação precisa bater exatamente com o subject que o GitHub emite, no formato `repo:org/repo:environment:NomeDoEnvironment`. Errar esse formato é o erro mais comum nessa configuração.

## Caminho 2: GitHub Actions com service principal e token (o caminho mais comum ainda)

Se a federação OIDC ainda não está configurada, o caminho mais usado hoje é gerar um token de acesso pra um service principal (não um usuário), guardar esse token como secret do GitHub, e usar a variável de ambiente `DATABRICKS_BUNDLE_TARGET` pra apontar qual target do bundle está sendo implantado. A ação `databricks/setup-cli` baixa o CLI no runner, e o resto é `databricks bundle deploy` mais `databricks bundle run`.

A diferença prática pro caminho 1 é operacional: aqui existe um segredo de longa duração pra rotacionar, lá não existe segredo nenhum pra vazar.

## Caminho 3: Azure DevOps, quando o resto da esteira já mora lá

Para organizações que já usam Azure DevOps como esteira de CI/CD corporativa, o Azure Databricks documenta integração equivalente, com os mesmos conceitos de target de bundle e autenticação por service principal, só trocando o runner do GitHub Actions por um pipeline YAML do Azure DevOps. A lógica de separação de ambiente (dev, staging, prod) não muda, só a casca que dispara o CLI muda.

## Caminho 4: sincronizar Git folder, quando você não precisa do bundle inteiro

Existe um quarto caminho mais leve, pensado pra quem só precisa manter notebooks sincronizados com um branch remoto, sem gerenciar configuração de job ou pipeline como código. Um workflow simples roda `databricks repos update` apontando pro branch certo, sem nenhuma etapa de `bundle deploy`.

**Minha leitura:** esse quarto caminho é o mais fácil de escolher errado. Ele resolve sincronização de código, não implantação de infraestrutura, e qualquer configuração de job ou pipeline feita manualmente na UI por cima dele fica fora do controle de versão. Funciona bem como ponto de entrada pra equipe que ainda não tem esteira de CI/CD nenhuma, mas não é substituto pra bundle completo assim que existir mais de um ambiente pra gerenciar.

## Mão na massa: separando dev e prod no mesmo repositório

O padrão que aparece de forma consistente na documentação combina federação de identidade com separação de target dentro da própria bundle, em vez de duplicar workflow por ambiente. Um exemplo combinando os dois conceitos:

```yaml
name: Deploy bundle

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event_name == 'push' && 'Prod' || 'Dev' }}
    env:
      DATABRICKS_AUTH_TYPE: github-oidc
      DATABRICKS_HOST: ${{ vars.DATABRICKS_HOST }}
      DATABRICKS_CLIENT_ID: ${{ secrets.DATABRICKS_CLIENT_ID }}
      DATABRICKS_BUNDLE_TARGET: ${{ github.event_name == 'push' && 'prod' || 'dev' }}
    steps:
      - uses: actions/checkout@v4
      - uses: databricks/setup-cli@main
      - run: databricks bundle validate
      - run: databricks bundle deploy
      - run: databricks bundle run sample_job --refresh-all
```

A parte que realmente faz diferença aqui não é a sintaxe, é a decisão de amarrar o `environment` do GitHub (que carrega a política de federação) ao `DATABRICKS_BUNDLE_TARGET` (que decide qual workspace recebe o deploy) através do mesmo evento de trigger. Isso evita que alguém configure federação pra produção e aponte pro target errado por engano.

## O que isso não resolve

Nenhum desses quatro caminhos resolve teste de regressão de verdade. `databricks bundle validate` confirma que a sintaxe da bundle está correta, não que o job vai produzir o resultado certo. Isso ainda depende de testes escritos com pytest ou equivalente, rodando antes do deploy, não depois. E nenhum caminho aqui cobre rollback automático: se o deploy em prod quebrar algo, a reversão ainda é um novo deploy manual da versão anterior, não um botão de "desfazer".

## Resumindo

A pergunta que decide qual caminho usar não é "qual ferramenta de CI/CD minha empresa já usa", é "minha organização já tem política de federação de identidade configurada, ou ainda depende de token de longa duração". Se a resposta for a segunda, comece pelo caminho 2 e trate a migração pra federação OIDC como débito técnico a resolver, não como opcional pra sempre.

## Referências

- Microsoft Learn, "What are Declarative Automation Bundles?": https://learn.microsoft.com/en-us/azure/databricks/dev-tools/bundles/
- Microsoft Learn, "CI/CD on Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/dev-tools/ci-cd/
- Microsoft Learn, "GitHub Actions - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/dev-tools/ci-cd/github
- Microsoft Learn, "Authenticate access to Azure Databricks using OAuth token federation": https://learn.microsoft.com/en-us/azure/databricks/dev-tools/auth/oauth-federation
- Microsoft Learn, "Service principals for CI/CD": https://learn.microsoft.com/en-us/azure/databricks/dev-tools/auth/service-principals

#AzureDatabricks #DeclarativeAutomationBundles #CICD #DevOps
