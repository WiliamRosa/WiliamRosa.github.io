---
title: "Zerobus Ingest ganhou protocolo binário Arrow Flight como terceiro formato de envio"
date: 2026-09-02T10:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow Connect", "Streaming", "Azure Databricks"]
summary: "Apache Arrow Flight chegou como formato de envio pro Zerobus Ingest do Lakeflow Connect, ao lado de JSON e protobuf, carregando RecordBatch colunar direto pela mesma conexão gRPC, com SDK em Python e Rust e opção de compressão ZSTD ou LZ4."
ShowToc: false
---

Ingestão de alta taxa de evento ganhou um formato binário colunar nativo em vez de depender só de serialização linha a linha.

O Azure Databricks confirmou disponibilidade geral do suporte a Apache Arrow Flight dentro do Zerobus Ingest, o caminho de ingestão de baixa latência do Lakeflow Connect que já grava direto em tabela Delta sem passar por Kafka nem cluster Spark. Arrow Flight entra como um terceiro formato de envio, ao lado de JSON e protobuf, rodando na mesma conexão gRPC, mesmo endpoint e mesmo fluxo de autenticação já usados pelos outros formatos.

A diferença prática é o formato de dado que trafega. Em vez de converter cada linha em JSON ou protobuf antes de enviar, a aplicação manda lote de dado já colunar, RecordBatch do Arrow, e o protocolo Arrow Flight DoPut carrega esse lote como mensagem IPC pela mesma conexão. Isso favorece principalmente aplicação que já trabalha nativamente com Arrow, como pipeline construído sobre Polars ou DataFusion, ou coletor que agrega dado por um intervalo curto antes de mandar em lote.

Pontos técnicos que valem atenção:
- SDK disponível em Python (pacote databricks-zerobus-ingest-sdk com extra [arrow]) e Rust (feature arrow-flight do crate)
- Compressão opcional na mensagem IPC, com LZ4_FRAME pra baixo custo de CPU ou ZSTD pra taxa de compressão maior
- Lote Arrow não está sujeito ao limite de 10 MB por mensagem gRPC que vale pra linha individual, o SDK quebra lote grande em mensagens menores automaticamente
- Recomendação oficial é reaproveitar o mesmo stream pra muitos lotes, já que abrir stream novo tem custo fixo relevante
- Não é indicado pra tráfego esparso, linha a linha, onde JSON ou protobuf continuam mais simples

**Minhas considerações:** esse suporte fecha uma lacuna que fazia sentido existir desde o lançamento do Zerobus, quem já processa dado colunar na aplicação não deveria pagar o custo de converter tudo pra JSON só pra depois a Databricks reconverter pra Delta do outro lado. Vale considerar principalmente pra pipeline de streaming que já nasce em Arrow, o ganho em aplicação pequena e esparsa provavelmente não compensa a complexidade extra.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/ingestion/zerobus-arrow-flight

#Databricks #LakeflowConnect #Streaming
