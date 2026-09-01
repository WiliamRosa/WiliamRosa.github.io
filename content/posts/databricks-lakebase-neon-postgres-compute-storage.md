---
title: "O DNA do Neon Postgres dentro do Lakebase: o que a separação compute/storage muda para quem provisiona banco"
date: 2026-08-25T09:00:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Neon", "Postgres", "Arquitetura", "Opinião"]
summary: "Na conversa com Nikita Shamgunov, VP de Engenharia da Databricks, fica mais claro de onde vem a arquitetura do Lakebase — e por que 'agente provisionando banco sozinho' deixou de ser ficção científica."
ShowToc: true
---

## O que a Databricks anunciou

A Databricks publicou uma conversa com **Nikita Shamgunov**, VP de Engenharia e um dos fundadores do Neon, sobre a ideia por trás do **Neon Postgres** que hoje sustenta o **Lakebase**: separar compute e armazenamento em um banco Postgres OLTP. A discussão explora como object storage pode tornar dados operacionais disponíveis para sistemas downstream, por que arquitetura de banco "developer-first" importa, e o que muda quando agentes começam a provisionar bancos, criar branches de dados e gerenciar o estado de aplicações sozinhos.

Fonte original: [post da Databricks no LinkedIn](https://lnkd.in/gCfiCrNU)

## Por que isso importa na prática

"Branch de banco de dados" como conceito não é novo para quem trabalha com Neon isoladamente — é uma das features que mais chamou atenção quando o produto ganhou popularidade fora do universo Databricks. O que essa conversa deixa claro é a intenção estratégica: trazer esse modelo mental (banco como recurso que se cria, clona e descarta com a mesma leveza de um container) para dentro do Lakehouse, sob o mesmo Unity Catalog que já governa o resto dos dados.

Isso se conecta diretamente com o [post de arquitetura do Lakebase](/posts/databricks-lakebase-postgres-arquitetura-agentes.md) que também cobri nesta série: aquele foca no "porquê" object storage embaixo de um transacional; esse aqui explica de onde veio tecnicamente essa capacidade — a aquisição e a arquitetura do Neon.

## Minha opinião

Como alguém que lida com provisionamento de ambiente de dados no dia a dia, a parte que mais me chama atenção não é a separação compute/storage em si — isso já é tese validada desde o Snowflake no mundo analítico — é a normalização do **branch de banco transacional** como operação rotineira. Hoje, criar um ambiente de teste isolado com uma cópia realista de produção ainda é, na maioria das empresas que conheço, um processo manual, lento e caro em armazenamento. Se um agente consegue fazer isso em segundos porque o banco é fundamentalmente copy-on-write sobre object storage, isso muda o ciclo de desenvolvimento de qualquer aplicação transacional, não só as orientadas a IA.

O ponto que eu colocaria em xeque é a maturidade operacional dessa promessa em escala empresarial regulada. Criar e descartar bancos rapidamente é ótimo para desenvolvimento e teste; para dados que tocam informação sensível, cada branch é potencialmente uma nova superfície de auditoria e retenção que o time de governança precisa entender — e isso raramente é tão simples quanto a demonstração técnica sugere.

De qualquer forma, é a peça que estava faltando para eu entender por que a Databricks investiu tanto em Postgres transacional quando já dominava o mundo analítico: não é sobre competir com bancos OLTP tradicionais, é sobre dar ao agente autonomia de infraestrutura sem sair do Lakehouse.

## Para saber mais

- Post original: https://lnkd.in/gCfiCrNU
- Documentação oficial do Databricks: https://docs.databricks.com/
