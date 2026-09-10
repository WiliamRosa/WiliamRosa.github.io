---
title: "AI Search agora mostra qual pedaço de documento sustentou cada resposta"
date: 2026-09-09T11:00:00-03:00
draft: true
tags: ["Databricks", "AI Search", "IA", "Azure Databricks"]
summary: "A opção generate_citations na função ai_search (Beta) do Azure Databricks expõe quais chunks recuperados o modelo efetivamente usou para sustentar cada resposta gerada, dando visibilidade que antes ficava escondida dentro da recuperação."
ShowToc: false
---

Uma resposta de busca aumentada por IA que não mostra a fonte é uma resposta que ninguém consegue auditar de verdade.

O Azure Databricks adicionou a opção `generate_citations` à função `ai_search`, em beta, permitindo ver quais chunks recuperados o modelo efetivamente usou pra sustentar cada resposta gerada. Antes, a função retornava a resposta final sem expor essa ligação entre trecho de documento recuperado e afirmação feita pelo modelo, deixando a etapa de recuperação como uma caixa-preta dentro do fluxo de busca aumentada.

Pontos técnicos que valem atenção:
- Opção `generate_citations` ativada dentro da própria chamada da função `ai_search`
- Expõe o chunk específico que sustentou cada parte da resposta gerada, não só a lista geral de resultado recuperado
- Recurso em Beta, parte da referência de função da linguagem SQL do Azure Databricks
- Reduz a distância entre "o modelo disse isso" e "de onde exatamente o modelo tirou isso"

**Minhas considerações:** citação por chunk é o tipo de recurso que devia ter vindo desde o primeiro dia de qualquer função de busca aumentada por IA usada em produto voltado a decisão de negócio, porque sem isso a auditoria de por que o modelo respondeu algo errado vira exercício de adivinhação. Vale adotar `generate_citations` já em qualquer pipeline novo de RAG construído sobre `ai_search`, mesmo em beta, só pra ganhar o hábito de rastrear a fonte desde o início do projeto.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/september#see-which-chunks-support-each-ai_search-answer-beta

#Databricks #AISearch #IA
