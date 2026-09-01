---
title: "Lakebase Postgres: por que o banco transacional da era dos agentes começa pelo object storage"
date: 2026-09-01T00:00:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Postgres", "Arquitetura", "Agentes de IA", "Opinião"]
summary: "A Databricks anunciou os detalhes de arquitetura do Lakebase Postgres. Minha leitura sobre por que separar compute e armazenamento pode ser o passo que faltava para bancos operacionais aguentarem cargas geradas por agentes."
ShowToc: true
---

## O que a Databricks anunciou

A Databricks publicou um artigo detalhando a arquitetura por trás do **Lakebase Postgres**, seu banco de dados transacional serverless. A pergunta que abre o material é direta: faz sentido colocar object storage *embaixo* de um banco transacional? A resposta da engenharia da Databricks é que sim — e que o lugar onde você posiciona a fonte da verdade dos dados importa mais do que a velocidade bruta do object store em si.

A tese central é que um Postgres construído dessa forma deixa de ser só "mais um OLTP" e passa a ser uma evolução pensada para **cargas de trabalho agênticas**: agentes que criam bancos, fazem branch de dados, escrevem e leem em padrões muito mais imprevisíveis do que uma aplicação tradicional com tráfego humano.

Fonte original: [post da Databricks no LinkedIn](https://lnkd.in/gJS6kPeM)

## Por que isso importa na prática

Quem trabalha com Unity Catalog e Lakehouse no dia a dia sabe que historicamente sempre existiu uma fronteira nítida entre o mundo analítico (Delta Lake, object storage, processamento em lote/streaming) e o mundo transacional (bancos OLTP tradicionais, geralmente fora do Lakehouse, com sua própria governança). Essa fronteira gera duplicação de dados, pipelines de sincronização e — o pior — dois sistemas de governança para manter alinhados.

Se o Lakebase realmente consegue rodar OLTP com a fonte de verdade em object storage, isso reduz drasticamente a necessidade de mover dados transacionais para fora do Lakehouse só para servir uma aplicação. Unity Catalog passa a governar de ponta a ponta, sem uma segunda camada de permissões para o banco operacional.

## Minha opinião

Tecnicamente, separar compute de storage não é novidade — é o que fez o Snowflake ganhar tração no mundo analítico, e é a mesma lógica por trás do Neon Postgres (que a Databricks adquiriu e que aparentemente é a base do Lakebase, como abordo no [artigo sobre a entrevista com Nikita Shamgunov](/posts/databricks-lakebase-neon-postgres-compute-storage/)). O que muda de fato aqui é o público-alvo: não é mais só analista rodando query pesada, é um agente autônomo decidindo, em tempo de execução, que precisa provisionar um banco, popular com dados e derrubar minutos depois.

Meu ceticismo saudável fica por conta da promessa de desempenho. Bancos transacionais são implacáveis com latência de I/O, e object storage historicamente não foi desenhado para isso — daí toda a engenharia de camadas de cache e write-ahead log que normalmente entra no meio do caminho. A Databricks não detalhou publicamente números de latência p99 sob concorrência real, e é exatamente isso que eu testaria antes de colocar uma aplicação crítica de produção em cima do Lakebase.

Na prática, para quem já vive o dia a dia de governança no Unity Catalog, vale acompanhar de perto: se a promessa se confirmar, é uma redução real de complexidade arquitetural para quem constrói aplicações orientadas a agentes sobre o Lakehouse.

## Para saber mais

- Post original: https://lnkd.in/gJS6kPeM
- Documentação oficial do Databricks: https://docs.databricks.com/
