---
title: "Testei o beta de Policies no Unity AI Gateway — e a barreira ainda deixa passar coisa que não devia"
date: 2026-08-26T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity AI Gateway", "Governança", "Opinião"]
summary: "O Databricks MVP Josue Bogran testou o recurso de Policies (ainda em beta) do Unity AI Gateway com Omnigent, e encontrou casos onde as barreiras deveriam ter sido mais rigorosas."
ShowToc: false
---

O Databricks MVP Josue "Josh" Bogran testou o recurso de Policies do Unity AI Gateway — ainda em beta — combinado com o Omnigent, adicionando camadas de proteção contra uso de IA arriscado ou fora de conformidade. Durante os testes, ele encontrou casos onde as barreiras (guardrails) deveriam ter sido mais rigorosas do que realmente foram, e já repassou esse retorno para a equipe da Databricks.

Isso confirma algo que quem acompanha governança de IA já esperava: sair do "faroeste de IA" pra um modelo com controles de acesso, políticas e custo é o caminho certo, mas uma feature em beta que promete barreira de segurança precisa ser testada sob condição adversária antes de virar dependência crítica — não só sob o caminho feliz.

Por que esse tipo de teste importa mais do que o anúncio da feature em si:
- Beta significa exatamente isso: ainda não é confiável o suficiente pra tratar como controle definitivo
- Um MVP testando ativamente e reportando gap pra Databricks é o processo de maturação da feature funcionando como deveria
- Quem já está usando Policies em produção (mesmo em beta) precisa saber que existem brechas conhecidas, não descobrir isso sozinho depois de um incidente

**Minha ressalva:** "beta com gap conhecido" é diferente de "beta pronto pra teste de estresse mais sério" — a diferença entre os dois só fica clara quando mais gente testa e reporta, como o Josue fez aqui. Antes de colocar Policies do Unity AI Gateway como única camada de proteção pra uso de IA sensível, eu manteria um controle complementar (revisão humana, ou um segundo gateway/proxy com regra própria) até a feature sair de beta com um histórico mais robusto de testes adversariais da comunidade.

**Fonte:** https://www.linkedin.com/in/josuebogran/

#Databricks #UnityAIGateway #GovernançaDeIA
