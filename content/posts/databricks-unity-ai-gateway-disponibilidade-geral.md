---
title: "Unity AI Gateway chega à disponibilidade geral: governança de IA deixou de ser opcional"
date: 2026-08-11T08:30:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Unity AI Gateway", "Governança", "FinOps", "Opinião"]
summary: "Com a GA do Unity AI Gateway e mais de um quatrilhão de tokens já processados, a Databricks formaliza algo que quem trabalha com governança de dados já sentia: administrar agentes de IA é, antes de tudo, um problema de governança."
ShowToc: true
---

## O que a Databricks anunciou

A Databricks anunciou a **disponibilidade geral (GA)** do **Unity AI Gateway**, o hub central de governança para todo ativo de IA da organização — modelos, agentes externos, servidores MCP, skills e assistentes de código. Segundo o anúncio, mais de **um quatrilhão de tokens** já passaram pelo gateway no último ano, com observabilidade de ponta a ponta e atribuição granular de custo por modelo, provedor, time e aplicação.

O argumento da Databricks é simples: a era de gerenciar "um punhado de modelos" acabou. Agora se governa uma frota de agentes e aplicações que acessam dados, chamam ferramentas e agem sozinhos — e isso muda completamente o que "governança de IA" precisa cobrir.

Fonte original: [post da Databricks no LinkedIn](https://www.databricks.com/blog/unity-ai-gateway-generally-available)

## Por que isso importa na prática

Quem administra Unity Catalog sabe que governança de dados já é, por si só, um trabalho contínuo: quem acessa o quê, com qual política de mascaramento, sob qual linhagem. O Unity AI Gateway está fazendo o mesmo movimento, só que para chamadas de modelo e execução de agente — tratando cada requisição de IA como um evento governável, com custo, política e auditoria, e não como uma chamada de API isolada e opaca.

Isso conecta diretamente com outro anúncio recente da própria Databricks, sobre orçamento diário e mensal para controlar gastos de coding agents internamente (que também comento [neste outro post](/posts/databricks-governanca-gastos-ia-coding-agents/)) — ambos nascem do mesmo problema real: gasto de IA virou uma das linhas que mais cresce no orçamento de engenharia, e sem um ponto central de controle, ele se torna invisível até a fatura chegar.

## Minha opinião

Esse é, na minha visão, o anúncio mais estruturalmente importante da lista que estou cobrindo nesta série — mais até do que os lançamentos de modelo. Ferramentas de IA generativa mudam de mês em mês; a necessidade de um plano de controle central para governar acesso, custo e comportamento de agentes é estrutural e vai continuar existindo independente de qual modelo estiver na moda.

O ponto de atenção que eu levantaria para quem for adotar: centralizar tudo em um gateway cria um ponto único de dependência crítica. Vale perguntar como fica a resiliência (o que acontece se o gateway cair?) e como a Databricks trata multi-cloud e modelos hospedados fora do seu próprio ecossistema — a promessa é "todo ativo de IA", mas a profundidade de governança tende a ser maior justamente para o que já vive dentro do Lakehouse.

Para quem lidera comunidade e treina gente em Databricks, como eu, esse é o tipo de anúncio que muda o que ensino: já não basta explicar Unity Catalog para dados, é hora de incluir Unity AI Gateway como parte do currículo básico de governança.

## Para saber mais

- Post original: https://www.databricks.com/blog/unity-ai-gateway-generally-available
- Documentação oficial do Databricks: https://docs.databricks.com/
