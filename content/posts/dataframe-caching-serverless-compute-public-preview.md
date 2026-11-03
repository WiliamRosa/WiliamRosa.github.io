---
title: "Cachear DataFrame no compute serverless deixou de ser exclusividade do cluster clássico"
date: 2026-10-27T11:00:00-03:00
draft: false
tags: ["Azure Databricks", "Serverless", "Apache Spark"]
summary: "O Databricks MVP Shekhar Shukla testou o DataFrame caching em compute serverless, em Public Preview, e descreveu um snapshot eager e privado à sessão, estável por até sete dias, mesmo com mudança no dado de origem nesse intervalo."
ShowToc: false
---

Cachear um DataFrame no compute serverless deixou de ser recurso exclusivo de cluster clássico.

O Databricks MVP Shekhar Shukla testou o DataFrame caching em compute serverless, agora em Public Preview, e descreveu o comportamento como um snapshot eager e privado à sessão: o resultado é materializado assim que você chama df.cache() ou df.persist(), fica isolado pra aquela sessão específica e permanece estável por até sete dias, mesmo que o dado de origem mude nesse intervalo.

A diferença pro cache tradicional em cluster clássico é justamente esse isolamento por sessão. Em vez de um cache compartilhado entre usuário do mesmo cluster, cada sessão serverless guarda sua própria cópia materializada, o que elimina risco de outra pessoa invalidar ou sobrescrever seu cache sem querer, mas também significa que o ganho não se propaga entre sessões diferentes, mesmo rodando a mesma transformação sobre a mesma tabela.

Pontos técnicos que valem atenção:
- Requer serverless environment version 5 ou superior, Databricks Connect for Python 18.1.8 ou mais recente, ou Databricks Connect for Scala 18.1.5 ou mais recente
- Habilitado por padrão na maioria dos workspaces; admin pode desabilitar via Previews page
- Cache eager, materializa na chamada e não só no primeiro uso, diferente do comportamento lazy que algumas implementações de cache assumem
- Snapshot estável por até sete dias dentro da mesma sessão, útil pra reaproveitar resultado caro sem reprocessar

**Minha ressalva:** isolamento por sessão resolve o problema de interferência entre usuário, mas também significa que o custo de materializar o cache se paga de novo a cada sessão nova, mesmo pra consulta idêntica. Vale medir se o ganho de reuso dentro da mesma sessão compensa esse custo repetido antes de assumir cache automático em todo notebook.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/compute/serverless/dataframe-cache

#AzureDatabricks #Serverless #ApacheSpark
