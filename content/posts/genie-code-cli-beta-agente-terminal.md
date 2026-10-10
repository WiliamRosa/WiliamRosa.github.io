---
title: "Genie Code CLI chega em Beta: um agente de terminal que já nasce entendendo seu workspace Azure Databricks"
date: 2026-10-07T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Genie Code", "CLI"]
summary: "O Genie Code CLI, em Beta, é um agente de codificação que roda localmente no terminal, pré-configurado pra entender Azure Databricks e trabalhar com dado, pipeline, modelo e app via Unity Catalog e Databricks CLI, com acesso a modelo provido e governado pelo Unity Gateway durante o Beta."
ShowToc: false
---

Agente de código que roda no terminal já é categoria estabelecida, Claude Code e Codex são exemplos que qualquer um que acompanha esse espaço já conhece. O Genie Code CLI entra nessa mesma categoria, mas com uma diferença de origem: ele já nasce configurado pra entender Azure Databricks, em vez de precisar de instrução extensa de contexto a cada sessão nova.

Rodando localmente, o Genie Code CLI lê e edita arquivo local, executa comando e alcança o Azure Databricks em nome de quem está usando, sempre sob a identidade do próprio usuário, então o agente só acessa dado e executa operação que a permissão da pessoa já permite. Ele usa o Databricks CLI por baixo, incluindo o conjunto de comandos `databricks genie`, pra descobrir dado e responder pergunta sobre ele.

Detalhes técnicos do lançamento:

- Durante o Beta, acesso a modelo é provido e governado via Unity Gateway, sem precisar de assinatura própria de modelo
- O modelo usado durante o Beta é o GPT 5.6, escolha gerenciada pela Databricks, sem opção de troca manual de modelo
- Cobrança segue o consumo do Unity Gateway, não a precificação do Genie, então orçamento configurado pro Unity Gateway já controla esse gasto
- Exige workspace em região com suporte a Unity Gateway e Unity Catalog habilitado
- É uma experiência separada do Genie Code dentro do workspace: ferramenta, skill e instrução não são compartilhadas entre as duas superfícies, e o CLI ainda não cobre todas as capacidades disponíveis na UI

**Minha leitura:** o diferencial real aqui não é "mais um agente de terminal", é a camada de contexto pré-carregada sobre Azure Databricks, que normalmente é o trabalho mais chato de configurar em qualquer harness genérico. A limitação que mais pesa é justamente não compartilhar ferramenta e skill com o Genie Code da UI, então quem já investiu tempo configurando skill customizada no workspace não aproveita esse trabalho automaticamente no CLI. Sendo Beta recente e com capacidade mudando com frequência declarada pela própria documentação, vale tratar como ferramenta de experimentação antes de apostar fluxo de produção nela.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/genie-code/genie-code-cli

#AzureDatabricks #GenieCode #CLI
