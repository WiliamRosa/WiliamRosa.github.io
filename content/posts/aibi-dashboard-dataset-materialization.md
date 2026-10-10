---
title: "Dataset Materialization no AI/BI: pré-computar resultado pra não repetir a mesma consulta cara"
date: 2026-10-10T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "AI/BI", "Dashboards"]
summary: "A Databricks MVP Nidhi Gupta detalhou a Dataset Materialization dos dashboards AI/BI: em vez de rodar a mesma consulta a cada abertura do dashboard, o resultado fica pré-computado e é servido direto, opção habilitada via Previews pra dataset em SQL ou tabela."
ShowToc: false
---

A Databricks MVP Nidhi Gupta escreveu sobre um problema comum em dashboard AI/BI com muito acesso simultâneo: cada usuário que abre o dashboard dispara a mesma consulta de novo, mesmo quando o dado por trás não mudou desde a última execução.

A Dataset Materialization ataca esse padrão diretamente. Em vez de manter o dataset como consulta viva que recalcula a cada carregamento, o resultado é pré-computado uma vez e servido como dado materializado pras visualizações seguintes, até a próxima atualização.

Pontos que a análise detalha:

- A diferença central é entre consulta viva (live query), que recalcula a cada carregamento, e resultado pré-computado, que é servido direto sem repetir a execução
- A opção de materialização está disponível pra dataset baseado em SQL e também pra dataset baseado em tabela
- O recurso precisa ser habilitado pela página de Previews do workspace antes de aparecer como opção
- A decisão de materializar ou não depende do padrão de acesso do dashboard: ganho real aparece quando muita gente abre o mesmo dashboard entre uma atualização de dado e outra, não em dashboard de acesso esporádico

**Minhas considerações:** esse tipo de recurso é fácil de subestimar porque não aparece como feature vistosa, mas é exatamente o tipo de ajuste que separa um dashboard que escala de um que degrada sob uso real. Antes de habilitar materialização em tudo, vale mapear quais dashboards realmente têm esse padrão de muita leitura concorrente contra pouca mudança de dado, porque materializar sem necessidade só adiciona complexidade de quando o dado pré-computado ficou desatualizado.

**Fonte:** https://medium.com/@nidhig631/databricks-dataset-materialization-594bef4f21ce

#AzureDatabricks #AIBI #Dashboards
