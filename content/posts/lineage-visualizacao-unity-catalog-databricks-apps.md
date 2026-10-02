---
title: "A linhagem nativa do Unity Catalog não respondia perguntas de arquitetura, então um MVP construiu a própria"
date: 2026-10-02T08:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Databricks Apps", "Data Lineage"]
summary: "O Databricks MVP Maksim Pachkouski construiu uma visualização de linhagem aprimorada sobre Databricks Apps, cobrindo todo o catálogo como um único grafo navegável, com hierarquia completa, jobs, dependências e exportação para draw.io."
ShowToc: false
---

A linhagem nativa do Unity Catalog responde bem de onde uma tabela vem e para onde ela vai, mas some na hora de responder pergunta de arquitetura em nível de plataforma inteira.

O Databricks MVP Maksim Pachkouski identificou essa lacuna e construiu, sobre Databricks Apps, uma visualização de linhagem aprimorada que se parece com a versão nativa da Databricks, mas permite explorar o catálogo inteiro como um único grafo navegável, em vez de navegar tabela por tabela isoladamente. Ele testou alternativas existentes, incluindo o OpenMetadata, mas a integração com Databricks não entregou o resultado que ele precisava para seus próprios casos de uso, o que motivou construir a ferramenta própria.

A ferramenta não tenta reinventar o conceito de linhagem, ela resolve um problema específico de visualização em escala: hierarquia completa de catálogos, schemas e objetos num só grafo; tabelas junto com suas dependências; jobs e fluxos de dado representados na mesma visualização; capacidade de mover objetos livremente para reorganizar a leitura do grafo; funções para expandir e colapsar partes específicas, essenciais quando o catálogo é grande; e exportação do diagrama resultante direto para draw.io, útil para documentação e apresentação.

Pontos técnicos da ferramenta:

- Construída sobre Databricks Apps, sem infraestrutura externa adicional
- Visualiza hierarquia completa de catálogos, schemas e objetos como um único grafo
- Inclui tabelas com suas dependências e também jobs e fluxos de dado
- Permite mover objetos livremente e expandir ou colapsar partes específicas do grafo
- Exporta o diagrama resultante direto para draw.io

**Minha leitura:** o padrão aqui é recorrente entre MVPs do Databricks, uma lacuna real de plataforma que vira ferramenta construída em Databricks Apps, porque o custo de construir e manter algo assim dentro da própria plataforma caiu bastante. Vale acompanhar se ferramentas desse tipo, nascidas de necessidade pessoal de um MVP, acabam influenciando a própria linhagem nativa da Databricks com o tempo, como já aconteceu com outras features que começaram como workaround da comunidade.

**Fonte:** https://www.linkedin.com/in/protmaks/#lineage-visualizacao-unity-catalog-databricks-apps

#Databricks #UnityCatalog #DatabricksApps
