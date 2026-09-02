---
title: "Genie One virou lugar de escrever relatório em conjunto, não só de perguntar"
date: 2026-08-29T09:00:00-03:00
draft: false
tags: ["Databricks", "Genie One", "IA Generativa", "Opinião"]
summary: "A Databricks lançou um pacote de novidades pro Genie One além do app nativo pra macOS já coberto aqui antes: colaboração em documento com versionamento, criação de agente a partir de conversa, compartilhamento de chat, upload de arquivo e ações de escrita via MCP governadas pelo Unity AI Gateway."
ShowToc: false
---

Genie One deixou de ser só um chat que responde pergunta e virou lugar de escrever documento em conjunto com o resto do time.

O app nativo pra macOS dessa mesma leva de novidades já foi coberto aqui antes, então esse post foca no restante do pacote que a Databricks lançou pro Genie One. A peça mais robusta é a colaboração em documento, rascunhar, editar e revisar relatório com visualização de dado ao vivo embutida, com histórico de versão, comentário, link de compartilhamento somente leitura e exportação em PDF.

Outras funcionalidades também chegam nessa leva. Dá pra transformar uma conversa curada em Genie Agent reutilizável, com o contexto da conversa virando a base do agente, e compartilhar esse agente com o time, desde que quem for usar tenha acesso ao workspace e ao SQL envolvido. Também é possível compartilhar um chat inteiro, com pergunta, resposta e visualização preservadas, e subir arquivo direto na conversa, CSV, Excel, PDF, imagem ou Word, mantido privado àquela conversa específica.

Pontos técnicos que valem atenção:
- Colaboração em documento com versionamento e comentário, pensado pra relatório vivo em vez de export estático
- Criação de agente a partir de conversa, reaproveitando contexto já validado pelo usuário
- Compartilhamento de chat somente leitura pra qualquer usuário da conta
- Genie Ontology Snippets, que integra Metric Views, Domains e Pages, com extração automática de regra de negócio a partir de dashboard, SQL e agente existente, respeitando a permissão da fonte original
- Upload de arquivo (CSV, Excel, PDF, imagem, Word) restrito à conversa
- Ações de escrita via MCP, permitindo o agente escrever de volta em sistema externo, tudo governado pelo Unity AI Gateway

**Minha ressalva:** ação de escrita via MCP governada pelo gateway é a peça mais poderosa e também a mais arriscada desse pacote, porque agente que escreve de volta em ticket, documento ou e-mail externo exige revisão de política bem mais rígida do que agente que só lê e responde. Vale revisar essa política antes de liberar write action em produção pra qualquer time.

**Fonte:** https://www.databricks.com/blog/beyond-answers-new-genie-one-features-turn-insights-action

#Databricks #GenieOne #IAGenerativa
