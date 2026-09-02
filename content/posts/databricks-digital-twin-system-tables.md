---
title: "Um MVP transformou o próprio histórico de uso do Databricks num gêmeo digital"
date: 2026-08-13T09:00:00-03:00
draft: false
tags: ["Databricks", "SystemTables", "IA", "Opinião"]
summary: "O projeto Databricks Digital Persona lê 90 dias de system tables (query history, jobs, billing, auditoria) e usa isso pra construir um agente que conversa como se fosse você."
ShowToc: false
---

E se o histórico de uso do seu workspace Databricks fosse suficiente pra construir um agente que pensa como você?

O Databricks MVP Aarni Sillanpää construiu o Databricks Digital Persona, um projeto que lê 90 dias de atividade em mais de 8 system tables (auditoria, histórico de query, execução de job, dado de billing) através de 15 etapas de análise, e usa isso pra classificar o usuário entre arquétipos de comportamento (algo como "arquiteto de pipeline", "explorador de dado", "guardião de plataforma") e gerar um perfil com badges de conquista.

A parte mais curiosa é o passo seguinte: o projeto usa esse perfil pra montar um system prompt em primeira pessoa que captura a personalidade e a especialidade técnica de quem gerou os dados, criando um "gêmeo digital" com quem dá pra conversar diretamente dentro de um app Databricks. Tecnicamente, roda como Databricks App com autenticação on-behalf-of-user, ou seja, cada consulta às system tables acontece sob a permissão de quem está usando, sem credencial compartilhada.

O que chama atenção no projeto:
- Nenhum dado sai do workspace, a análise inteira acontece em cima de system tables que já existem
- Autenticação OBO garante isolamento: cada usuário só vê o próprio histórico, nunca o de outra pessoa
- O projeto tem 90 testes cobrindo pontuação, segurança, isolamento de dado e rotas, sinal de que não é só uma prova de conceito descartável

**Minhas considerações:** o valor real disso não é o gêmeo digital em si, é lembrar que system tables guardam muito mais sinal comportamental do que a maioria dos times usa. A maior parte das empresas trata query history e billing como dado só de auditoria ou custo, quando dá pra extrair daí padrão de uso, especialização de time e até risco de dependência de uma única pessoa em um pipeline crítico. Vale menos pelo gêmeo digital e mais pelo lembrete: você provavelmente está sentado em cima de mais dado de comportamento do que imagina.

**Fonte:** https://github.com/ikidata/databricks-digital-persona

#Databricks #SystemTables #AIAgents
