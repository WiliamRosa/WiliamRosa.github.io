---
title: "Agora dá pra negar permissão de administrar permissão, mesmo pro dono do objeto"
date: 2026-09-09T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "ABAC", "Governança", "Azure Databricks"]
summary: "ABAC DENY policies chegaram em beta no Unity Catalog: uma política pode negar explicitamente o privilégio MANAGE ACCESS CONTROL a um principal específico, incluindo o dono do objeto, e essa negação sempre tem prioridade sobre qualquer concessão."
ShowToc: false
---

Até hoje, ser dono de uma tabela significava poder mudar quem mais tem acesso a ela. Isso deixou de ser garantido.

O Azure Databricks lançou ABAC DENY policies em beta no Unity Catalog. A política DENY permite negar explicitamente o privilégio MANAGE ACCESS CONTROL a principal específico, incluindo o próprio dono do objeto, impedindo que esse principal faça operação de gestão de acesso mesmo tendo outros privilégios amplos. A regra central é que negação sempre tem prioridade sobre qualquer concessão, não importa de onde a concessão veio.

Pontos técnicos que valem atenção:
- DENY policies operam dentro do modelo ABAC já existente no Unity Catalog, ao lado de row filter, column mask e Context Attributes
- Alvo específico é o privilégio MANAGE ACCESS CONTROL, não acesso a dado em si
- Vale até para o dono do objeto, que normalmente teria controle total sobre ele
- Negação sempre prevalece sobre concessão, independente de qual regra foi criada por último

**Minhas considerações:** esse recurso resolve um problema de governança que ABAC baseado só em concessão nunca resolveu bem: às vezes você precisa impedir uma ação específica de um principal específico sem reescrever toda a árvore de permissão dele. O risco prático é o oposto, negação explícita e silenciosa pode virar um mistério de "por que ninguém consegue mudar permissão nessa tabela" seis meses depois, se a política DENY não estiver documentada tão bem quanto uma concessão normalmente é.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/abac/deny-policies

#Databricks #UnityCatalog #Governanca
