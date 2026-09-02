---
title: "Genie Code virou um tipo de tarefa dentro de Job, e roda sozinho, sem parar pra perguntar nada"
date: 2026-08-31T11:00:00-03:00
draft: false
tags: ["Databricks", "GenieCode", "Automação", "Opinião"]
summary: "O novo Genie Code task type deixa rodar um agente autônomo dentro de um job agendado, a partir de um prompt em linguagem natural e com auto-aprovação sempre ligada."
ShowToc: false
---

Genie Code deixou de ser só uma conversa que você inicia manualmente e virou um tipo de tarefa dentro de um Job do Databricks.

O Databricks MVP Derar Alhussein destacou a novidade assim que ela saiu: o Genie Code task inicia um novo chat a partir de um prompt em linguagem natural e produz uma resposta sozinho, lendo dado, chamando ferramenta e agindo sobre o pedido sem exigir aprovação adicional durante a execução. Depois que o job termina, ainda dá pra abrir o chat e continuar interagindo com o histórico daquela execução.

O caso de uso central é automação de análise complexa dentro de uma rotina agendada: resumir o resultado de jobs que rodaram de madrugada e mandar um relatório por e-mail, analisar dado novo e sinalizar anomalia, investigar um ticket do Jira e propor correção, gerar auditoria de compliance semanal. Como é sempre auto-aprovado dentro de um job, o Databricks compensa isso com um classificador de IA que avalia cada ação contra o prompt original e bloqueia operação que sai do escopo pretendido.

Pontos técnicos que valem registrar:
- Auto-aprovação é sempre ligada em tarefa de job, não é uma opção, é o comportamento padrão
- Um classificador de IA (não uma barreira determinística) decide o que conta como ação arriscada demais pro escopo do prompt
- Recurso ainda em Beta, admin de workspace controla o acesso pela página de Previews

**Minha ressalva:** já escrevi aqui antes sobre o modo de auto-aprovação do Genie Code fora de job, e a mesma ressalva vale, e pesa mais dentro de uma automação agendada: quem decide o que é "arriscado" é um classificador de IA, não uma regra fixa e auditável. Rodando dentro de um job que ninguém está acompanhando ao vivo, esse é exatamente o tipo de cenário em que um falso negativo do classificador passa despercebido até o relatório final chegar errado na caixa de entrada de alguém.

**Fonte:** https://docs.databricks.com/aws/en/jobs/tasks/genie-code

#Databricks #GenieCode #Automação
