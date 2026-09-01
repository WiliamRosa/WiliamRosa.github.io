---
title: "Ingestão sem CDC no Lakeflow Connect saiu do papel e virou GA"
date: 2026-05-30T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Lakeflow Connect", "Ingestão de Dados", "Opinião"]
summary: "Conectores baseados em query atingiram disponibilidade geral: ingestão incremental via cursor, sem CDC nem gateway, pra Oracle, SQL Server, MySQL, MariaDB, Teradata e PostgreSQL."
ShowToc: false
---

🚀 Os conectores baseados em query do Lakeflow Connect atingiram GA. A proposta: ingerir dado de banco relacional consultando a fonte diretamente por uma coluna cursor, sem precisar configurar CDC nem manter um gateway de ingestão.

Isso remove uma barreira de entrada que sempre existiu pra times que não podem ou não querem habilitar CDC no banco de origem — seja por restrição do DBA, seja pelo overhead operacional de manter mais uma peça de infraestrutura rodando.

O mecanismo, resumido:
- Você define a tabela e escolhe uma coluna cursor (timestamp ou ID)
- O Databricks rastreia a marca d'água e consulta só as linhas novas/alteradas a cada execução
- Funciona com Oracle, Teradata, SQL Server, MySQL, MariaDB, PostgreSQL, e qualquer fonte do Lakehouse Federation via ingestão por catálogo externo

❗ Minha ressalva: ingestão baseada em query só captura o que existe na tabela no momento da consulta — ela não vê delete físico nem update que aconteceu e foi revertido entre duas execuções, do jeito que um CDC de log de transação captura. Pra caso de uso que exige histórico completo de mudança (auditoria estrita, por exemplo), essa abordagem é mais simples de operar, mas não é substituta equivalente ao CDC tradicional — é uma troca consciente de completude por simplicidade operacional.

🔗 Fonte: https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/may

#AzureDatabricks #LakeflowConnect #EngenhariaDeDados
