---
title: "Por que o Lakebase colocou object storage embaixo de um Postgres transacional"
date: 2026-09-01T00:05:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Postgres", "LinkedIn", "Opinião"]
summary: "A resposta não é sobre velocidade: é sobre onde fica a fonte da verdade quando quem opera o banco pode ser um agente, não um humano."
ShowToc: false
---

A Databricks acabou de detalhar por que colocou object storage embaixo de um banco Postgres transacional, e a resposta não é sobre velocidade.

O Lakebase separa compute de armazenamento, com a fonte de verdade vivendo em object storage. Isso muda o motivo de existir de um OLTP: deixa de ser só "banco para aplicação" e vira infraestrutura pensada para agentes que criam, clonam e derrubam bancos em segundos.

O que isso destrava na prática:
- Governança única via Unity Catalog, sem uma segunda camada de permissão só pro banco operacional
- Branch de banco como operação de rotina, não projeto de infraestrutura
- Agente decide provisionar/descartar ambiente sozinho, sem esperar um humano

**Minha ressalva:** bancos transacionais não perdoam latência de I/O. A Databricks ainda não publicou latência p99 sob concorrência real, é o primeiro benchmark que eu pediria antes de colocar carga crítica em cima disso.

**Fonte:** https://www.databricks.com/blog/object-storage-wal-lakebase-postgres-agentic-era

#Databricks #Lakebase #EngenhariaDeDados
