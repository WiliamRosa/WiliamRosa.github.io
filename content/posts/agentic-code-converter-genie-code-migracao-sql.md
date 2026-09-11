---
title: "Genie Code ganhou subagente pra migrar dialeto de SQL sozinho, com validação e retry"
date: 2026-09-10T10:30:00-03:00
draft: false
tags: ["Databricks", "Genie Code", "Migração", "Azure Databricks"]
summary: "O Databricks MVP Laurenz Wuttke detalhou o agentic code converter (Beta): o Genie Code converte script de T-SQL, Snowflake, Redshift, Oracle, BigQuery e Teradata pra ANSI SQL, com subagente validando e corrigindo cada arquivo em paralelo."
ShowToc: false
---

Migração de dialeto de SQL sempre foi trabalho manual demorado, script por script, corrigindo função proprietária uma de cada vez até tudo rodar igual no destino.

O Databricks MVP Laurenz Wuttke explicou como funciona o agentic code converter, recurso em beta que usa o Genie Code pra automatizar boa parte dessa migração. O fluxo começa com a criação de um projeto de migração dentro do workspace, que serve como painel central acompanhando o estado de cada arquivo. A partir daí, o Genie Code aciona uma skill específica de migração e distribui subagentes que trabalham em paralelo, cada um convertendo um arquivo do dialeto de origem, como T-SQL, Snowflake, Redshift, Oracle, BigQuery ou Teradata, pra ANSI SQL compatível com Databricks.

O diferencial em relação a um conversor de sintaxe tradicional é o loop de validação embutido: cada subagente não só traduz a query, ele valida o resultado e tenta de novo os trechos que falharam, em vez de entregar uma conversão que só parece certa até alguém rodar em produção. Isso não elimina a necessidade de revisão humana, mas tira do time boa parte do trabalho repetitivo de tradução linha a linha que consumia a maior parte do tempo numa migração desse tipo.

Pontos técnicos que valem atenção:
- Recurso em Beta, precisa ser ativado pelo admin do workspace na página de Previews
- Organizado como projeto de migração, que rastreia o estado de cada arquivo
- Suporta origem em T-SQL, Snowflake, Redshift, Oracle, BigQuery e Teradata
- Subagentes rodam em paralelo, cada um analisando, convertendo, validando e corrigindo seu próprio arquivo
- Resultado final é ANSI SQL pronto pra rodar no Databricks

**Minha ressalva:** validação automática reduz erro óbvio de sintaxe, mas não garante que a lógica de negócio embutida numa stored procedure legada sobreviveu intacta à tradução. Query complexa com efeito colateral específico do dialeto de origem ainda merece revisão humana linha a linha antes de ir pra produção, não só o sinal verde do validador automático.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/migration/agentic-code-converter

#Databricks #GenieCode #Migracao
