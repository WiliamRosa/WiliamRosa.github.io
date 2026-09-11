---
title: "O que realmente separa uma managed table de uma external table no Unity Catalog"
date: 2026-09-11T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Data Engineering", "Azure Databricks"]
summary: "Um artigo do Youssef Mrini, destacado pelo Databricks MVP Jacek Laskowski, revisita um ponto que ainda confunde muita gente: managed table não é só 'tabela sem LOCATION', é a Databricks assumindo o ciclo de vida inteiro do dado."
ShowToc: false
---

Achar que managed table é só uma external table sem o LOCATION explícito é o tipo de simplificação que engana o time inteiro na hora de planejar retenção de dado.

O Databricks MVP Jacek Laskowski destacou um artigo de Youssef Mrini que volta ao básico do Unity Catalog pra explicar essa diferença direito. Numa external table, quem decide onde o dado físico mora é quem criou a tabela, apontando pra um caminho de storage já existente, e dropar a tabela remove só o registro de metadado, o arquivo continua lá. Numa managed table, o Unity Catalog escolhe e controla o caminho de armazenamento dentro da managed storage location do catálogo ou schema, e dropar a tabela remove também o dado físico.

Essa diferença de propriedade sobre o ciclo de vida é o que abre espaço pra Databricks aplicar otimização automática só em managed table, como predictive optimization, compactação e vacuum sem o time precisar agendar job manual pra isso. External table continua útil quando o dado já existe em algum lugar específico, por exigência de compliance ou porque outro sistema também lê o mesmo arquivo, mas aí o time abre mão de parte dessa automação em troca de controle total sobre onde o byte fica.

Pontos técnicos que valem revisar:
- Managed table: Databricks controla local de armazenamento e ciclo de vida completo do arquivo
- External table: local de armazenamento é definido explicitamente via LOCATION, arquivo sobrevive ao DROP TABLE
- Só managed table recebe otimização automática de storage por padrão
- Governança de acesso via Unity Catalog vale igual pros dois tipos
- Escolha errada nesse ponto costuma aparecer como surpresa só na hora de migrar ou de fazer disaster recovery

**Minhas considerações:** é um daqueles conceitos que parece óbvio quando já se trabalha com Unity Catalog há um tempo, mas que continua gerando escolha errada em projeto novo, geralmente porque alguém copia um exemplo de tutorial sem entender a implicação de longo prazo. Vale revisitar esse artigo com quem está desenhando arquitetura de dado agora, antes da decisão virar dívida técnica.

**Fonte:** https://community.databricks.com/t5/technical-blog/actually-understanding-unity-catalog-managed-tables/ba-p/168194

#Databricks #UnityCatalog #DataEngineering
