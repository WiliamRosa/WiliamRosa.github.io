---
title: "Genie aprendeu a extrair gráfico de PDF como JSON estruturado antes de responder"
date: 2026-08-28T09:00:00-03:00
draft: false
tags: ["Databricks", "Genie", "IA Generativa", "RAG"]
summary: "A Databricks publicou uma técnica de enriquecimento que usa ai_parse_document e ai_prep_search pra transformar gráfico dentro de documento em JSON estruturado antes de indexar, e bateu embedding multimodal maior em dois benchmarks públicos."
ShowToc: false
---

Um agente de recuperação quase sempre erra a resposta quando o dado certo está dentro de um gráfico, não de um parágrafo de texto.

A Databricks lançou uma técnica de enriquecimento pensada exatamente pra esse ponto cego: hoje, RAG tradicional trata gráfico como imagem, ou ignora, ou joga pra um modelo multimodal caro tentar interpretar em tempo de consulta. A proposta aqui inverte a ordem, extrai a estrutura do gráfico uma vez, no momento da indexação, e guarda como JSON.

O mecanismo usa duas funções SQL nativas em sequência: ai_parse_document identifica e recorta gráfico dentro do PDF ou documento, e ai_prep_search converte esse recorte em JSON estruturado, com eixo, série, valor e legenda explícitos, que entra no índice de busca do Genie junto com o texto ao redor. Na hora da pergunta, o agente recupera o JSON do gráfico como se fosse mais um trecho de texto, sem precisar rodar um modelo de visão pesado toda consulta.

Pontos técnicos que valem atenção:
- Testado em dois benchmarks públicos, ViDoRe V3 (310 perguntas, 7 domínios) e Chart-RAG (114 perguntas, 3 relatórios financeiros)
- Taxa de acerto de 75,9% e 75,1% respectivamente, superando quatro baselines de embedding multimodal
- O modelo usado pra extrair é bem menor, na casa de 300M de parâmetros, e a consulta final passa menos imagem pro modelo de resposta

**Minhas considerações:** o ganho aqui não é só de acurácia, é de custo, trocar chamada de modelo multimodal em toda consulta por uma extração feita uma vez na indexação reduz bastante o gasto recorrente. Vale lembrar que o benchmark é da própria Databricks, então taxa de acerto divulgada merece ser validada em dado próprio antes de virar decisão de arquitetura.

**Fonte:** https://www.databricks.com/blog/enhancing-agent-retrieval-structured-chart-extraction

#Databricks #Genie #RAG
