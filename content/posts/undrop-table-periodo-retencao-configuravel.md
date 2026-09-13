---
title: "UNDROP TABLE ganhou período de retenção configurável em vez dos sete dias fixos"
date: 2026-09-14T15:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Governança", "Opinião"]
summary: "Em Public Preview, ALTER CATALOG ou ALTER SCHEMA com a cláusula RETAIN DROPPED TO permite configurar entre zero (desabilita recuperação) e trinta dias quanto tempo uma tabela gerenciada derrubada fica recuperável via UNDROP TABLE, com a configuração de schema tendo precedência sobre a de catálogo."
ShowToc: false
---

O Databricks MVP Derar Alhussein destacou um ajuste fino de governança que muda um comportamento que até então era fixo: o período de sete dias em que uma tabela derrubada por engano ficava recuperável.

O Unity Catalog sempre manteve tabela gerenciada derrubada recuperável via `UNDROP TABLE` por sete dias, prazo fixo e igual pra todo mundo. Agora, em Public Preview, dá pra configurar esse período em nível de catálogo ou de schema usando a cláusula `RETAIN DROPPED TO`, aceitando de zero horas, que desativa completamente a recuperação, até trinta dias. Isso importa tanto pra quem precisa de uma janela maior de segurança operacional quanto pra quem, por política de retenção de dado regulada, precisa garantir que dado apagado realmente suma rápido e não fique recuperável por padrão.

A configuração é declarativa e pode ser feita tanto na criação quanto depois: `CREATE CATALOG meu_catalogo RETAIN DROPPED FOR 30 DAYS` ou `ALTER SCHEMA meu_catalogo.meu_schema RETAIN DROPPED TO 7 DAYS`, por exemplo. Quando catálogo e schema têm configuração diferente, o valor definido no schema é o que vale pras tabelas daquele schema específico.

Pontos técnicos:

- Configurável via `ALTER CATALOG` / `ALTER SCHEMA ... RETAIN DROPPED TO`, ou na criação com `RETAIN DROPPED FOR`
- Aceita de zero horas (desabilita recuperação via UNDROP) até trinta dias
- Configuração em nível de schema tem precedência sobre a de catálogo quando os dois estão definidos
- Exige privilégio `MANAGE` ou posse do catálogo/schema pra alterar o período
- Mudança só vale pra tabela derrubada depois da configuração, não retroage sobre tabela já derrubada antes
- Arquivo de dado da tabela é efetivamente apagado do armazenamento em nuvem em até 48 horas depois do fim do período de recuperação

**Minhas considerações:** dar esse controle pro nível de schema é o tipo de granularidade que faz sentido numa organização com times diferentes tendo tolerância a risco diferente, um schema de sandbox pode ter zero retenção e um schema de produção crítica pode ir até os trinta dias. O ponto de atenção é justamente a irretroatividade: configurar isso hoje não protege tabela que já foi derrubada ontem sob a regra antiga de sete dias.

Fonte: https://learn.microsoft.com/en-us/azure/databricks/tables/managed

#Databricks #UnityCatalog #AzureDatabricks
