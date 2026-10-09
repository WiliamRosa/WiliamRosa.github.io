---
title: "Um job do Lakeflow agora pode esperar por até cinco gatilhos diferentes ao mesmo tempo"
date: 2026-10-09T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Lakeflow Jobs", "Opinião"]
summary: "O Databricks MVP Derar Alhussein destacou o suporte a múltiplos gatilhos (Beta) no Lakeflow Jobs: um job pode combinar até cinco triggers de tipos iguais ou diferentes, cada um pausável de forma independente, e qualquer um que disparar inicia a execução."
ShowToc: false
---

O Databricks MVP Derar Alhussein destacou que o Lakeflow Jobs passou a aceitar múltiplos gatilhos num único job, uma mudança pequena na superfície mas que resolve uma limitação incômoda de quem combinava gatilho via workaround.

Antes, cada job vivia preso a um único tipo de gatilho configurado por vez, agendamento, atualização de tabela, chegada de arquivo, atualização de modelo ou execução contínua. Agora, em Beta, um job pode somar até cinco gatilhos, iguais ou de tipos diferentes, e qualquer um deles que avaliar como verdadeiro já dispara a execução. O caso de uso mais direto é redundância: usar um gatilho de atualização de tabela como caminho principal e um gatilho agendado como backup, garantindo que o job rode mesmo se o sinal de atualização de tabela falhar silenciosamente. Outro caso é monitorar múltiplos locais de armazenamento diferentes, cada um com seu próprio gatilho de chegada de arquivo, sem precisar duplicar o job inteiro pra cada pasta.

Pontos técnicos do recurso:

- Cada gatilho pode ser pausado e retomado de forma independente dos demais
- Gatilho contínuo não pode ser combinado com nenhum outro, porque o job já roda sem parar
- Configuração via API usa o array `triggers` dentro de `JobSettings`, e não pode ser misturada na mesma requisição com os campos legados `schedule`, `trigger` ou `continuous`
- Atualizar o array `triggers` substitui a lista inteira, não faz merge incremental
- Durante o Beta, admin do workspace precisa habilitar o recurso na página de Previews, com a opção "Multiple Triggers"
- O limite de 12 mil gatilhos ativos por workspace, contando todos os tipos, continua valendo com ou sem o Beta habilitado

**Minhas considerações:** o ganho real aqui é reduzir gambiarra, antes resolver "dispara por atualização de tabela, mas com um agendamento de segurança por trás" exigia dois jobs separados ou lógica externa de orquestração. A contrapartida é debugging: quando um job com cinco gatilhos ativos dispara, descobrir qual gatilho especificamente causou aquela execução vira uma pergunta a mais pra responder durante investigação de incidente, vale já pensar em como o log de execução identifica a origem antes de espalhar múltiplos gatilhos pelos jobs mais críticos.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/jobs/triggers#add-multiple-triggers-to-a-job

#AzureDatabricks #LakeflowJobs #Databricks
