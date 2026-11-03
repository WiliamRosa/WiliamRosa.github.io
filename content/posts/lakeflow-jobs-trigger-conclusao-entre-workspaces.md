---
title: "Um Lakeflow Job agora pode esperar outro job terminar mesmo em workspace diferente"
date: 2026-11-02T12:00:00-03:00
draft: true
tags: ["Lakeflow Jobs", "Azure Databricks", "Orquestracao"]
summary: "O Databricks MVP Soufiane Darraz destacou os job completion triggers do Lakeflow Jobs, em Beta: um job downstream dispara quando jobs upstream terminam, mesmo espalhados por workspaces diferentes, desde que compartilhem o mesmo metastore do Unity Catalog."
ShowToc: false
---

Um job agora pode esperar outro job terminar mesmo que ele viva num workspace completamente diferente.

O Databricks MVP Soufiane Darraz destacou os job completion triggers do Lakeflow Jobs, em Beta: um job downstream passa a disparar quando um ou mais jobs upstream terminam, mesmo que esses jobs upstream estejam espalhados por workspaces diferentes, desde que todos compartilhem o mesmo metastore do Unity Catalog.

O mecanismo monitora de 1 a 10 pares workspace e job, e aplica o mesmo filtro de resultado a todos eles ao mesmo tempo, sucesso, falha ou qualquer conclusão. Com mais de um job monitorado, o trigger só dispara quando todos tiverem uma nova conclusão que bate com o filtro, não a cada conclusão isolada, o que exige pensar no desenho como uma barreira de sincronização, não como soma de eventos independentes. A identidade run-as do job downstream precisa estar presente em cada workspace upstream com permissão de visualização sobre o job monitorado, já que o trigger roda com a permissão de quem executa o job, não de quem configurou.

Pontos técnicos que valem atenção:
- Monitora até 10 pares workspace e job por trigger, com filtro único de resultado (SUCCESS, FAILED ou DONE) aplicado a todos
- Exige workspace admin habilitando o preview em cada workspace envolvido, upstream e downstream
- Conclusão passada não dispara o trigger na ativação, só conclusão nova a partir dali
- Parâmetro upstream_completions expõe workspace_id, job_id, run_id e termination_code de cada job monitorado pra tarefa seguinte consumir
- Limite de 1.000 triggers de conclusão ativos por workspace, dentro do limite geral de 12.000 triggers ativos

**Minha ressalva:** sincronizar múltiplos upstream como barreira, não como OR, é um detalhe fácil de passar batido na primeira leitura da documentação, e decide se o pipeline dispara na hora certa ou fica esperando um job que talvez nunca rode naquele ciclo. Pra disparar em qualquer conclusão, a documentação recomenda configurar um trigger separado por job, o que já é outro nível de complexidade de manutenção.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/jobs/job-completion-triggers

#LakeflowJobs #AzureDatabricks #Orquestracao
