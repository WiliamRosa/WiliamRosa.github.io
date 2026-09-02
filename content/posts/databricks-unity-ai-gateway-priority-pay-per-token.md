---
title: "Priority pay-per-token: pagar mais caro pra garantir latência, sem reservar capacidade dedicada"
date: 2026-08-02T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity AI Gateway", "Model Serving", "Opinião"]
summary: "O Unity AI Gateway ganhou um modo de prioridade que promete latência consistente pra aplicações de IA em tempo real, sem exigir capacidade reservada, um meio-termo entre pay-per-token comum e provisioned throughput."
ShowToc: false
---

O Unity AI Gateway adicionou o "Priority pay-per-token": latência consistente para aplicações de IA críticas em tempo real, sem precisar reservar capacidade dedicada. A ideia é dar prioridade de fila pra quem paga mais por token, em vez de forçar a escolha binária entre pay-per-token comum (mais barato, latência variável) ou provisioned throughput (latência garantida, mas com capacidade reservada e custo fixo mesmo ocioso).

Isso preenche uma lacuna real de quem serve modelo em produção: nem toda aplicação crítica tem volume constante o suficiente pra justificar capacidade reservada, mas ainda assim não pode tolerar latência imprevisível em horário de pico.

Por que isso importa na prática:
- Evita pagar por capacidade reservada ociosa em aplicações com tráfego irregular mas latência-sensível
- Dá um terceiro ponto no espectro custo/latência, não só os dois extremos de sempre
- Funciona dentro do mesmo Unity AI Gateway que já centraliza custo e observabilidade, não é uma configuração isolada

**Minha ressalva:** "prioridade" só funciona de verdade quando há contenção de fato, se todo mundo pagar o prêmio de prioridade, a fila volta a ser genérica e você só pagou mais caro pelo mesmo resultado. Vale medir o ganho real de latência em horário de pico antes de assumir que o prêmio pago se traduz em benefício proporcional.

**Fonte:** https://docs.databricks.com/aws/en/machine-learning/foundation-model-apis/priority-mode

#Databricks #UnityAIGateway #ModelServing
