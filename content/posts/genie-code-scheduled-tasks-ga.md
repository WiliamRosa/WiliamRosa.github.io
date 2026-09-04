---
title: "Genie Code agora roda sozinho num horário fixo, sem ninguém abrir o chat"
date: 2026-09-02T10:00:00-03:00
draft: false
tags: ["Databricks", "Genie Code", "Azure Databricks", "Opinião"]
summary: "O agendamento de tarefas do Genie Code chegou à disponibilidade geral no Azure Databricks: dá pra configurar um prompt fixo pra rodar numa recorrência, gerando um chat continuável a cada execução."
ShowToc: false
---

Agendar o Genie Code pra rodar todo dia de madrugada e te entregar um relatório pronto quando você chega no trabalho já é possível.

A Databricks tornou geralmente disponível o agendamento de tarefas do Genie Code no Azure Databricks. Antes, cada sessão do Genie Code dependia de alguém abrir o chat e digitar o prompt; agora dá pra configurar um prompt fixo pra rodar numa recorrência definida, sem intervenção manual.

Cada execução agendada dispara uma sessão completa do Genie Code, com o mesmo prompt de sempre, e produz um chat continuável com o resultado, então quem chega depois pode abrir aquela conversa e seguir interagindo com o agente a partir de onde ele parou, em vez de só ler um log estático. A configuração acontece direto no chat do Genie Code ou no menu de Schedules, sem precisar orquestrar isso via job externo.

Pontos técnicos que valem registrar:
- Disponibilidade geral a partir de 1 de setembro de 2026
- Cada execução cria uma sessão completa de Genie Code, com histórico continuável, não só um log de texto
- Configuração pelo próprio chat do Genie Code ou pelo menu de Schedules
- Casos de uso descritos: resumir resultado de job noturno, investigar ticket, gerar auditoria de conformidade recorrente

**Minhas considerações:** transformar prompt em tarefa agendada é o tipo de feature pequena que muda o hábito de uso. A diferença entre "pergunto quando lembro" e "isso roda sozinho toda noite" é grande, mas também levanta a pergunta de quem revisa o resultado quando ninguém pediu a execução daquela vez. Vale pensar no agendamento de Genie Code como mais um job de produção que precisa de dono e de alerta de falha, não como um chat que só acontece de forma automática.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#genie-code-scheduled-tasks-are-now-generally-available

#Databricks #GenieCode #AzureDatabricks
