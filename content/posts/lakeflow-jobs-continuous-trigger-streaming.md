---
title: "Lakeflow Jobs ganhou trigger contínuo pra job de streaming parar de depender de gambiarra de CRON"
date: 2026-09-14T11:00:00-03:00
draft: true
tags: ["Databricks", "Lakeflow", "Streaming", "Opinião"]
summary: "O trigger continuous transforma um Lakeflow Job em serviço always-on que reinicia sozinho assim que termina ou falha, delegando pra Databricks a responsabilidade de manter o job rodando sem interrupção, em vez de forçar CRON ou trigger orientado a evento a fazer papel de scheduler contínuo."
ShowToc: false
---

O Databricks MVP Bartosz Konieczny mostrou como o novo trigger continuous resolve um desconforto antigo de quem roda job de streaming no Lakeflow.

Trigger de CRON e trigger orientado a evento nunca foram desenhados pra sustentar um job que, por definição, deveria rodar sem parar. A saída de sempre era forçar um agendamento curtíssimo pra simular continuidade, o que na prática significava reinício desnecessário e gerenciamento manual de retomada depois de falha. O trigger continuous inverte isso: ao ser declarado, o job vira um serviço always-on que reinicia automaticamente assim que uma execução termina ou falha, sem esperar próximo horário de agendamento.

A configuração acontece direto no Databricks Asset Bundle, com o bloco `continuous` definindo `pause_status: UNPAUSED` e `task_retry_mode: ON_FAILURE`, esse último garantindo que tarefa individual dentro de um job com múltiplas tarefas seja reiniciada sozinha com backoff exponencial em caso de falha, em vez de deixar aquele pedaço específico do pipeline parado sem ninguém perceber.

Pontos técnicos que valem registrar:

- Declaração via Databricks Asset Bundle, bloco `continuous` com `pause_status` e `task_retry_mode`
- Cada reinício provisiona cluster novo, o que introduz latência que pode pressionar SLA e acumular dado não processado durante a janela de restart
- `task_retry_mode: ON_FAILURE` aplica retry com backoff exponencial por tarefa, essencial em job multi-tarefa
- Job contínuo não deve misturar trigger `Available Now` com `Processing Time` na mesma definição, porque gera conflito de dependência entre tarefas

**Minhas considerações:** delegar a orquestração de "rodar pra sempre" pro próprio Databricks é um ganho de manutenção real frente a manter um CRON job fingindo ser contínuo. O ponto que merece atenção antes de migrar pipeline crítico é o provisionamento de cluster novo a cada reinício, porque isso significa que falha frequente numa tarefa específica pode virar um ciclo caro de reprovisionamento em vez de simplesmente retomar processamento onde parou.

Fonte: https://www.waitingforcode.com/databricks/continuous-trigger-lakeflow-jobs/read

#Databricks #Lakeflow #AzureDatabricks
