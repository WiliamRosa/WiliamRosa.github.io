---
title: "Agora dá pra auditar política de acesso sem ganhar poder pra mudar ela"
date: 2026-08-28T09:00:00-03:00
draft: true
tags: ["Databricks", "UnityCatalog", "Governança", "Opinião"]
summary: "READ METADATA é uma privilégio novo do Unity Catalog: visibilidade completa sobre permissão, row filter, column mask e política ABAC de um objeto, sem poder de leitura de dado nem de alteração."
ShowToc: false
---

Até aqui, quem precisava auditar uma política de acesso no Unity Catalog tinha só duas opções ruins: ganhar MANAGE (e com isso poder de fato mudar a política) ou não ver nada.

O MVP Aladdin Alchalabi resumiu um pacote de novidades de agosto do Azure Databricks, e uma delas mereceu destaque isolado: READ METADATA, um privilégio novo que dá visibilidade completa sobre metadado sensível de um objeto sem conceder nem poder de modificação nem acesso ao dado em si.

O mecanismo é simples de descrever e resolve um problema real de separação de função: READ METADATA é um privilégio filho de MANAGE, mas só de leitura. Quem tem ele enxerga concessão de permissão, row filter, column mask, política ABAC, definição de view e function, e até detalhe de credencial de storage (nome e ID), mas não consegue alterar nada disso nem ler o dado protegido por essas regras. A documentação é explícita sobre pra quem isso foi pensado: auditor de segurança, time de governança de dado, e SRE que precisa depurar controle de acesso sem assumir responsabilidade de administrar ele.

Pontos técnicos que valem registrar:
- Aplica-se à maioria dos objetos securáveis: tabela, view, function, volume, credencial de storage e até o metastore
- É privilégio filho de MANAGE, mas estritamente somente leitura
- A própria documentação recomenda conceder só a principal de confiança, porque o metadado exposto é sensível por natureza

**Minhas considerações:** esse é um daqueles privilégios pequenos que resolve um atrito organizacional real, não só técnico. Antes dele, dar a alguém poder de auditar governança geralmente significava dar mais poder do que a função exigia, o que empurrava empresa a pular a auditoria por preguiça de gerenciar mais uma permissão ampla. Separar "ver a regra" de "mudar a regra" é o tipo de detalhe que só importa quando sua empresa já tem política de acesso complexa o suficiente pra alguém de fora do time técnico precisar confirmar que ela está sendo seguida.

**Fonte:** https://docs.databricks.com/aws/en/data-governance/unity-catalog/access-control/privileges-reference

#Databricks #UnityCatalog #Governança
