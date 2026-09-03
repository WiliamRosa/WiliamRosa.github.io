---
title: "Um Git folder inteiro passou a compartilhar um único ambiente serverless"
date: 2026-09-02T09:30:00-03:00
draft: false
tags: ["Databricks", "Azure Databricks", "Serverless", "Desenvolvimento"]
summary: "Git Folder Serverless (Beta) deixa notebook e arquivo do mesmo Git folder compartilharem um único compute serverless e um ambiente gerenciado por pyproject.toml, em vez de cada notebook subir seu próprio ambiente."
ShowToc: false
---

Abrir cinco notebooks do mesmo projeto e esperar cinco ambientes serverless subirem, cada um com sua própria lista de dependência, nunca fez muito sentido pra quem trabalha em múltiplos arquivos do mesmo repositório.

O Azure Databricks lançou em Beta o Git Folder Serverless: notebook e arquivo dentro do mesmo Git folder agora podem se conectar a um único recurso de compute serverless, com o ambiente Python gerenciado por um `pyproject.toml` na raiz da pasta em vez da configuração por notebook do serverless padrão. Só é possível usar essa opção dentro do editor de Git folder, e o requisito é ter `environment_version` 5 ou superior se já existir um `pyproject.toml`. Dependência nova entra de duas formas: rodando `%uv add <pacote>` seguido de `%uv sync` direto na célula, ou editando o `pyproject.toml` manualmente e clicando em Aplicar no editor. Um detalhe que separa isso de simplesmente "um cluster só pro projeto inteiro": variável Python de um notebook não fica visível em outro, cada arquivo ainda roda seu próprio estado, só o ambiente e o compute são compartilhados.

Pontos técnicos que valem atenção:
- Apenas assets dentro do mesmo Git folder conseguem anexar ao recurso de compute compartilhado
- Terminal web aberto a partir de qualquer notebook ou arquivo do folder roda no mesmo compute
- Só quem iniciou o compute consegue rodar workload nele, outro usuário que abrir o mesmo Git folder fica bloqueado
- Recomendação da Databricks pra colaboração é cada pessoa clonar o repositório na própria pasta pessoal, cada clone gera compute e ambiente próprios, a troca acontece via branch, commit e push
- Compartilhamento de compute fica restrito a uma mesma usage policy serverless, Git folder com política diferente ganha compute separado

**Minha ressalva:** a trava de um único usuário ativo por compute é a parte que mais chama atenção. Resolve o desperdício de subir ambiente repetido pro mesmo projeto, mas não resolve pair programming nem revisão em tempo real dentro do mesmo Git folder, que continua exigindo clone separado. Ainda em Beta, vale testar em projeto individual multi-arquivo antes de esperar isso resolver colaboração em equipe.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/compute/serverless/notebooks/git-folder-serverless

#Databricks #AzureDatabricks #Serverless
