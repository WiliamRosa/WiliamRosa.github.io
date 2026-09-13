---
title: "`databricks environments setup-local` sincroniza venv local com a versão exata do compute remoto"
date: 2026-09-13T14:00:00-03:00
draft: false
tags: ["Databricks", "CLI", "Developer Experience", "Opinião"]
summary: "O comando resolve o compute alvo, seja cluster clássico ou serverless, descobre a versão de Python e de databricks-connect fixadas pra aquele ambiente e provisiona um .venv gerenciado por uv já casado com essas versões, atualizando o pyproject.toml com backup automático em pyproject.toml.bak."
ShowToc: false
---

O Databricks MVP Daniel Sahal apontou pra um comando de CLI que ataca um tipo de bug clássico: código que funciona local e quebra ao rodar no Databricks só por diferença de versão de Python ou de biblioteca.

O `databricks environments setup-local` resolve o compute de destino, seja cluster clássico com Databricks Runtime específico ou ambiente serverless versionado, busca a versão de Python e de `databricks-connect` fixadas pra aquele alvo junto com as restrições de dependência publicadas, e a partir disso provisiona ou atualiza um `.venv` gerenciado por `uv` já alinhado com esse ambiente remoto. Isso fecha o gap entre "funciona no meu notebook local" e "quebra no cluster" que sempre exigiu ajuste manual de versão toda vez que o time trocava de runtime.

O comando também sabe lidar com projeto que já existe: ao rodar num projeto com `pyproject.toml`, ele faz o merge das mudanças necessárias no arquivo em vez de sobrescrever, e grava um backup em `pyproject.toml.bak` pra permitir revisão ou reversão manual antes de aceitar a mudança definitivamente.

Pontos técnicos:

- Resolve o compute alvo pra uma chave de ambiente, buscando versão de Python, versão de `databricks-connect` e restrição de dependência publicadas pra essa chave
- Provisiona `.venv` via `uv` já casado com Databricks Runtime do cluster ou versão do ambiente serverless
- Em projeto existente, faz merge no `pyproject.toml` e grava backup em `pyproject.toml.bak`
- Se `uv python install` falhar, cai automaticamente pra um interpretador Python compatível já instalado na máquina
- Reporta código de erro distinto (`E_PROVISION_CONFLICT`) quando dependência do projeto conflita com a versão fixada pro ambiente alvo
- Flag `--constraints-only` foi descontinuada em favor de `--no-dbconnect`; novas flags `--no-constraints` e `--no-dbconnect` permitem pular escrita de pin de versão ou dependência de `databricks-connect`, respectivamente

**Minha ressalva:** merge automático em `pyproject.toml`, mesmo com backup, é o tipo de operação que vale revisar via diff antes de commitar, principalmente em projeto com dependência já fixada manualmente por outro motivo que não seja compatibilidade com Databricks. O backup evita perda de dado, mas não evita que uma mudança automática passe despercebida num pull request maior.

Fonte: https://github.com/databricks/cli/releases

#Databricks #CLI #AzureDatabricks
