---
title: "Vector Store no Databricks virou três produtos diferentes, e escolher errado sai caro"
date: 2026-08-31T12:00:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "VectorSearch", "Opinião"]
summary: "AI Search, o novo lakebase_vector em beta e a variante em batch via SQL resolvem o mesmo problema, guardar e buscar embedding, de formas bem diferentes."
ShowToc: false
---

Vector Search no Databricks parou de ser uma escolha única e virou uma decisão de arquitetura com três caminhos possíveis.

O Databricks MVP Laurenz Wuttke mapeou as opções que existem hoje pra guardar e buscar embedding na plataforma. A primeira é o AI Search (antigo Vector Search): índice gerenciado sobre uma tabela Delta, sincronização automática quando o dado muda, busca híbrida combinando vetor e palavra-chave, tudo consultável direto via SQL pela função vector_search(), serverless e de baixa latência, pensado pra caso de uso de RAG ou agente em produção.

A segunda opção é nova: o Lakebase, o Postgres operacional do Databricks, agora suporta pgvector por completo, e ganhou em beta o lakebase_vector, uma busca ANN própria compatível com pgvector mas bem mais econômica em uso de memória. Faz sentido quando o embedding já precisa morar onde a aplicação já está escrevendo, como memória de agente ou feature serving. A terceira opção é a mais simples: calcular embedding em lote via ai_query() sobre a tabela inteira, guardar como array numa tabela Delta e resolver similaridade direto com função SQL, sem índice nem endpoint, ideal pra job periódico que não precisa rodar em tempo real.

O que muda na prática entre as três:
- AI Search entrega menor latência e sincronização automática, mas exige manter um índice gerenciado separado
- lakebase_vector (Beta) faz sentido quando o embedding já vive no mesmo lugar que grava dado operacional, evitando duplicar armazenamento
- A variante em batch via SQL dispensa índice e endpoint, mas não serve pra consulta em tempo real

**Minhas considerações:** a pergunta certa deixou de ser "qual vector store usar" e virou "qual dessas três opções combina com o padrão de escrita e leitura que eu já tenho". Quem está construindo agente com memória persistente ganha mais testando o lakebase_vector, ainda em beta, do que forçando tudo pelo AI Search só porque é a opção mais conhecida.

**Fonte:** https://www.linkedin.com/in/laurenz-wuttke/

#Databricks #Lakebase #VectorSearch
