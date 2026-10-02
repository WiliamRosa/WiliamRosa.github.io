---
title: "Trocar Aurora Serverless por Lakebase melhorou performance e ainda cortou custo"
date: 2026-09-26T18:00:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Postgres", "Arquitetura"]
summary: "O Databricks MVP Pål de Vibe migrou o backend de uma aplicação Postgres da AWS Aurora Serverless para o Databricks Lakebase, relatando ganho radical de performance, corte de custo e simplificação da arquitetura de nuvem da fintech Kvidd."
ShowToc: false
---

Trocar o banco transacional de uma aplicação de produção raramente é indolor, mas às vezes o resultado surpreende por melhorar tudo de uma vez: performance, custo e simplicidade.

O Databricks MVP Pål de Vibe migrou o backend Postgres de uma aplicação de produção da AWS Aurora Serverless para o Databricks Lakebase. O caso, documentado em artigo coautorado com o Field CTO de Life Sciences da Databricks, Surya Sai Turaga, envolve a fintech Kvidd, e reporta melhora radical de performance combinada com corte adicional de custo, algo que normalmente é escolha de um ou outro, não os dois juntos.

Além do ganho direto em performance e custo, a migração trouxe um efeito colateral estratégico: colocar o dado da aplicação diretamente dentro do Databricks deixa a Kvidd pronta para IA de um jeito que manter o dado transacional isolado num Aurora externo não permitia. A gestão de ambientes e a testabilidade do banco também ficaram mais ágeis e instantâneas, o que ele descreve como crucial para quem faz programação agêntica rápida e segura.

Pontos técnicos da migração:

- Migração de backend Postgres de AWS Aurora Serverless para Databricks Lakebase
- Melhora radical de performance relatada após a migração
- Corte de custo adicional, não apenas manutenção do custo anterior
- Simplificação da arquitetura de nuvem, eliminando a necessidade de um banco OLTP externo separado
- Dado da aplicação passa a morar dentro do Databricks, tornando a fintech Kvidd pronta para IA
- Gestão de ambiente e testabilidade do banco tornaram-se ágeis e instantâneas

**Minha leitura:** o que torna esse caso interessante não é só o ganho de performance, é o argumento de que trazer o dado transacional para dentro do Databricks remove a necessidade da ponte complexa entre OLTP externo e lakehouse que a maioria das arquiteturas ainda carrega. Para quem está avaliando se vale a pena migrar um backend de produção para o Lakebase, esse é um caso real com número e arquitetura documentados, não apenas uma promessa de feature nova.

**Fonte:** https://www.linkedin.com/in/paal-de-vibe/#migracao-aurora-serverless-lakebase

#Databricks #Lakebase #Postgres
