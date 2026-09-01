---
title: "O Genie virou um app dentro do Microsoft Teams"
date: 2026-06-11T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Genie", "Microsoft Teams", "Opinião"]
summary: "Perguntar sobre dado do Lakehouse sem sair do Teams parece um detalhe de UX, mas muda quem realmente usa Genie no dia a dia."
ShowToc: false
---

🚀 O app do Databricks Genie chegou ao Microsoft Teams em beta: mensagem direta ou @menção num canal, e a pergunta roteia pro Genie ou pra um Genie Agent fixado — sem abrir o workspace do Databricks em nenhum momento.

Parece um detalhe de distribuição, mas é o tipo de mudança que decide se uma ferramenta de dados é usada por 50 pessoas do time de analytics ou por 5.000 pessoas da empresa inteira.

Por que essa integração pesa mais do que "mais um canal de acesso":
- A barreira de entrada pra perguntar algo ao Genie deixa de ser "ter conta e saber navegar no Databricks"
- Área de negócio já vive dentro do Teams o dia inteiro — a pergunta de dado se torna tão natural quanto perguntar pra um colega
- Governança do Unity Catalog continua valendo: quem pergunta só vê o que tem permissão de ver

❗ Minha ressalva: colocar uma ferramenta de linguagem natural dentro do canal onde todo mundo já está aumenta o volume de perguntas mal formuladas recebendo respostas mal calibradas. Facilitar o acesso sem investir em curadoria dos Genie Agents que respondem é trocar "ninguém usa" por "todo mundo usa errado".

🔗 Fonte: https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/june

#AzureDatabricks #Genie #MicrosoftTeams
