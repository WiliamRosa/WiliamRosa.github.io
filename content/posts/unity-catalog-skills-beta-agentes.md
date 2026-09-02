---
title: "Skill de agente virou um objeto do Unity Catalog, com dono, permissão e auditoria"
date: 2026-08-29T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Agentes", "Opinião"]
summary: "Unity Catalog Skills (Beta) trata skill de agente como securable de três níveis, catalog.schema.skill, com as mesmas permissões e tags que já protegem tabela. O Databricks MVP Hubert Dudek notou a mudança antes do anúncio oficial confirmar."
ShowToc: false
---

O Databricks MVP Hubert Dudek percebeu, direto na interface, que uma peça nova apareceu para gerenciar skills de agente antes mesmo da documentação oficial confirmar o recurso: Unity Catalog Skills, agora em Beta.

A ideia central é simples de explicar e difícil de fazer bem: hoje, skill de agente de código vive espalhada, num README aqui, num arquivo de instrução ali, sem dono claro nem controle de quem pode usar o quê. O Unity Catalog Skills trata skill como um securable de três níveis, catalog.schema.skill, seguindo a especificação aberta SKILL.md. Isso significa que você registra a skill uma vez e ganha, de graça, o mesmo modelo de permissão, tag e auditoria que já protege tabela e view no Unity Catalog. Um agente de código pode baixar a skill publicada ou carregá-la em tempo real via MCP, sem precisar embutir instrução fixa no prompt.

Pontos técnicos que valem atenção:
- Skill é um objeto governável, não um arquivo solto, então dá pra restringir quem descobre, usa e atualiza cada skill
- A referência é a especificação SKILL.md, um formato já usado fora do ecossistema Databricks, o que facilita portar skill entre ferramentas
- O consumo funciona tanto por download direto quanto por MCP, cobrindo agente batch e agente interativo com o mesmo mecanismo

**Minhas considerações:** faz sentido que skill de agente siga o mesmo caminho que modelo e prompt já seguiram dentro do MLflow, virar ativo organizacional versionado em vez de configuração pessoal espalhada. A pergunta que fica em aberto é operacional: quem no time assume a responsabilidade de manter skill atualizada quando a lógica de negócio muda, porque um catálogo de skills desatualizado é pior do que nenhum catálogo, ele passa confiança que não deveria.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/agents/uc-skills/

#Databricks #UnityCatalog #Agentes
