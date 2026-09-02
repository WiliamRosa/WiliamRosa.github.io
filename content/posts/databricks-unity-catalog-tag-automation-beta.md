---
title: "Tag Automation chega ao Unity Catalog, e você pode descrever a regra em português"
date: 2026-08-12T09:00:00-03:00
draft: false
tags: ["Databricks", "UnityCatalog", "Governança", "Opinião"]
summary: "Tag Automation (Beta) deixa o Unity Catalog aplicar e remover tags governadas sozinho, com base em regras que você descreve em linguagem natural pro Genie construir."
ShowToc: false
---

Tag automatizada finalmente chegou no Unity Catalog, e a parte mais interessante não é a automação em si, é como você a configura.

O Databricks MVP Ajay Kumar Pandey destacou o Tag Automation logo na semana em que saiu do papel: um jeito de manter tag correta sem depender de alguém lembrar de atualizar manualmente toda vez que uma tabela muda de dono, fica obsoleta ou passa a carregar dado sensível.

O mecanismo funciona assim: você define condições (tag existente, contagem de query, data de criação ou modificação, dono, existência de descrição, correspondência de nome) e o automation aplica ou remove tags governadas com base nelas, de forma recorrente. A parte que chama atenção é que, em vez de escrever a regra manualmente, dá pra descrever em linguagem natural e deixar o Genie montar o escopo, a condição e a ação, tudo revisável antes de salvar.

Alguns limites valem nota pra quem for testar:
- Cada execução processa no máximo 500 ativos, e uma automação atribui ou remove no máximo 5 tags governadas por vez
- O escopo é sempre um catálogo só, sem abranger múltiplos catálogos numa regra
- Automação é separada entre tabelas OU volumes, nunca os dois juntos
- Exige privilégios específicos: USE CATALOG, USE SCHEMA, APPLY TAG, MANAGE no catálogo alvo, mais ASSIGN em cada tag que a automação toca

**Minha ressalva:** deixar o Genie escrever a regra a partir de uma descrição em linguagem natural é conveniente, mas ainda é código de governança rodando sozinho, revisar o resultado antes de salvar não é opcional, é o único ponto de controle humano que sobra nesse fluxo. Automação de tag errada tem o mesmo efeito de qualquer automação errada: silenciosa até alguém descobrir tarde demais.

**Fonte:** https://docs.databricks.com/aws/en/admin/governed-tags/automate-tag-assignment

#Databricks #UnityCatalog #DataGovernance
