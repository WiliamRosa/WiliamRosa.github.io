---
title: "Auto CDC no Spark 4.2 tira o MERGE manual de cima de quem só queria manter a versão mais recente"
date: 2026-08-02T09:00:00-03:00
draft: true
tags: ["Databricks", "ApacheSpark", "SDP", "Opinião"]
summary: "Auto CDC chega ao Spark Declarative Pipelines pra SCD Type 1: você descreve a regra de mudança (chave, ordenação, o que conta como delete), e o motor aplica, mesmo com evento fora de ordem."
ShowToc: false
---

Manter só a versão mais recente de um registro parece simples até o feed de mudança trazer delete e evento fora de ordem no meio.

O Databricks MVP P Shekhar Shukla resumiu bem o problema que o Auto CDC resolve: um change feed de cliente que mudou de endereço normalmente carrega o registro original, uma atualização com o endereço novo, um evento de exclusão, e às vezes tudo isso chega fora de ordem. Manter a tabela de destino correta nesse cenário sempre exigiu lógica de MERGE escrita à mão, que fica complicada rápido quando delete e ordenação entram na conta.

O Spark 4.2 introduz suporte a Auto CDC dentro do Spark Declarative Pipelines especificamente pra processamento SCD Type 1, o padrão que mantém só a versão mais recente de cada registro (perfil de cliente, catálogo de produto, dado de referência operacional). Em vez de escrever cada passo do merge, você descreve a regra de mudança e o motor aplica: target (tabela a atualizar), source (evento de mudança de entrada), keys (como casar registro), sequence_by (como ordenar evento), apply_as_deletes (quais eventos contam como exclusão) e stored_as_scd_type (o tipo de processamento SCD).

Pontos técnicos que valem registrar:
- Resolve especificamente SCD Type 1: manter só a versão mais recente, não histórico completo
- O parâmetro sequence_by garante ordenação correta mesmo com evento chegando fora de sequência
- apply_as_deletes deixa explícito quais eventos do feed contam como exclusão de registro
- Roda dentro do Spark Declarative Pipelines, herdando checkpoint e observabilidade que o SDP já oferece

**Minha ressalva:** declarar a regra de mudança em vez de escrever o merge manualmente resolve o problema de manutenção, mas move a complexidade pra outro lugar: agora o cuidado precisa estar na definição correta de sequence_by e apply_as_deletes, porque um erro ali silenciosamente aplica a versão errada como "mais recente" sem lançar exceção óbvia. Eu testaria com um conjunto de eventos propositalmente fora de ordem antes de confiar isso em produção com dado que importa.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/ldp/cdc

#Databricks #ApacheSpark #SDP
