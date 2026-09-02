---
title: "Pages dá ao Genie Ontology o que faltava: uma definição de negócio que alguém realmente escreveu"
date: 2026-08-19T09:00:00-03:00
draft: false
tags: ["Databricks", "Genie", "UnityCatalog", "Opinião"]
summary: "Pages (Beta) deixa times documentarem conceito de negócio dentro do Unity Catalog, organizado por domínio, e o Genie One passa a priorizar essa definição humana em vez de inferir tudo sozinho."
ShowToc: false
---

Genie Ontology sempre teve o problema inverso ao esperado: monta contexto automaticamente demais, e às vezes automaticamente demais é o problema, não a solução.

A Databricks MVP Zoë Van Noppen destacou o Pages assim que a funcionalidade entrou em beta: uma aba nova dentro do Discover onde o time define conceito de negócio explicitamente, organizado por Domínio, em vez de deixar tudo por conta da inferência automática do Genie Ontology.

O mecanismo funciona como um glossário vivo dentro do Unity Catalog. Cada Page define um conceito de negócio, seus sinônimos, e linka os ativos relacionados (tabela ou objeto do workspace que aquele conceito conecta) e as fontes de onde ele se originou, incluindo link externo pra ferramenta como Notion, quando a documentação já vive fora do Databricks. A parte mais interessante: já dá pra gerar Page a partir de documento existente usando Genie Code e seus conectores MCP, em vez de escrever cada definição manualmente do zero. Quando o Genie One responde uma pergunta sobre um conceito que tem Page definida, ele prioriza essa definição humana em vez do que inferiria sozinho, e cita a Page como fonte.

Pontos técnicos que valem registrar:
- Pages são organizadas por Domínio e Subdomínio dentro do Discover
- Suportam link pra ativo do Unity Catalog ou workspace, e link externo pra fonte de documentação
- Já dá pra gerar Page automaticamente a partir de documento existente via Genie Code e conectores MCP
- Ainda não tem versionamento, e a Page em si não é um objeto do Unity Catalog

**Minha ressalva:** gerar Page automaticamente a partir de documentação existente resolve o problema de começar do zero, mas cria um risco novo: sem versionamento, não tem como saber se aquela definição ainda reflete a realidade seis meses depois, ou se alguém mudou a regra de negócio sem atualizar a Page. Documentação desatualizada que o Genie trata como fonte de verdade prioritária é pior do que nenhuma documentação, porque erra com confiança em vez de admitir incerteza.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/uc-semantics/pages

#Databricks #Genie #UnityCatalog
