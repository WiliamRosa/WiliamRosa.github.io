---
title: "Alerta SQL virou tarefa dentro do Job, e agora dá pra ramificar o fluxo a partir do resultado dele"
date: 2026-09-02T11:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow Jobs", "Automação", "Opinião"]
summary: "O Databricks MVP Juan Diaz notou que o Lakeflow Jobs agora aceita alerta SQL como tipo de tarefa, expondo o estado da avaliação como saída pra tarefa seguinte decidir o próximo passo com um If/Else."
ShowToc: false
---

O Databricks MVP Juan Diaz apontou uma mudança pequena de configuração com efeito grande em quem já tem alerta demais que ninguém trata: o alerta SQL virou um tipo de tarefa dentro do Lakeflow Jobs.

Até então, alerta SQL vivia isolado, rodava sua consulta, checava a condição e mandava notificação, sem se conectar ao resto de um pipeline. Agora ele pode entrar como uma tarefa dentro do Job: a consulta roda no SQL warehouse configurado, a condição é avaliada, e o estado da avaliação, `OK`, `TRIGGERED` ou `ERROR`, fica disponível como valor de saída pra tarefa seguinte referenciar. Na prática isso abre espaço pra construir uma tarefa If/Else logo depois do alerta, com condição do tipo `{{tasks.Alert-FraudRateCheck.output.alert_state}} == "TRIGGERED"`, decidindo automaticamente se o fluxo segue direto, dispara uma tarefa de correção ou interrompe outra etapa.

Um detalhe importa pra quem for configurar isso: a tarefa de alerta reporta status "Succeeded" sempre que consegue avaliar a condição, independente do alerta ter disparado ou não. Quem quer reagir ao disparo precisa ler o valor de saída explicitamente, não dá pra confiar só no status da tarefa pra saber se algo deu errado.

Pontos técnicos que valem atenção:
- Estado da avaliação sai como `OK`, `TRIGGERED` ou `ERROR`, acessível como saída da tarefa
- Tarefa If/Else consegue ramificar com base nesse valor, por exemplo `{{tasks.<nome>.output.alert_state}} == "TRIGGERED"`
- Tarefa de alerta reporta "Succeeded" mesmo quando o alerta dispara, o status por si só não indica problema
- Tarefa de alerta SQL não aceita parâmetro, uma limitação a considerar no desenho do Job

**Minha ressalva:** o ponto que mais merece atenção é justamente o status "Succeeded" mascarando um alerta disparado. Sem montar explicitamente a ramificação com base no valor de saída, um Job inteiro pode terminar "verde" no monitoramento mesmo com uma condição crítica acionada lá dentro, o que é o oposto do que se espera de um alerta.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/jobs/tasks/alert

#Databricks #LakeflowJobs #Automação
