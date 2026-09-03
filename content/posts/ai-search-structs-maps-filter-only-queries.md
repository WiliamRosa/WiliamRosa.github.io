---
title: "AI Search agora filtra dentro de struct e map, e dá pra consultar sem buscar nada"
date: 2026-09-02T10:00:00-03:00
draft: false
tags: ["Databricks", "AI Search", "Vector Search", "Azure Databricks"]
summary: "AI Search passou a aceitar filtro em campo de struct aninhado e chave de map, e ganhou a opção de consulta só de filtro, sem busca vetorial nem por palavra-chave, útil pra lookup direto por chave."
ShowToc: false
---

Buscar por similaridade sempre foi o motivo de existir do AI Search, mas nem toda consulta contra um índice é sobre similaridade.

O Azure Databricks ampliou o filtro do AI Search (o antigo Vector Search) pra alcançar campo aninhado dentro de coluna do tipo struct e chave dentro de coluna do tipo map, usando notação de ponto pra struct, `profile.age`, e notação de colchete pra map, `attrs['voltage']`. Ao lado disso chegou a consulta só de filtro: basta omitir `query_text`, `query_vector` e `query_type` e informar apenas o filtro, e o índice devolve toda linha que bate com a condição sem rodar busca vetorial nem full-text por trás. Isso vale tanto pra endpoint padrão quanto pro endpoint storage-optimized, cada um com sua própria sintaxe de filtro, dicionário de chave e valor no padrão e string estilo cláusula WHERE no storage-optimized.

Na prática isso empurra o AI Search pra um território que antes pedia uma consulta SQL direto na tabela: filtrar por chave primária pra fazer um lookup pontual, sem gastar ciclo com embedding nem ranking, agora é um caso suportado dentro do próprio índice.

Pontos técnicos que valem atenção:
- Struct aninhado é filtrado com notação de ponto, `profile.age`, map com notação de colchete, `attrs['voltage']`
- Consulta só de filtro dispensa `query_text`, `query_vector` e `query_type`, mantém apenas `filters`
- Os mesmos limites de `num_results` e paginação da busca normal valem pra consulta só de filtro
- Lookup por ponto (point lookup) é o caso de uso indicado quando o filtro é sobre a coluna de chave primária
- Endpoint padrão e storage-optimized usam sintaxe de filtro diferente entre si, dicionário versus string tipo SQL

**Minhas considerações:** faz sentido técnico, já que o índice já guarda a coluna e o filtro, mas isso também confunde a fronteira entre "índice de busca" e "tabela consultável", o que provavelmente é a intenção. A pergunta prática é de custo: consulta só de filtro contra um índice de AI Search compensa mesmo, ou uma consulta direto na tabela Delta que já origina o índice resolve mais barato o mesmo lookup pontual. Vale medir antes de trocar um pelo outro por conveniência de API única.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/ai-search/query-ai-search

#Databricks #AISearch #AzureDatabricks
