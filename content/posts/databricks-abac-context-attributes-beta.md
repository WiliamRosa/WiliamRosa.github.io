---
title: "Uma política ABAC agora sabe distinguir se quem pergunta é um agente ou uma pessoa"
date: 2026-08-26T11:00:00-03:00
draft: true
tags: ["Databricks", "UnityCatalog", "ABAC", "Opinião"]
summary: "Context Attributes (Beta) deixa política ABAC do Unity Catalog condicionar máscara e row filter ao contexto da requisição, se veio via OAuth on-behalf-of ou de qual client_id, não só a quem pertencem os dados."
ShowToc: false
---

Dar permissão de leitura pra um agente não devia significar dar a mesma permissão que o humano que ele representa tem.

A Databricks MVP Zoë Van Noppen apontou o Context Attributes assim que saiu do papel: uma extensão das políticas ABAC do Unity Catalog que deixa condicionar máscara de coluna e row filter não só a quem é o usuário, mas ao contexto técnico da própria requisição.

O mecanismo introduz duas condições novas de política: request.is_on_behalf_of, que retorna verdadeiro sempre que a chamada vem de um app OAuth agindo em nome de alguém (não exclusivo de agente, CLI e SDK também contam), e request.client_id, que deixa mirar uma aplicação OAuth específica pelo identificador dela. Isso resolve um problema real de quem constrói agente hospedado como Databricks App: autenticação on-behalf-of já garante que o agente herda a identidade do usuário, mas às vezes você quer que o agente veja menos dado do que a pessoa vê diretamente, por exemplo, dado sensível demais pra passar por um LLM mesmo que o usuário tenha acesso a ele.

Detalhes técnicos que valem registrar:
- request.is_on_behalf_of retorna a string 'true' ou 'false', verdadeiro pra qualquer requisição vinda de app OAuth
- request.client_id permite política direcionada a uma aplicação OAuth específica pelo ID
- As funções has_context_attribute e has_context_attribute_value são suportadas na cláusula WHEN de política de row filter e column mask
- Ainda em Beta, precisa ser ativado por admin de conta na página de Previews

**Minhas considerações:** essa é uma peça pequena mas exatamente do tipo que separa "agente com acesso ok em teoria" de "agente com acesso auditável na prática". Sem diferenciar contexto de requisição, a única forma de restringir o que um agente vê era criar um usuário técnico separado com permissão reduzida, o que quebra o modelo mais limpo de on-behalf-of. Vale testar cedo em qualquer solução agêntica que já lide com dado sensível, antes de precisar improvisar um workaround.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/abac/core-concepts

#Databricks #UnityCatalog #ABAC
