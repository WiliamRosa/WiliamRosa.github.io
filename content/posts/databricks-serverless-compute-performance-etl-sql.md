---
title: "Testei Serverless compute pra ETL e pra SQL do dia a dia, e o resultado surpreendeu"
date: 2026-09-17T10:00:00-03:00
draft: true
tags: ["Databricks", "Serverless", "Performance", "ETL"]
summary: "Teste hands-on de Josue Bogran mostrou o Serverless compute do Azure Databricks batendo resultados anteriores de SQL Serverless em velocidade e ficando competitivo em custo pra ETL, mesmo sem nenhum ajuste fino de cluster."
ShowToc: false
---

Nenhum node count, nenhuma versão de runtime pra escolher, e mesmo assim mais rápido que o esperado.

O Databricks MVP Josue Bogran testou o Serverless compute do Azure Databricks num dataset público grande, com uma tabela de fatos de mais de 7 bilhões de linhas, comparando desempenho e custo contra o que já tinha medido antes com SQL Serverless. O resultado o surpreendeu: o Serverless "genérico" (o mesmo usado pra notebook e job) bateu números que ele havia registrado anteriormente com SQL Serverless, e ficou competitivo em custo mesmo em cargas de ETL.

O único atrito identificado foi um tempo de scaling perceptível na primeira consulta grande, o join com a tabela de bilhões de linhas, algo que não se repetiu nas consultas seguintes. Fora esse aquecimento inicial, a experiência foi de computação disponível sem esperar cluster subir e sem escolher tamanho de cluster (t-shirt sizing).

Pontos técnicos e recomendações do teste:
- Pra ETL novo, orquestrado em SQL ou Python, Serverless virou escolha natural: custo baixo e zero tentativa e erro de dimensionamento
- Pra ETL existente já bem ajustado manualmente, vale testar migração, mas não é garantia de ganho automático
- Pra consulta analítica do dia a dia e dashboard, SQL Serverless warehouse continua sendo a opção mais barata
- Pra quem está começando agora no Azure Databricks, a recomendação foi usar Serverless geral por padrão e reservar SQL Serverless só pra cenário de BI
- Sem gerenciamento manual de cluster, cenários como "esqueci o cluster ligado" ou "dimensionei grande demais" praticamente desaparecem

**Minha ressalva:** são números de um teste individual, sem metodologia formal publicada nem controle rigoroso de variáveis, então vale tratar como direção e não como benchmark oficial da Databricks. Ainda assim, é o tipo de teste hands-on, feito por quem paga a conta na prática, que a documentação oficial raramente mostra.

**Fonte:** https://www.linkedin.com/feed/update/urn:li:activity:7505896749887254528/

#Databricks #Serverless #Performance
