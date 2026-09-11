---
title: "Governança consistente entre motor e catálogo diferente: o Open Lakehouse propõe dois padrões novos"
date: 2026-09-11T09:15:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Apache Iceberg", "Governança"]
summary: "A comunidade Apache Iceberg adotou read restrictions e catalog labels, duas especificações que a Databricks detalhou pra resolver o mesmo problema por ângulos diferentes: como manter política de acesso consistente quando motor de consulta e catálogo de dado não são os mesmos."
ShowToc: false
---

Ter Unity Catalog governando o dado e outro motor de consulta acessando esse mesmo dado direto costuma abrir uma brecha: quem garante que a política de acesso vale igual dos dois lados?

A Databricks publicou um detalhamento de duas especificações que a comunidade Apache Iceberg adotou recentemente pra atacar esse problema de ângulos diferentes. Read restrictions padroniza como um motor de consulta confiável aplica controle de acesso delegado pelo catálogo de origem: o catálogo avalia a política pro usuário que está pedindo o dado e devolve instrução de filtragem, usando um vocabulário fechado de ações de projeção de coluna e expressão de filtro de linha, e o motor de destino aplica essas restrições na hora de acessar o dado. Catalog labels resolve outro cenário, o de catálogos federados heterogêneos: em vez de repetir checagem de permissão a cada consulta, o catálogo de origem anexa metadado de governança (rótulo chave-valor) direto na tabela ou coluna, e cada catálogo consumidor mapeia esse rótulo pro seu próprio sistema de governança nativo, aplicando a política localmente.

O post organiza isso em três modelos, dependendo de quem está do outro lado: enforcement centralizado via serviço de filtragem seguro pra motor não confiável, read restrictions pra motor confiável com acesso direto, e catalog labels pra federação entre sistemas de governança autônomos e heterogêneos. Cada modelo troca expressividade de política, trilha de auditoria, performance e escala de um jeito diferente, então a escolha depende de quanto se confia no motor do outro lado e de quanto overhead de checagem repetida a arquitetura consegue absorver.

Pontos técnicos que valem atenção:
- Read restrictions: catálogo de origem avalia a política e devolve instrução de filtragem num vocabulário padronizado
- Catalog labels: metadado de governança anexado em tabela ou coluna, mapeado localmente por cada catálogo consumidor
- Três modelos de enforcement dependendo do nível de confiança no motor de destino
- Ambas as especificações vieram de adoção recente pela comunidade Apache Iceberg, não são exclusivas do Databricks

**Minha ressalva:** padronização entre projetos open source é sempre mais lenta que a evolução de um produto fechado, então vale acompanhar de perto quantos motores e catálogos de fato implementam essas duas especificações na prática antes de desenhar arquitetura de governança federada em cima delas. Especificação adotada no papel e especificação implementada de verdade em produção nem sempre andam no mesmo ritmo.

**Fonte:** https://www.databricks.com/blog/unifying-governance-across-engines-and-catalogs-open-lakehouse

#Databricks #UnityCatalog #ApacheIceberg
