---
title: "FILE vira tipo de coluna nativo, e arquivo passa a ter dono e permissão como qualquer tabela"
date: 2026-08-11T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Dados Não Estruturados", "Opinião"]
summary: "A Databricks lançou o tipo FILE em beta: documento, imagem, áudio e vídeo agora podem virar coluna nativa de tabela, com a mesma governança de linha, coluna e ABAC do Unity Catalog aplicada também ao arquivo."
ShowToc: false
---

Documento, imagem, áudio e vídeo agora podem virar coluna de tabela no Databricks, não só referência solta num storage.

A Databricks lançou o tipo FILE, um tipo de coluna nativo, ainda em beta, pensado para dado não estruturado dentro de tabela Delta ou Iceberg. Em vez de guardar o binário inteiro dentro da tabela, a coluna guarda uma referência leve para o arquivo, e o conteúdo só é carregado quando uma consulta realmente precisa dele.

O motivo de existir é mais sobre governança do que sobre armazenamento. Hoje, quem guarda caminho de arquivo como string de URL depende de permissão de pasta, que vive fora do controle de acesso da tabela, então documento e imagem acabam com um modelo de permissão paralelo ao dos dados estruturados. Com FILE, a mesma política de linha, coluna e ABAC do Unity Catalog passa a valer também para o arquivo, incluindo a exclusão em cascata: apagar a linha apaga o binário correspondente no storage, o que ajuda bastante quem lida com pedido de exclusão sob LGPD ou GDPR.

Pontos técnicos que valem registrar:
- Beta, integra com Spark, Delta Lake e Apache Iceberg
- Controle de acesso a nível de linha, coluna e ABAC via Unity Catalog, aplicado também ao arquivo
- Deletar a linha remove o binário do storage automaticamente, sem processo separado de limpeza
- Funciona em SQL e em UDF Python, incluindo função de IA nativa como AI_PARSE_DOCUMENT
- Conectores prontos para SharePoint, Google Drive e storage em nuvem, com opção de referenciar arquivo sem mover ele

**Minha ressalva:** unificar governança de dado estruturado e não estruturado numa mesma política é o tipo de promessa que só se prova em produção. Column-level ABAC pensado pra número e string é uma coisa, aplicar a mesma lógica a vídeo de gigabytes é outra, com implicação de custo e latência que o anúncio não detalha. Vale testar o comportamento de exclusão em cascata com cuidado antes de confiar nele como mecanismo único de conformidade.

**Fonte:** https://www.databricks.com/blog/introducing-file-type-native-column-type-multimodal-data

#Databricks #UnityCatalog #DadosNaoEstruturados
