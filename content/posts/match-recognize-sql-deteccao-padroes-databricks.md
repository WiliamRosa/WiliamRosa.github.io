---
title: "MATCH_RECOGNIZE chega ao Databricks SQL pra achar padrão de evento sem gambiarra de CTE"
date: 2026-09-17T11:00:00-03:00
draft: false
tags: ["Databricks", "SQL", "Databricks SQL", "Análise de Dados"]
summary: "A Databricks lançou em Public Preview o operador MATCH_RECOGNIZE, que detecta sequência e padrão em dados de evento de forma declarativa, substituindo o empilhamento de CTE, window function e lógica de gaps and islands que esse tipo de análise normalmente exige."
ShowToc: false
---

Detectar sequência de eventos em SQL sempre foi sinônimo de CTE encadeada e window function difícil de revisar depois.

A Databricks lançou o MATCH_RECOGNIZE em Public Preview no Databricks SQL, um operador que reconhece padrões e sequências em dados de evento de forma declarativa, como se fosse regex aplicado a linhas em vez de caracteres. A ideia central é simples: SQL tradicional trata linha como conjunto sem ordem inerente, então identificar algo como "cinco falhas de login seguidas de um sucesso" hoje exige empilhar CTE, função de janela e a clássica lógica de gaps and islands.

Com o novo operador, o fluxo passa a ser particionar o dado pela coluna relevante, ordenar por timestamp, e descrever o padrão numa cláusula DEFINE com sintaxe parecida com regex, usando funções como FIRST(), PREV() e NEXT() pra ancorar momentos específicos da sequência, incluindo a âncora `$` de fim de partição pra detectar ausência de evento esperado.

Casos de uso citados no anúncio:
- Segurança: identificar credential stuffing, cinco ou mais falhas de login numa janela de uma hora seguidas de sucesso imediato
- Mercado financeiro: encontrar padrão em V no preço de uma ação, queda seguida de recuperação
- E-commerce: identificar usuário de alta intenção que abandona o carrinho depois de adicionar item
- Manufatura e IoT: prever falha de equipamento a partir de sensor mostrando temperatura subindo seguida de pico de vibração
- Disponível hoje em compute Databricks, incluindo Lakehouse Real-Time

**Minhas considerações:** sequência de eventos é justamente o tipo de análise que sempre empurra o time de dados pra SQL feio ou pra sair do SQL e escrever Python puro. Ter isso como sintaxe declarativa nativa reduz bastante a barreira pra quem não quer lidar com window function complexa toda vez que precisa achar um padrão temporal. Ainda em Public Preview, então vale testar antes de colocar em produção como parte crítica de um pipeline.

**Fonte:** https://www.databricks.com/blog/regex-rows-simplifying-pattern-detection-sql-matchrecognize

#Databricks #DatabricksSQL #AnaliseDeDados
