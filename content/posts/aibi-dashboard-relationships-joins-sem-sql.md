---
title: "AI/BI Dashboard ganha relationships: join entre dataset sem reescrever SQL nem duplicar linha"
date: 2026-10-10T16:00:00-03:00
draft: false
tags: ["Azure Databricks", "AI/BI", "Dashboards"]
summary: "Dashboard relationships do AI/BI, em Public Preview, deixa modelar o join entre datasets de um dashboard direto na interface, com cardinalidade explícita (many-to-one ou one-to-many), sem pré-juntar tabela em SQL nem criar objeto no Unity Catalog."
ShowToc: false
---

A Databricks MVP Abiola David destacou um recurso de AI/BI Dashboard que resolve um problema comum de quem monta dashboard com múltiplos dataset de granularidade diferente: cruzar métrica de uma tabela fato com outra sem pré-juntar tudo em SQL e correr risco de duplicar linha.

O recurso se chama dashboard relationships e fica na aba Data do dashboard, numa seção dedicada de Relationships. Em vez de escrever o join manualmente em cada consulta, você aponta os dois datasets, escolhe o campo de cada lado e define a cardinalidade da relação; o dashboard monta um modelo semântico próprio a partir disso, que outras visualizações do mesmo dashboard passam a reaproveitar.

Pontos técnicos do recurso:

- Recurso está em Public Preview na documentação atual (uma versão antiga da documentação do GCP ainda lista como Private Preview, o que sugere rollout por região/cloud não é simultâneo)
- Exige permissão CAN EDIT no dashboard, CAN USE no SQL warehouse, e pelo menos dois datasets já adicionados ao dashboard antes de começar
- Cardinalidade tem duas opções: many-to-one, quando o dataset da esquerda é a tabela fato e o da direita é dimensão, ou one-to-many, o inverso; o exemplo oficial usa `web_sales.customer_id = customers.customer_id` como many-to-one
- A relação fica escopada ao dashboard, não cria objeto nenhum no Unity Catalog; pra métrica que precisa ser reaproveitada entre dashboards diferentes ou outra ferramenta, a documentação indica usar metric view do Unity Catalog em vez disso
- Existe também a opção de local metric view, que modela dimensão, medida e relação de join via interface visual mantendo tudo dentro de um único dashboard, também em Public Preview

**Minhas considerações:** a escolha de deixar a relação escopada ao dashboard, em vez de criar automaticamente um objeto compartilhável, parece deliberada: evita que alguém monte uma dependência cross-dashboard escondida, sem governança, só clicando numa tela. Quem quer reuso de verdade sabe exatamente onde precisa ir (metric view do Unity Catalog) em vez de descobrir isso tarde, quando outro dashboard já depende silenciosamente de uma relação que só existia num lugar.

**Fonte:** https://docs.databricks.com/aws/en/dashboards/manage/data-modeling/dashboard-relationships/

#AzureDatabricks #AIBI #Dashboards
