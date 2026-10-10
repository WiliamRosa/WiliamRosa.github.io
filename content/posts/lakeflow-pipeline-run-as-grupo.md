---
title: "Pipeline do Lakeflow agora pode rodar como grupo, não só como usuário ou service principal"
date: 2026-10-06T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Lakeflow", "Governança"]
summary: "A identidade run-as de uma pipeline do Lakeflow agora aceita um grupo de conta, além de usuário e service principal: atualização da pipeline passa a rodar com a permissão do grupo, e a propriedade das tabelas publicadas acompanha essa mesma identidade, útil pra time inteiro ser dono de uma pipeline automatizada."
ShowToc: false
---

Pipeline do Lakeflow configurada pra rodar como usuário individual sempre teve o mesmo risco estrutural: a pessoa muda de time, é desativada, ou sai da empresa, e a pipeline para de funcionar junto, levando as tabelas que ela publica pra um estado de acesso incerto. A prática recomendada já era rodar como service principal justamente pra evitar isso, mas isso ainda deixava a pipeline amarrada a uma identidade única, não a um time.

Agora a identidade run-as aceita diretamente um grupo de conta, do mesmo jeito que já aceitava usuário ou service principal. Atualização da pipeline passa a rodar com a permissão do grupo, e em pipeline que usa Unity Catalog a propriedade das tabelas publicadas também passa pro grupo, não fica mais amarrada a uma pessoa.

O que muda na prática:

- O grupo precisa ser um grupo de conta associado ao workspace, não um grupo local do workspace, e não pode ser um dos grupos amplos embutidos (`admins`, `users`, `account users`)
- Quem configura precisa ser membro do grupo ou ter permissão Assume sobre ele, se o grupo usa acesso exclusivo
- O grupo precisa receber, ele mesmo, todas as permissões que a pipeline exige (acesso de workspace, leitura de notebook, USE CATALOG, USE SCHEMA, CREATE TABLE, MODIFY), ter acesso você mesmo não é suficiente
- Via API REST, o campo é `run_as.group_name` na criação, ou `updated_run_as.group_name` numa atualização de pipeline existente
- Via Declarative Automation Bundles, o mesmo grupo entra em `run_as.group_name` dentro do recurso de pipeline no bundle
- Trocar o run-as não muda quem é o owner da pipeline, são dois atributos separados, e `SET OWNER TO` via SQL não funciona pra atribuir grupo como owner de materialized view ou streaming table, isso só pela UI
- Job do Lakeflow ganhou o mesmo suporte equivalente pra run-as em grupo

**Minhas considerações:** isso resolve um problema real de ciclo de vida organizacional, pipeline crítica não devia depender de uma pessoa específica continuar ativa na empresa, mas a configuração correta exige disciplina que muita equipe vai pular na pressa: garantir que o grupo em si tem todas as permissões listadas, e não assumir que "eu tenho acesso, então o grupo também tem" só porque eu sou membro dele. Vale revisar pipeline crítica hoje rodando como usuário individual e migrar pra grupo antes que a saída de alguém force essa migração em caráter de emergência.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/ldp/configure-pipeline#run-as-group

#AzureDatabricks #Lakeflow #Governanca
