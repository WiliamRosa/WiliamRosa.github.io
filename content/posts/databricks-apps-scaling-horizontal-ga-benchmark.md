---
title: "Cinco instâncias sustentaram 4.640 req/s, mas o gargalo não foi onde parecia"
date: 2026-10-31T11:00:00-03:00
draft: true
tags: ["Databricks Apps", "Azure Databricks", "Performance"]
summary: "O Databricks MVP Domonkos Pal testou a GA do horizontal scaling de Databricks Apps e mediu crescimento quase linear de throughput até um platô por instância em torno de 730 a 960 req/s, com o gargalo real migrando pra ordenação no banco em consulta pesada."
ShowToc: false
---

Cinco instâncias XL sustentaram 4.640 requisições por segundo por mais de cinco minutos sem erro, mas o gargalo não foi onde parecia.

O Databricks MVP Domonkos Pal publicou um teste de carga próprio sobre a disponibilidade geral do horizontal scaling de Databricks Apps, complementando o que já cobrimos aqui sobre Serverless Micro Apps e scale-to-zero: enquanto o scale-to-zero resolve custo ocioso, o horizontal scaling resolve throughput, e são mecanismos diferentes dentro da mesma plataforma de Apps.

Escalar um Databricks App horizontalmente hoje significa fixar manualmente quantas instâncias rodam, até cinco por app e até vinte apps escalados por workspace, sem autoscaling baseado em carga. Pal mediu que o throughput cresce de forma quase linear com o número de instância numa consulta simples de chave primária, mas identificou um platô real por instância em torno de 730 a 960 requisições por segundo, independente do tamanho da instância, então o ganho de escalar vem de somar instância, não de trocar pra uma instância maior.

Pontos técnicos que valem atenção:
- Cinco instâncias XL sustentaram 4.640 req/s por 5,4 minutos, 1,5 milhão de requisições, zero erro, p99 de 68ms, p99 de consulta Lakebase de 8ms
- Uma instância XL isolada serviu 958 req/s, cinco instâncias serviram 5.052 req/s, crescimento próximo de linear
- Em requisição mais pesada, consulta indexada complexa, o teto ficou perto de 1.100 req/s tanto com cinco instâncias L quanto cinco XL, porque o gargalo passou a ser a ordenação no banco, não a CPU da instância do app
- Passado o pico de carga, o roteador responde HTTP 502 em vez de enfileirar requisição, então a recomendação é manter margem de capacidade, não operar no limite
- Chamada de API pra escalar falhou na primeira tentativa em cerca de metade dos casos, com sucesso no retry

**Minhas considerações:** o dado mais útil aqui não é o número de pico, é o platô por instância independente do tamanho, isso muda completamente como planejar capacidade. Não dá pra simplesmente comprar instância maior esperando mais throughput por unidade, o caminho é escalar na horizontal e cuidar do gargalo real, que no teste de Pal acabou sendo o banco, não o app.

**Fonte:** https://hiflylabs.com/blog/2026/10/30/databricks-apps-scaling

#DatabricksApps #AzureDatabricks #Performance
