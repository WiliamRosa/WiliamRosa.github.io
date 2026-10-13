---
title: "Flo Health usou 26 juízes de IA para pós-treinar um modelo aberto sem perder segurança médica no processo"
date: 2026-10-13T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "AI Runtime", "MLflow", "Saúde"]
summary: "A Flo Health construiu um pipeline de pós-treinamento com 26 juízes de IA (12 de segurança médica como barreira obrigatória, 6 de comportamento fino, 8 de utilidade) pra deixar um modelo aberto mais seguro sem sacrificar utilidade, usando Databricks AI Runtime, LLM Foundry e Compose-RL."
ShowToc: false
---

A Flo Health publicou um caso que foge do padrão de depoimento de cliente raso: eles mostram o mecanismo real de como transformaram um modelo aberto genérico em algo seguro o suficiente pra lidar com pergunta de saúde sensível, sem virar um modelo inútil de tão cauteloso.

O núcleo do trabalho foi traduzir preocupação de risco médico, levantada por time médico, de produto e de engenharia junto, em rubrica, e depois em juiz de IA automatizado. Chegaram a 26 juízes: 12 juízes de segurança médica funcionando como barreira obrigatória (se falhar aqui, a resposta é descartada independente do resto), 6 juízes "micro" pra comportamento mais fino, e 8 juízes de utilidade. Quando os juízes discordavam da avaliação humana inicial, um clínico arbitrava o caso, e esse veredito servia pra calibrar os próprios juízes.

Pontos técnicos do pipeline:

- Mais de 15 mil perguntas sintéticas, construídas a partir de sinal gerado ou agregado por modelo, não a partir de texto literal de usuário
- O loop de treino gera múltiplas respostas candidatas, pontua cada uma com os juízes, seleciona a mais forte pra montar par de preferência, roda SFT seguido de DPO, e reavalia com os juízes de novo pra verificar o resultado
- Um detalhe que a equipe só descobriu na prática: a primeira versão do pipeline usava par de preferência binário (passa ou não passa), e isso melhorou utilidade sem melhorar segurança. A correção foi trocar por uma pontuação graduada de segurança, dando sinal mais fino pro treino
- A infraestrutura por trás: GPU H100 serverless (32 unidades no treino de fine-tuning), PyTorch com Fully Sharded Data Parallel, LLM Foundry pra treino distribuído, Compose-RL pra camada de otimização de preferência, e MLflow pra rastreamento e checkpoint

**Minha ressalva:** o caso é honesto sobre o mecanismo, mas fraco em reprodutibilidade, não há nome do modelo base, hiperparâmetro, configuração de DPO, composição exata do dataset nem prompt dos juízes. Mais importante: o ganho reportado é medido pelos próprios juízes de IA que também serviram de sinal de treino, a mesma família de juiz validando o que ela ajudou a treinar é um risco real de circularidade que o texto não discute. A lição sobre pontuação graduada em vez de binária é o pedaço mais valioso e generalizável do caso, isso vale pra qualquer pipeline de alinhamento com juiz automatizado, não só pra saúde.

**Fonte:** https://www.databricks.com/blog/how-flo-health-built-safer-more-useful-open-models-databricks-ai-runtime

#AzureDatabricks #AIRuntime #Saude
