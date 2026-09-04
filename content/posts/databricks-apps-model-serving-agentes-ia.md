---
title: "Databricks Apps ou Model Serving pra hospedar seu agente? A resposta depende de três coisas"
date: 2026-08-30T09:00:00-03:00
draft: false
tags: ["Databricks", "Agentes de IA", "Model Serving", "Databricks Apps", "Arquitetura", "Opinião"]
summary: "Databricks Apps virou o host recomendado pra agente novo, mas Model Serving ainda vence em cenário de baixo custo e alta escala, e a diferença de timeout entre os dois muda qual opção funciona pra que tipo de agente."
ShowToc: false
---

Escolher onde hospedar um agente de IA no Databricks parece detalhe de infraestrutura, mas na prática decide se o agente roda até o fim ou morre no meio de uma tarefa longa.

O Databricks MVP Shashank Shekhar resumiu um dilema que quem constrói agente em produção acaba enfrentando cedo ou tarde: usar Databricks Apps ou Model Serving como camada de hospedagem, e por que a resposta certa muda conforme o tipo de carga de trabalho.

Model Serving nasceu para servir modelo de ML clássico, com escalonamento a zero quando ocioso e cobrança por uso, mas isso vem com um teto de execução em torno de dez minutos por requisição. Um agente que faz raciocínio em múltiplos passos, chama ferramenta externa ou espera resposta de LLM mais lento pode facilmente estourar essa janela. Databricks Apps, por outro lado, roda como servidor persistente, sem esse limite de tempo, só que cobra por hora enquanto estiver ligado, mesmo ocioso, o que inverte a equação de custo pra quem tem tráfego baixo ou picos irregulares.

Pontos técnicos que valem registrar:
- Databricks Apps é a opção recomendada pela Databricks para hospedar agente novo, por rodar como servidor persistente
- Model Serving impõe um timeout de aproximadamente dez minutos por requisição, um limite real para agente com execução longa
- Model Serving escala a zero e cobra só pelo uso, enquanto Databricks Apps tem custo por hora mesmo com baixo tráfego
- Serverless Micro Apps, ainda não disponível, promete resolver esse trade-off de custo ocioso no futuro

**Minhas considerações:** esse tipo de decisão de arquitetura costuma ficar invisível até o agente falhar em produção por timeout, e nesse ponto já é tarde para descobrir que a escolha de hospedagem estava errada desde o início. Recomendo tratar isso como parte do desenho técnico logo na primeira reunião de arquitetura do projeto, não como ajuste de última hora: se o agente tem passo longo ou espera de ferramenta externa, Databricks Apps evita dor de cabeça, mas exige monitorar custo ocioso até que Serverless Micro Apps chegue.

**Fonte:** https://www.linkedin.com/in/ishashankshekhar/#databricks-apps-vs-model-serving-agentes

#Databricks #AgentesIA #Arquitetura
