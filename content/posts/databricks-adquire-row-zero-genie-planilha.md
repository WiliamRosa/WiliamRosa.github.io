---
title: "A Databricks comprou uma planilha de bilhão de linhas pra virar a mão do Genie"
date: 2026-09-25T09:00:00-03:00
draft: true
tags: ["Databricks", "Genie", "Aquisição", "Opinião"]
summary: "A Databricks adquiriu a Row Zero, startup de planilha que roda cada arquivo numa instância dedicada e aguenta bilhão de linha, pra dar ao Genie uma interface de planilha nativa, governada por Unity Catalog e Unity Gateway, com permissão, auditoria e write-back."
ShowToc: false
---

A Databricks comprou a Row Zero, startup de Seattle que construiu uma planilha capaz de aguentar até um bilhão de linhas, e a aposta é clara: dar ao Genie a interface que todo usuário de negócio já sabe usar de cor.

A Row Zero roda cada planilha numa instância dedicada na nuvem em vez de depender do limite de memória do navegador, o que explica como ela aguenta volume que travaria Excel ou Google Sheets. Ela já tinha conector nativo pra fonte de dado como o próprio Databricks, com atualização automática da planilha quando o registro de origem muda. O que a aquisição muda é o destino dessa tecnologia: em vez de continuar só como produto standalone, ela vira a camada de visualização e edição nativa do Genie, acessível direto do chat, no navegador, no desktop ou no celular.

A integração prometida (ainda não lançada, só anunciada) apoia a planilha em cima da infraestrutura de governança que a Databricks já constrói há tempo: Genie Ontology define o contexto de negócio, Unity Catalog aplica permissão linha a linha, Unity Gateway governa o acesso a modelo. Isso significa que o usuário de negócio sai de uma pergunta em linguagem natural no Genie e cai direto numa planilha funcional com pivot, fórmula compatível com Excel e Google Sheets, e gráfico, sem que esse trecho intermediário exija replicar dado nem burlar controle de acesso.

Pontos técnicos destacados pela Databricks:

- Cada planilha roda isolada, suportando até um bilhão de linhas com performance interativa
- Permissão de usuário é respeitada em cada consulta, e dado atualiza a partir da fonte viva, sem cópia manual
- Administrador consegue restringir exportação, e usuário pode escrever de volta pro dado de origem, com toda ação auditável
- Ação de agente feita através da planilha continua interpretável e auditável em termos de planilha comum
- Vai estar disponível pra cliente Databricks em qualquer nuvem principal, mantendo suporte a fonte de dado fora do Databricks

**Minha ressalva:** tudo isso ainda é promessa de integração, não feature já disponível. A Databricks não divulgou valor do negócio, data de lançamento da integração nem preço da experiência combinada, e o próprio CEO da Row Zero confirmou que o produto standalone continua disponível enquanto o time embute a tecnologia dentro da Databricks. Vale acompanhar quando isso efetivamente aparecer dentro do workspace antes de assumir que o usuário de negócio já tem essa planilha nativa hoje.

**Fonte:** https://www.databricks.com/company/newsroom/press-releases/databricks-acquires-row-zero-bringing-live-governed-spreadsheets

#Databricks #Genie #UnityCatalog
