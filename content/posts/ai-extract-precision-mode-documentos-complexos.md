---
title: "AI Extract ganhou modo Precision pra documento longo e schema complexo demais pro chunk-and-merge"
date: 2026-09-13T10:00:00-03:00
draft: false
tags: ["Databricks", "AI Functions", "Document Intelligence", "Opinião"]
summary: "Precision Mode no ai_extract combina modelo especializado com um harness agentico que dispara subagentes em paralelo por seção do documento e depois junta os resultados, atingindo 94,7% de acurácia em benchmark contra 9 mil documentos, sete pontos acima do melhor baseline de modelo de fronteira com chunk-and-merge."
ShowToc: false
---

Extrair campo de documento com IA funciona bem até o documento passar de algumas dezenas de página ou o schema ficar grande demais para caber numa janela de contexto só.

A Databricks lançou o Precision Mode dentro da função `ai_extract`, mirando justamente os três jeitos clássicos de esse tipo de pipeline quebrar: documento longo que exige reconciliar informação entre página distante, saída longa como nota fiscal com centena de item de linha, e schema complexo cujo campo exige inferência ou cálculo em vez de simples cópia de texto. Em vez de depender só de um modelo de fronteira lendo o documento inteiro de uma vez, o modo combina um modelo afinado especificamente pra extração com uma camada agentica que raciocina em etapas, decompõe o trabalho e distribui pedaço do documento entre subagentes rodando em paralelo antes de consolidar tudo numa saída só.

A Databricks testou esse modo em seis benchmarks de documento complexo, cobrindo cerca de nove mil documentos, misturando caso interno de cliente de setor financeiro, industrial e de saúde com benchmark público como VAREX e RealDocBench, incluindo documento de até duas mil páginas e schema com mais de trezentos campo aninhado.

Pontos técnicos:

- Ativa-se passando o modo `precision` na chamada da função `ai_extract`, ou pelo toggle de Precision Mode na interface de Information Extraction dentro de Agents
- Resultado de 94,7% de acurácia agregada nos seis benchmarks testados, sete pontos acima do melhor baseline de modelo de fronteira usando abordagem tradicional de chunk-and-merge
- Endereça três falha comum: reconciliação entre página distante em documento longo, saída longa com muito item repetido, e schema com campo que exige raciocínio, não só extração literal
- Harness agentico dispara subagente em paralelo por trecho do documento e depois faz o merge final num único resultado estruturado

**Minha ressalva:** ganho de sete pontos de acurácia custa alguma coisa em latência e custo computacional, já que agora tem modelo afinado mais harness agentico rodando subagente em paralelo em vez de uma chamada só. Antes de trocar todo pipeline de extração para Precision Mode, vale medir se o schema e o volume de documento do seu caso realmente estão no território onde o chunk-and-merge tradicional falha, porque para documento curto e schema simples o ganho tende a ser marginal frente ao custo extra.

Fonte: https://www.databricks.com/blog/databricks-document-intelligence-pushing-frontier-complex-document-extraction

#Databricks #DocumentIntelligence #AzureDatabricks
