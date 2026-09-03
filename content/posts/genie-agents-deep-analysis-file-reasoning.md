---
title: "Genie Agents ganha modo de pesquisa em múltiplos passos e aprende a ler arquivo, não só tabela"
date: 2026-09-03T09:00:00-03:00
draft: true
tags: ["Databricks", "Genie", "Agentes", "Unity Catalog"]
summary: "Agent mode traz raciocínio em múltiplos passos com relatório e visualização, Genie Agents passa a ler PDF, slide e imagem dentro de volume do Unity Catalog, e o Genie Code ganha função pra criar e diagnosticar outros agentes Genie."
ShowToc: false
---

O Genie deixou de responder só com base em tabela estruturada e passou a lidar com pergunta que exige investigar antes de responder.

A Databricks expandiu o Genie Agents em três frentes. A primeira é o Agent mode, um modo de raciocínio em múltiplos passos: em vez de tentar responder de cara, o agente monta um plano de investigação, explora o dado em rodadas iterativas de consulta e devolve um relatório com achados, visualização e citação da fonte usada. Isso já está disponível via API com Server-Sent Events pra resposta em streaming, com gestão completa de conversa, histórico de follow-up e suporte a visualização junto do texto. A segunda frente é a leitura de dado não estruturado: PDF, documento, slide e imagem guardados em volume do Unity Catalog agora entram na mesma análise que já cobria tabela, até dez volumes por configuração, sempre respeitando a permissão de quem está perguntando. Um índice de busca opcional acelera a recuperação e melhora o raciocínio quando o volume de arquivo é grande.

A terceira frente muda quem constrói o agente. O Genie Code ganhou três funções voltadas a curar outro Genie: gerar uma configuração inicial a partir de uma descrição de propósito e perguntas de exemplo, diagnosticar falha analisando conversa com erro e sugerindo ajuste de instrução, e acompanhar produção analisando tendência de pergunta e feedback do usuário pra apontar lacuna de conhecimento.

Pontos técnicos que valem atenção:
- Agent mode monta plano de investigação e itera em múltiplas consultas antes de responder, em vez de responder direto
- API com Server-Sent Events permite streaming de resposta e gestão programática de conversa e follow-up
- Até dez volumes do Unity Catalog por configuração, com permissão do usuário respeitada arquivo por arquivo
- Indexação de conteúdo é opcional, pensada pra coleção grande de documento
- Genie Code passa a gerar, diagnosticar e monitorar outro agente Genie, não só escrever código de pipeline

**Minhas considerações:** juntar tabela estruturada e arquivo solto na mesma pergunta resolve um problema real, muita decisão de negócio depende de cruzar número com contrato, ata ou política em PDF. Mas isso também espalha a superfície de governança: antes bastava pensar em permissão de tabela, agora entra permissão de volume, indexação de conteúdo e o próprio comportamento do Agent mode ao decidir quantas iterações vale a pena rodar antes de responder. Vale acompanhar de perto quanto esse raciocínio em múltiplos passos custa em token antes de liberar geral.

**Fonte:** https://www.databricks.com/blog/expanding-genie-agents-deep-analysis-file-reasoning-and-more

#Databricks #Genie #Agentes
