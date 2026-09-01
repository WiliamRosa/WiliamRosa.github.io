---
title: "Agora dá pra escrever no Unity Catalog direto do Excel"
date: 2026-06-05T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Excel", "Unity Catalog", "Opinião"]
summary: "O Add-in do Excel para Azure Databricks deixou de ser só leitura — agora escreve de volta em uma tabela do Unity Catalog, sem sair da planilha."
ShowToc: false
---

🚀 O Add-in do Azure Databricks para Excel ganhou uma capacidade que muda o público-alvo da ferramenta: escrever dados de volta numa tabela do Unity Catalog, criando ou sobrescrevendo, sem sair da planilha.

Até aqui, integração Excel-Databricks era estritamente de leitura — bom pra quem só precisa consumir uma metric view. Write-back muda o jogo: o Excel vira também um ponto de entrada de dados governado, e não só de consulta.

Por que isso importa na prática:
- Área de negócio que só sabe trabalhar em Excel ganha um caminho oficial pra alimentar o Lakehouse
- Elimina a etapa manual de "exportar Excel → subir CSV → rodar pipeline"
- Ainda passa pelo Unity Catalog, então a governança da tabela de destino continua valendo

❗ Minha ressalva: write-back direto de Excel é exatamente o tipo de porta de entrada que precisa de controle de qualidade rígido — schema errado, tipo de dado inconsistente, duplicata de linha. Antes de liberar isso pra usuário de negócio, eu garantiria validação na tabela de destino, porque Excel não vai fazer esse trabalho por você.

🔗 Fonte: https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/june

#AzureDatabricks #Excel #UnityCatalog
