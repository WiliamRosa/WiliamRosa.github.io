---
title: "TinyFish mede sucesso do agente web pela tarefa completa, não pela resposta isolada do modelo"
date: 2026-10-10T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "AI Runtime", "Model Serving", "Agentic AI"]
summary: "A TinyFish pós-treina um modelo próprio especializado em tarefa de agente web usando Databricks AI Runtime (SFT indo pra DPO), avalia sucesso via MLflow com juiz de IA olhando o histórico de ação completo do agente, e serve em produção via Model Serving: 294 mil execuções e 6,4 milhões de passos de ferramenta em 15 dias."
ShowToc: false
---

A TinyFish constrói um agente web empresarial e decidiu que modelo de fronteira genérico não bastava pra essa tarefa específica, então treina um modelo próprio especializado em tarefa web (search, fetch, navegação de página), chamado de modelo "web-native".

O ponto que mais chama atenção no caso não é o treino em si, é o jeito de avaliar sucesso. Em vez de medir se a resposta do modelo parece boa isoladamente, a equipe mede se o agente completo terminou a tarefa, usando MLflow pra acompanhar isso. Um juiz de IA separado revisa o pedido original, todo o histórico de ação do agente e o resultado final; conclusão parcial, resposta incorreta ou resultado inválido contam como falha, não só erro explícito.

Pontos técnicos do caso:

- O pós-treinamento usa Databricks AI Runtime pra infraestrutura de GPU gerenciada, começando com supervised fine-tuning e migrando pra Direct Preference Optimization
- Num benchmark interno de go/no-go, o modelo completou 1.691 de 2.178 tarefas de agente web, taxa de sucesso de 77,6%
- Versão aprovada vai pra produção via Databricks Model Serving, a mesma infraestrutura que já hospeda o reranker de busca e o reescritor de consulta da TinyFish
- Em 15 dias de produção, o modelo processou 294.781 execuções de agente e 6,4 milhões de passos de ferramenta
- Custo estimado de serving: US$ 0,088 por execução e US$ 0,0040 por passo de ferramenta, cobrindo só o serving do modelo, não a pilha completa do agente
- A TinyFish usa Unity Gateway pra centralizar acesso a modelo de fundação externo, com rastreamento de custo e gestão de chave

**Minha leitura:** o valor real aqui não é o número de sucesso de 77,6%, é a decisão de avaliar no nível de tarefa completa em vez de resposta isolada. Isso é um problema estrutural que qualquer time construindo agente vai enfrentar: uma resposta pode parecer perfeita isoladamente e ainda assim deixar a tarefa real incompleta, ou o inverso. O caso não detalha tipo de GPU, dado de treino ou configuração exata de DPO, então não é um tutorial reprodutível, mas o padrão de avaliação (juiz revisando histórico de ação completo, não só a saída final) é o pedaço que vale levar pra qualquer projeto de agente.

**Fonte:** https://www.databricks.com/blog/post-training-production-how-tinyfish-runs-its-web-native-model-databricks-ai-runtime

#AzureDatabricks #AIRuntime #AgenticAI
