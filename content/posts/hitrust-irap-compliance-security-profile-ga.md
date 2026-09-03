---
title: "HITRUST e IRAP viram GA no Azure Databricks, e o perfil de segurança de compliance passa a ser obrigatório"
date: 2026-09-02T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Governança", "Compliance", "Seguranca"]
summary: "Controles de compliance HITRUST e IRAP atingiram disponibilidade geral no Azure Databricks em setembro de 2026, e a partir de agora HIPAA, HITRUST e IRAP exigem o compliance security profile ativado, deixou de ser configuração opcional pra quem já usa esses padrões."
ShowToc: false
---

Uma mudança de "opcional" pra "obrigatório" em regra de compliance costuma passar despercebida até travar um workspace em produção.

A Microsoft confirmou nas release notes de setembro de 2026 que os controles de compliance HITRUST e IRAP chegaram à disponibilidade geral no Azure Databricks, via compliance security profile. A parte que exige atenção não é a GA em si, é a mudança de regra que vem junto: a partir de agora, workspace que processa dado sob HIPAA, HITRUST ou IRAP precisa ter o compliance security profile ativado, deixou de ser recomendação, virou pré-requisito.

Compliance security profile é o mecanismo do Azure Databricks que aplica um conjunto de controle técnico (rede, monitoramento, hardening) necessário pra atender padrão regulatório específico. Até aqui, HITRUST e IRAP estavam em estágio anterior à disponibilidade geral, o que deixava equipe de segurança em zona cinzenta sobre se podia depender disso pra certificação formal.

Pontos técnicos que valem atenção:
- HITRUST (saúde, padrão americano) e IRAP (Infosec Registered Assessors Program, padrão australiano de governo) agora em disponibilidade geral
- Compliance security profile passa a ser exigência, não opção, pra workspace sob HIPAA, HITRUST ou IRAP
- Mudança vale a partir de 1º de setembro de 2026
- Sem prazo de carência mencionado nas release notes pra quem já roda workspace sob esses padrões sem o perfil ativado

**Minha ressalva:** toda vez que um requisito de compliance muda de opcional pra obrigatório, o risco real não é técnico, é operacional, alguém que já certificou o ambiente sob a regra antiga e não percebeu a mudança de status até uma auditoria travar. Vale checar agora se algum workspace sob HIPAA, HITRUST ou IRAP na sua conta ainda está sem o compliance security profile ligado, antes que isso vire problema de auditoria.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#hitrust-and-irap-compliance-controls-are-now-generally-available

#AzureDatabricks #Compliance #Governanca
