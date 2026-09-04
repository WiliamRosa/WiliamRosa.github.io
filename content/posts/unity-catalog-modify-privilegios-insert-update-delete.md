---
title: "MODIFY deixou de ser um privilégio só, e virou três: INSERT, UPDATE e DELETE"
date: 2026-08-29T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Governança", "Opinião"]
summary: "O privilégio MODIFY do Unity Catalog, antes tudo ou nada, ganhou privilégios filhos separados: INSERT, UPDATE e DELETE podem ser concedidos individualmente, com falha explícita quando um principal tenta operação fora do escopo."
ShowToc: false
---

Um job de ingestão que só devia inserir linha, mas também podia apagar tabela inteira: essa era a realidade de anos de MODIFY no Unity Catalog.

A Databricks MVP Gavita Regunath destacou uma mudança pequena na superfície, mas com impacto real em quem administra permissão de escrita no Unity Catalog: o privilégio MODIFY, que por anos era tudo ou nada, ganhou privilégios filhos separados, INSERT, UPDATE e DELETE.

Antes, conceder MODIFY para um job de ingestão significava dar a ele o poder de inserir linha, mas também de apagar coluna, truncar tabela ou reescrever schema inteiro, porque o Unity Catalog não distinguia esses casos. Com a mudança, dá pra conceder só o verbo que aquele workload realmente usa: um loader que só faz append recebe SELECT e INSERT e mais nada, e se algum dia tentar um DELETE ou um ALTER TABLE, a resposta vem como PERMISSION_DENIED em vez de suceder silenciosamente.

Pontos técnicos que valem registrar:
- MODIFY continua existindo, mas agora atua como agrupador dos três privilégios filhos
- INSERT, UPDATE e DELETE podem ser concedidos individualmente, sem liberar os outros dois
- Job de ingestão append-only passa a operar com o mínimo privilégio necessário, sem depender de disciplina manual pra não usar poder que não precisa
- Tentativa de operação fora do escopo concedido falha com PERMISSION_DENIED, não passa despercebida

**Minhas considerações:** esse é o tipo de mudança que não aparece em keynote, mas resolve um problema real de princípio de menor privilégio que toda auditoria de segurança cobra e poucas plataformas realmente entregam no nível certo de granularidade. Vale revisar hoje mesmo quem no seu workspace tem MODIFY concedido só porque era a única opção disponível, e trocar por INSERT, UPDATE ou DELETE conforme o que aquele principal realmente faz.

**Fonte:** https://dailydatabricks.tips/tips/Unity%20Catalog/FineGrainedDMLPrivileges.html

#Databricks #UnityCatalog #Governanca
