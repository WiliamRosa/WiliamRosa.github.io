---
title: "Mover tabela entre catálogos sem copiar dado: a Databricks contribuiu UNREGISTER pro padrão aberto do Iceberg"
date: 2026-10-20T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Apache Iceberg", "Governança"]
summary: "REGISTER e UNREGISTER, em Private Preview, deixam uma tabela sair de um catálogo e entrar em outro reaproveitando só a localização do metadado, sem mover arquivo nenhum, baseado na especificação REST do Apache Iceberg à qual a própria Databricks contribuiu o UNREGISTER."
ShowToc: false
---

A Databricks publicou um raciocínio direto sobre o que realmente torna um catálogo "aberto": não é o formato de arquivo em si, é quem controla o dado e se dá pra tirar ele de lá sem reescrever tudo.

O par de operação que sustenta esse argumento é REGISTER e UNREGISTER, baseado na especificação REST do Apache Iceberg. UNREGISTER remove uma tabela do Unity Catalog e devolve a localização atual do metadado dela; REGISTER pega essa localização e anexa a tabela a um catálogo novo. O arquivo de dado em si nunca se move, só a referência de metadado muda de dono. A Databricks contribuiu o UNREGISTER de volta pra especificação aberta, não é um mecanismo proprietário escondido atrás de API fechada.

Pontos técnicos do anúncio:

- Cerca de 99% das managed tables do Unity Catalog já vivem em storage de propriedade do próprio cliente, "managed" aqui descreve quem cuida do ciclo de vida da tabela, não quem é dono do arquivo
- Tabela Iceberg externa (foreign table) é somente leitura no Databricks hoje, mas pode ser convertida via REGISTER ou SET MANAGED
- Recuperação de dado derrubado e Predictive Optimization (remoção de arquivo não referenciado) continuam funcionando normalmente em tabela Delta e Iceberg gerenciada
- Já está no roadmap (ainda não lançado) um comando SET MANAGED IN PLACE, pra converter tabela externa ou foreign em managed sem precisar passar pelo passo de REGISTER

**Minhas considerações:** o detalhe que mais chama atenção aqui não é a feature em si, é a Databricks contribuir a operação de saída (UNREGISTER) de volta pra especificação aberta do Iceberg, em vez de manter isso como vantagem competitiva fechada. Isso muda o cálculo de risco de lock-in de catálogo pra quem está decidindo onde hospedar dado em formato aberto hoje. Vale lembrar que o recurso ainda está em Private Preview, só acessível via time de conta, então não é algo pra planejar migração em cima ainda, é sinal de direção, não funcionalidade pronta pra produção.

**Fonte:** https://www.databricks.com/blog/what-makes-catalog-open-unity-catalog-advances-open-lakehouse

#Databricks #UnityCatalog #ApacheIceberg
