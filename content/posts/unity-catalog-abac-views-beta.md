---
title: "Row filter e column mask do Unity Catalog agora valem pra view também, não só pra tabela"
date: 2026-09-16T07:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "ABAC", "Governança", "Azure Databricks"]
summary: "ABAC em view chegou em beta no Unity Catalog: as mesmas políticas de row filter e column mask baseadas em atributo que já valiam pra tabela agora se aplicam também a dado sensível exposto através de view."
ShowToc: false
---

Até aqui, uma política ABAC bem desenhada em cima da tabela podia virar letra morta assim que alguém criava uma view em cima dela.

O Azure Databricks estendeu o controle de acesso baseado em atributo do Unity Catalog pra alcançar também views, não só tabelas. Row filter e column mask definidos via política ABAC agora se aplicam a dado sensível mesmo quando ele chega ao usuário final através de uma view, fechando uma lacuna comum em ambientes onde view é a interface principal de consumo pra time de analytics e BI.

O recurso está em beta e exige habilitar o preview "ABAC on Views" no console da conta, além de rodar em Databricks Runtime 19 ou superior.

Pontos técnicos:
- Row filter e column mask de política ABAC agora cobrem view, além de tabela
- Habilitação é feita pelo administrador da conta, na página de Previews do console
- Exige Databricks Runtime 19 ou versão superior
- Continua fazendo parte do mesmo modelo ABAC já usado pra tabela, sem sintaxe de política separada

**Minhas considerações:** faz sentido que isso viesse depois do ABAC pra tabela, mas o atraso é justamente o tipo de lacuna que costuma ser explorada sem querer, alguém cria uma view de conveniência achando que herda a proteção da tabela de origem e descobre que não herdava. Vale a pena revisar views existentes que expõem coluna sensível assim que esse recurso sair do beta, em vez de assumir que a política antiga já cobria esse caso.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/abac/

#Databricks #UnityCatalog #Governanca
