---
title: "Agora dá pra plugar VS Code, Cursor ou terminal direto no compute do Azure Databricks via SSH"
date: 2026-09-13T09:00:00-03:00
draft: false
tags: ["Databricks", "Developer Experience", "VS Code", "Opinião"]
summary: "O túnel SSH conecta editor local ou CLI direto num cluster serverless, AI Runtime ou dedicado do Azure Databricks, com Cursor e Copilot funcionando de fábrica e Claude Code instalável na sessão. Sessão cai depois de uma hora e o limite é de dez conexões por cluster, então não é substituto de workflow de produção."
ShowToc: false
---

Trabalhar com Databricks remotamente sempre teve aquele atrito de sincronizar dependência e versão de runtime entre a máquina local e o cluster.

A Databricks lançou um túnel SSH que conecta VS Code, Cursor ou o terminal direto num compute do Azure Databricks, seja serverless, AI Runtime ou cluster dedicado. Isso elimina a etapa de replicar manualmente o ambiente Python local para bater com o Databricks Runtime remoto: o editor passa a rodar e depurar notebook e arquivo de workspace com dependência e versão já sincronizadas com o cluster de verdade, não com uma cópia local que pode ter versão de biblioteca diferente.

A ativação usa a flag `--ide` apontando pra vscode ou cursor; sem essa flag, a sessão abre direto no terminal, e de lá dá pra navegar até `/Workspace/Users/seu-usuario` pra acessar os arquivos do workspace normalmente. Do lado de agente de código, Cursor e GitHub Copilot já funcionam sem configuração extra dentro do túnel, e é possível instalar outro agente, como Claude Code, manualmente depois que a sessão SSH está ativa, o que dá a esses agentes o contexto completo do workspace.

Pontos técnicos que valem registrar:

- Conexão via SSH tunnel para compute serverless, AI Runtime ou cluster dedicado, com flag `--ide` para vscode/cursor ou modo terminal puro
- Arquivo e dependência ficam sempre sincronizados com o Databricks Runtime do cluster remoto, não com o ambiente local
- Cursor e Copilot funcionam nativamente; outros agentes como Claude Code precisam ser instalados manualmente dentro da sessão
- Sessão SSH pode cair depois de uma hora de inatividade
- Limite de dez conexões SSH simultâneas por cluster

**Minhas considerações:** é uma peça de developer experience bem-vinda para quem já vive trocando de editor local para notebook remoto, mas o limite de dez conexões por cluster e a queda de sessão em uma hora deixam claro que isso foi pensado para uso individual em desenvolvimento, não para virar um padrão de equipe inteira compartilhando poucos clusters. Vale testar antes de assumir que substitui Databricks Connect ou Asset Bundles no fluxo de CI/CD.

Fonte: https://learn.microsoft.com/en-us/azure/databricks/dev-tools/ssh-tunnel

#Databricks #DeveloperExperience #AzureDatabricks
