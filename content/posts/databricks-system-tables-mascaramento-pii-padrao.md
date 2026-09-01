---
title: "Chega de manter view própria só pra esconder dado sensível das system tables"
date: 2026-09-01T14:45:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Governança", "Segurança", "Opinião"]
summary: "Dados potencialmente sensíveis em query.history e request_params agora vêm mascarados por padrão nas system tables, liberando acesso amplo sem expor informação sensível a quem não deveria ver."
ShowToc: false
---

O Databricks MVP Casper Lubbers notou uma mudança silenciosa nas system tables do Databricks: informação potencialmente sensível — tanto em `query.history` quanto em alguns `request_params` onde detalhes de query ficam guardados — agora vem mascarada por padrão. Pra ver o dado sem máscara, é preciso fazer parte do grupo `databricks_pii_access`.

Isso resolve um problema prático que qualquer time de plataforma que já trabalhou com system tables conhece bem: historicamente, a única forma seguindo de dar acesso amplo às system tables (fundamentais pra responder perguntas como "quanto isso está me custando" ou "quem fez X") era manter uma view própria por cima, filtrando manualmente o que era sensível antes de liberar pro resto da organização.

Por que essa mudança elimina trabalho real de manutenção:
- Views customizadas pra mascarar dado sensível são exatamente o tipo de camada que ninguém lembra de atualizar quando o schema da system table muda
- Mascaramento por padrão, com controle de acesso baseado em grupo, é o modelo que já funciona bem pro resto dos dados no Unity Catalog — aplicado agora ao próprio metadado operacional da plataforma
- Sem a necessidade de view intermediária, mais gente na organização pode ter acesso direto às system tables pra responder perguntas de custo e uso, sem esperar que alguém do time de plataforma libere acesso caso a caso

**Minha ressalva:** mascaramento por padrão é uma boa mudança, mas "por padrão" também significa que times que já tinham processos de auditoria dependendo do dado não-mascarado (por exemplo, investigação de segurança que precisa ver o texto completo de uma query suspeita) agora precisam garantir explicitamente que as pessoas certas estão no grupo `databricks_pii_access` — é fácil essa mudança quebrar silenciosamente um processo de auditoria existente até alguém notar que o dado sumiu da view.

**Fonte:** https://www.linkedin.com/in/casper-lubbers/

#Databricks #UnityCatalog #Governança
