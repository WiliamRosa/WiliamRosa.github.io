---
title: "Databricks é mais barato no fim das contas, mas você só descobre isso depois de gastar"
date: 2026-09-15T09:00:00-03:00
draft: true
tags: ["Databricks", "FinOps", "Preços", "Opinião"]
summary: "O Databricks MVP Josue Bogran apontou que a forma como o Azure Databricks comunica preço, DBU e controle de custo antes do uso ainda deixa a desejar, mesmo a plataforma sendo competitiva depois que os workloads já estão rodando."
ShowToc: false
---

Descobrir quanto vai custar rodar um workload novo no Azure Databricks ainda é mais fácil depois de já ter gastado do que antes.

O Databricks MVP Josue Bogran defendeu que, apesar de considerar o Azure Databricks geralmente a opção mais em conta em dados e IA, principalmente conforme a operação escala, a forma como a plataforma comunica preço antes do uso ainda tem bastante espaço pra melhorar. Segundo ele, ajustar uma cobrança pequena depois que você já está dentro da plataforma é tranquilo, mas entender de antemão quanto vai custar expandir pra um tipo de workload novo, ou avaliar a plataforma pela primeira vez, é bem mais difícil do que deveria.

O ponto central da crítica é a abstração de DBU: ela funciona bem pra quem já conhece o comportamento da própria carga de trabalho, mas cria uma camada extra de tradução pra quem está tentando decidir orçamento com a executiva antes de qualquer coisa rodar.

Pontos que ele levantou:
- A calculadora de preço do Azure Databricks existe e cobre mais detalhes, mas a experiência de uso ainda fica atrás da calculadora da Snowflake em clareza de apresentação
- O problema não é o preço em si, e sim a dificuldade de alinhar engenheiro e executivo numa mesma expectativa de custo antes do fato
- Isso pesa mais justamente em dois momentos críticos: expansão pra workload novo e avaliação inicial da plataforma por quem ainda não é cliente

**Minha ressalva:** concordo que abstração de DBU tem seu valor técnico, mas ela desloca o trabalho de tradução de custo pra quem menos tem contexto pra fazer essa conta, o time de negócio que está decidindo se aprova o projeto. Enquanto isso não muda, a saída prática continua sendo documentar internamente uma tabela de conversão DBU-para-custo-real específica do seu workload, em vez de esperar que a calculadora oficial resolva isso sozinha.

**Fonte:** https://www.linkedin.com/feed/update/urn:li:activity:7505294991842500608/

#Databricks #FinOps #Precos
