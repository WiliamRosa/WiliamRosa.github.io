---
title: "Retenção de system table agora é escolha sua, não mais um número fixo"
date: 2026-09-10T09:00:00-03:00
draft: false
tags: ["Databricks", "System Tables", "Governança", "Azure Databricks"]
summary: "Administradores da conta agora conseguem configurar, em beta, um período de retenção entre 30 e 3.650 dias pras system tables suportadas, em vez de depender do período fixo padrão da plataforma."
ShowToc: false
---

Auditoria de longo prazo em cima de system table sempre esbarrou no mesmo limite: o dado simplesmente não ficava disponível por tempo suficiente.

O Azure Databricks lançou, em beta, retenção configurável pra system tables suportadas. Administradores da conta agora conseguem definir um período de retenção entre 30 e 3.650 dias, no nível da conta inteira, em vez de ficar preso ao comportamento padrão da plataforma. Isso muda o cálculo pra qualquer time que precisa manter histórico de uso, custo ou auditoria por período mais longo do que o default cobria.

Pontos técnicos:
- Período de retenção configurável vai de 30 a 3.650 dias
- Configuração é feita no nível da conta, por administrador
- Aplica-se às system tables que suportam esse controle
- Recurso está em beta

**Minhas considerações:** esse tipo de ajuste parece pequeno, mas resolve uma dor recorrente de quem monta relatório de FinOps ou auditoria de compliance em cima de system table e descobre, tarde demais, que o dado de seis meses atrás já não existe mais. A ressalva óbvia é custo: reter mais de nove anos de histórico de query, se alguém configurar o teto de 3.650 dias sem pensar, tem impacto de armazenamento que vale simular antes de aplicar em produção.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/admin/system-tables/

#Databricks #Governanca #SystemTables
