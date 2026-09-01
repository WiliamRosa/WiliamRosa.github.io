---
title: "Databricks Runtime 18 virou LTS e matou a pergunta '18.1 ou 18.2?'"
date: 2026-08-12T09:00:00-03:00
draft: false
tags: ["Databricks", "Databricks Runtime", "DevOps", "Opinião"]
summary: "A partir do Runtime 18, a Databricks unificou as release notes: sem mais versão menor pra decorar, features novas chegam como atualizações datadas na mesma página."
ShowToc: false
---

🚀 O Databricks Runtime 18 é o primeiro a usar um formato unificado de release notes: em vez de cada versão menor (18.0, 18.1, 18.2...) ganhar sua própria página, toda novidade, mudança de comportamento e correção entra como uma atualização datada na mesma página do Runtime 18 — sem trocar o número da versão.

Isso resolve um atrito pequeno, mas constante, de quem mantém Databricks Asset Bundles e pipelines de CI/CD apontando pra uma versão específica de runtime: a pergunta recorrente "espera, era 18.2 ou 18.3 que tinha essa feature?" simplesmente deixa de fazer sentido — o que antes seria uma versão menor nova agora é só mais uma entrada datada na mesma página.

Por que essa mudança de convenção importa na prática:
- Elimina a necessidade de decorar em qual sub-versão uma feature específica apareceu
- Simplifica o pin de versão em bundle/YAML: "18.x" cobre o runtime inteiro, sem se preocupar em qual "sub-release" está rodando
- Times que documentam internamente "qual runtime usar" ganham uma única referência viva em vez de várias páginas históricas fragmentadas

❗ Minha ressalva: unificar a documentação por trás de um único número de versão facilita a vida de quem lê, mas exige mais disciplina de quem escreve testes de regressão — se uma mudança "menor" já não gera uma versão nova identificável, o time precisa confiar mais em pipeline de teste automatizado e menos em "só travar numa versão que já testamos e sabemos que funciona".

🔗 Fonte: https://docs.databricks.com/aws/en/release-notes/runtime/18

#Databricks #DatabricksRuntime #DevOps
