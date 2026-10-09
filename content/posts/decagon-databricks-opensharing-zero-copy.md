---
title: "Agente de atendimento lê dado do Databricks sem cópia, e devolve a conversa estruturada de volta"
date: 2026-10-01T09:00:00-03:00
draft: true
tags: ["Databricks", "OpenSharing", "Agentes", "Opinião"]
summary: "A parceria entre Decagon e Databricks usa OpenSharing zero-copy nos dois sentidos: agentes de atendimento leem registro de cliente governado direto do Databricks sem ETL, e cada conversa volta estruturada, com intenção, causa raiz e sentimento, pra enriquecer tabela de receita e produto."
ShowToc: false
---

A Decagon e a Databricks anunciaram uma parceria que usa OpenSharing zero-copy nos dois sentidos, não só pra levar dado pro agente de atendimento, mas também pra trazer de volta o que a conversa revelou.

No sentido Databricks para Decagon, o agente de atendimento lê registro de cliente, pedido, pagamento, direito de uso e pontuação calculada, direto das tabelas do Databricks, sem precisar de pipeline de ETL nem cópia separada do dado sensível. No sentido contrário, cada conversa que o agente da Decagon conduz é enviada de volta como dado estruturado, com tag de intenção, atribuição de causa raiz, gatilho de escalonamento e sentimento do usuário, alimentando tabela de receita, retenção e produto dentro do próprio Databricks, além do Duet Autopilot da Decagon.

O que sustenta essa troca nos dois sentidos é a mesma base de governança que já aparece em outras integrações recentes da Databricks: acesso do agente ao dado passa pelo Unity Catalog, e a inferência de modelo passa pelo Unity Gateway, então permissão, linhagem e trilha de auditoria cobrem tanto a leitura do dado quanto a chamada ao modelo que a sustenta.

Pontos técnicos do anúncio:

- Fluxo bidirecional: dado de cliente sai do Databricks pro agente, resultado da conversa volta estruturado pro Databricks
- Nenhuma cópia nova do dado sensível é criada, o zero-copy evita duplicar o que já é governado
- Decagon vai entrar no programa Built-On da Databricks, escalando o serving de modelo via Unity Gateway
- A parceria já nasce com Decagon listada como parceira de lançamento, disponível via Databricks Marketplace

**Minhas considerações:** o anúncio é específico sobre o que entra e sai em cada direção, mas fica vago sobre o mecanismo técnico exato, protocolo, latência, como a permissão é configurada por agente individual. Isso é comum em anúncio de parceria comercial, os detalhes de implementação tendem a aparecer só depois, em documentação técnica ou em relato de quem já integrou de verdade. O padrão de fundo, porém, é o que interessa, zero-copy nos dois sentidos via OpenSharing é uma alternativa concreta ao modelo antigo de exportar dado de cliente pra uma plataforma de atendimento terceira e nunca mais saber onde ele realmente mora.

**Fonte:** https://www.decagon.ai/blog/decagon-and-databricks

#Databricks #OpenSharing #Agentes
