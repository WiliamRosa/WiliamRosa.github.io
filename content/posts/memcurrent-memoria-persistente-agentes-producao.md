---
title: "MemCurrent: a arquitetura de duas camadas por trás da memória de agente da Databricks"
date: 2026-10-27T09:00:00-03:00
draft: false
tags: ["Databricks", "Agentes de IA", "Lakebase", "Azure Databricks"]
summary: "A Databricks detalhou o MemCurrent, arquitetura de memória persistente que já roda por baixo do Agent Bricks Memory e do Genie, separando memória episódica bruta de memória derivada e destilada por um processo de consolidação em segundo plano."
ShowToc: false
---

A Databricks detalhou a arquitetura de memória que já roda por baixo do Genie e do Agent Bricks Memory.

A Databricks publicou os detalhes do MemCurrent, a arquitetura de memória persistente que alimenta o Agent Bricks Memory e o Genie, destacada pelo Databricks MVP Ajay Kumar Pandey logo depois da publicação. A proposta é melhorar a qualidade da resposta de um agente de longa duração sem deixar custo e latência explodirem conforme o histórico cresce.

O MemCurrent separa memória de agente em duas camadas. A primeira, episódica, é um log bruto e append-only de cada passo de uma sessão, gravado por um plugin enquanto a sessão roda. A segunda, derivada, guarda aprendizado já destilado em arquivos organizados como um sistema de arquivos hierárquico dentro de uma tabela mutável, com um índice memory.md gerado automaticamente descrevendo essa estrutura. Em vez de só acumular histórico, um job de consolidação em segundo plano, que a Databricks chama de dreaming, roda periodicamente pra dividir arquivo que cresceu demais, juntar entrada duplicada e resolver conflito entre memórias.

Pontos técnicos que valem atenção:
- Três formas de acessar a memória: plugin automático em pontos fixos da sessão, ferramenta explícita (search_memory, fetch_memory, add_memory, update_memory, delete_memory) e pipeline offline de consolidação
- Armazenamento roda sobre Lakebase, com um session store pra memória episódica e um memory store pra memória derivada
- Benchmark interno com 114 casos de teste corporativo: taxa de acerto subiu de 22,3% sem memória pra 68,4% com MemCurrent, 1,35x mais rápido e 1,44x mais barato
- Em LoCoMo, LongMemEval e ConvoMem, empatou com contexto completo (88,1% contra 87,8%) usando cerca de 12 vezes menos token de entrada por pergunta
- Ablação mostrou que memória derivada isolada (66,1%) pesa mais que episódica isolada (35,8%), mas a combinação dos dois ainda supera cada um sozinho

**Minhas considerações:** o ganho de 12 vezes menos token é o número que mais importa aqui, memória bem curada economiza contexto, não só acerta mais. Mas a Databricks não detalha o mecanismo de busca por trás de search_memory, se é embedding, palavra-chave ou híbrido, e isso muda bastante o comportamento em produção conforme o volume de memória acumulada cresce.

**Fonte:** https://www.databricks.com/blog/memcurrent-designing-persistent-memory-production-agents

#Databricks #AgentesDeIA #Lakebase
