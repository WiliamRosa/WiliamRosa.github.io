---
title: "Um trigger novo nas Databricks Asset Bundles dispara o job assim que o deploy termina"
date: 2026-09-28T08:00:00-03:00
draft: true
tags: ["Databricks", "Databricks Asset Bundles", "Lakeflow Jobs", "DevOps"]
summary: "O trigger on_bundle_deploy em job_runs faz um job rodar automaticamente assim que uma Databricks Asset Bundle é implantada, sem agendamento externo, útil para DDL e povoamento único de tabela logo após o deploy."
ShowToc: false
---

Um job que só precisa rodar uma vez, logo depois do deploy, deixou de exigir gatilho manual ou agendamento avulso.

O Databricks MVP Hubert Dudek notou a chegada do trigger `on_bundle_deploy` dentro de `job_runs`, em uma Databricks Asset Bundle: basta declarar esse gatilho na definição do job para que ele dispare automaticamente assim que o bundle terminar de ser implantado.

O caso de uso é bem específico e resolve um incômodo recorrente de quem trabalha com DABs: tarefa de pós-deploy que hoje depende de rodar manualmente um notebook, clicar em "Run now" na UI, ou criar um job separado só para ser acionado por API depois do `databricks bundle deploy`. Coisas como aplicar uma DDL que só faz sentido depois que o schema já existe, ou povoar uma tabela de calendário uma única vez quando o ambiente sobe pela primeira vez, agora acontecem como parte do próprio ciclo de deploy, sem esse passo manual a mais.

Pontos técnicos que valem registrar:
- O trigger fica declarado no bloco `job_runs` da definição do job dentro da bundle
- Ele dispara automaticamente assim que o `databricks bundle deploy` termina com sucesso
- É indicado para tarefas de pós-deploy como DDL pontual ou povoamento único de tabela, não para jobs recorrentes
- Não substitui os triggers de schedule ou file arrival já existentes em Lakeflow Jobs, é um terceiro tipo de gatilho, ligado ao ciclo de vida do deploy

**Minhas considerações:** é o tipo de feature pequena que não vira manchete de keynote, mas resolve um atrito real de quem já perdeu tempo escrevendo script auxiliar só para rodar uma tarefa de inicialização depois do deploy. Vale revisar bundles existentes que hoje simulam esse comportamento com job separado acionado via API ou com passo manual documentado no runbook, porque esse tipo de gambiarra costuma ser esquecido até quebrar silenciosamente.

**Fonte:** https://www.linkedin.com/feed/update/urn:li:activity:7510094497561894913/

#Databricks #DatabricksAssetBundles #DataEngineering
