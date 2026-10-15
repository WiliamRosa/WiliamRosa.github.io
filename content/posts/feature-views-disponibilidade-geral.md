---
title: "Feature Views chegou à disponibilidade geral, e unifica feature de batch, streaming e tempo de requisição numa peça só"
date: 2026-10-14T13:30:00-03:00
draft: false
tags: ["Azure Databricks", "Machine Learning", "Feature Store"]
summary: "Feature Views atingiu disponibilidade geral no Azure Databricks para dado de batch, streaming e tempo de requisição, mas só chega a workspaces com compliance security profile em meados de novembro de 2026, quase um mês depois do resto."
ShowToc: false
---

Feature de modelo de machine learning calculada em batch, em streaming e na hora da requisição costumam viver em três caminhos de engenharia diferentes, cada um com sua própria forma de servir dado pro modelo em produção. Feature Views, agora em disponibilidade geral no Azure Databricks, trata essas três origens como uma única abstração.

Na prática, isso significa que quem define uma feature não precisa mais escolher entre três implementações separadas dependendo de quando o dado fica disponível: a mesma definição de feature pode ser alimentada por uma tabela batch recalculada periodicamente, por um stream contínuo, ou por um valor calculado em tempo real no momento da requisição de inferência, com o Feature Views abstraindo essa diferença de origem na hora de servir o modelo. É um passo natural depois de anos de feature store tratando batch e streaming como cidadãos de primeira classe e tempo de requisição como caso especial que exigia código próprio.

O detalhe que mais chama atenção no anúncio não é a GA em si, é o prazo: workspaces configurados com compliance security profile (usado por quem precisa de HIPAA, HITRUST, IRAP e certificações parecidas) só recebem o recurso em meados de novembro de 2026, quase um mês depois do restante dos workspaces. É um padrão que já apareceu antes em outras features do Azure Databricks, e que vale o cliente regulado sempre confirmar antes de assumir que "GA" significa "disponível pra mim agora".

Pontos a reter:

- Feature Views chegou à disponibilidade geral cobrindo dado de batch, streaming e tempo de requisição numa única abstração.
- Workspaces com compliance security profile habilitado só recebem o recurso a partir de meados de novembro de 2026.
- A unificação resolve a fragmentação histórica entre pipeline batch, streaming e serving em tempo real de feature pra modelo.

**Minhas considerações:** a unificação de batch, streaming e tempo de requisição é o tipo de simplificação que reduz código de manutenção real, mas o atraso de quase um mês pra workspace regulado é a parte que eu destacaria pra quem trabalha em setor como saúde, financeiro ou governo: não dá pra planejar adoção de feature nova assumindo que compliance acompanha o calendário geral de GA. Isso também levanta a pergunta, não respondida no anúncio, de como a governança do Unity Catalog sobre feature table se comporta igual nos três tipos de origem, ou se streaming e tempo de requisição têm alguma lacuna de auditoria que a feature batch já não tem há mais tempo.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/october#feature-views-are-now-generally-available

#AzureDatabricks #MachineLearning #FeatureStore
