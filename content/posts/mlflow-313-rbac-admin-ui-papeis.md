---
title: "MLflow 3.13 trocou permissão por recurso avulso por um sistema de papéis com UI própria de admin"
date: 2026-10-04T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "MLflow", "Governança"]
summary: "O Databricks MVP Juan Diaz destacou o RBAC completo do MLflow 3.13: papel reutilizável com permissão agrupada, UI de admin via navegador e matriz de permissão cobrindo experimento, modelo e artefato, fechando uma lacuna de quem hospeda o próprio MLflow em vez de pagar por plataforma gerenciada só por causa de controle de acesso."
ShowToc: false
---

O Databricks MVP Juan Diaz apontou uma mudança que resolve um problema clássico de quem mantém MLflow auto-hospedado: controle de acesso que sempre ficou um passo atrás do que uma plataforma gerenciada oferece de fábrica.

O MLflow 3.13 substitui o antigo modelo de permissão por recurso avulso por um sistema completo de Role-Based Access Control. Em vez de conceder acesso individual a cada experimento ou modelo, um papel agrupa um conjunto de permissões reutilizável, que depois é atribuído a usuário ou a grupo. O acesso efetivo de alguém passa a ser a união de todos os papéis que essa pessoa tem no workspace.

Pontos técnicos da mudança:

- Uma UI de administração própria, acessível por navegador, substitui a necessidade de chamar endpoint REST manualmente pra gerenciar usuário, papel e concessão de acesso
- A cobertura de permissão se estende a experimento, modelo registrado, prompt, scorer e recurso do AI Gateway (segredo, endpoint ou definição de modelo), não só a experimento e modelo como no esquema antigo
- `default_permission` deixa de funcionar como permissão que pode ser sobrescrita e passa a atuar como piso mínimo de acesso
- Conceder permissão continua exigindo MANAGE sobre aquele recurso específico, ou condição de Platform Admin, então dono de um experimento consegue conceder acesso a ele sem precisar de MANAGE no workspace inteiro
- A tabela antiga de permissão por recurso e os métodos de cliente que dependiam dela foram removidos; uma migration de banco faz o backfill automático pra dentro da nova tabela `role_permissions` na atualização

**Minha leitura:** o ganho real aqui não é a permissão em si, é fechar a última desculpa real pra não auto-hospedar MLflow. Antes, abrir mão de uma plataforma gerenciada significava abrir mão de controle de acesso decente, e agora essa troca deixou de existir. Quem mantém MLflow próprio hoje devia revisar se ainda está usando o esquema de permissão por recurso avulso, porque esse caminho antigo foi removido, não só descontinuado, e a migração de API quebra código que dependia dos métodos antigos.

**Fonte:** https://mlflow.org/releases/3.13.0/

#AzureDatabricks #MLflow #Governanca
