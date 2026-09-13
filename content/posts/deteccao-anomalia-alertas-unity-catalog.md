---
title: "Unity Catalog agora manda alerta por e-mail quando anomaly detection acha tabela doente"
date: 2026-09-13T13:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Data Quality", "Opinião"]
summary: "Alertas de anomaly detection, em Beta na Data Quality Monitoring UI, notificam por e-mail usuário do workspace quando uma tabela monitorada fica insalubre dentro do escopo de catálogo ou schema configurado, sem exigir regra manual de qualidade escrita à mão."
ShowToc: false
---

O Databricks MVP Ajay Kumar Pandey destacou uma peça de governança que fecha um buraco comum em monitoramento de qualidade de dado: alguém só descobre que uma tabela quebrou quando um dashboard já está errado há dias.

Os alertas de anomaly detection, agora em Beta dentro da Data Quality Monitoring UI, eliminam a necessidade de escrever regra manual de frescor ou completude tabela por tabela. Em vez disso, o sistema aprende o padrão histórico de cada tabela monitorada e dispara notificação por e-mail assim que detecta um problema, como uma tabela parada há tempo demais ou uma queda inesperada na contagem de linha, dentro do escopo de catálogo ou schema em que a regra de alerta foi configurada.

A configuração acontece direto no Catalog Explorer: dentro de um schema com monitoramento de qualidade já habilitado, a aba Details leva pra Data Quality Monitoring UI, onde o botão Manage alerts abre um painel pra criar, editar ou excluir regra de alerta, escolhendo catálogo, schema (ou todos os schemas do catálogo) e a lista de usuários a notificar.

Pontos técnicos:

- Regra de alerta escopada por catálogo inteiro ou schema específico
- Cada destinatário recebe um e-mail por tabela insalubre importante detectada dentro do escopo da regra
- Criar alerta em nível de schema exige privilégio `MANAGE` no schema; em nível de catálogo, exige `MANAGE` no catálogo
- Gerenciamento (criar, editar, excluir) feito direto no painel Manage alerts da Data Quality Monitoring UI
- Recurso está em Beta e já vem habilitado por padrão pra todo usuário, sem precisar ativação na página Previews

**Minhas considerações:** automatizar a detecção de tabela insalubre é bem-vindo, mas o alerta por si só não substitui decidir o que fazer depois que ele chega. Vale já desenhar de antemão quem recebe cada regra e qual runbook aciona quando o e-mail cai, porque alerta que ninguém tem responsabilidade clara de tratar vira ruído rapidamente, principalmente em catálogo grande com muito schema monitorado ao mesmo tempo.

Fonte: https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/data-quality-monitoring/anomaly-detection/alerts

#Databricks #UnityCatalog #AzureDatabricks
