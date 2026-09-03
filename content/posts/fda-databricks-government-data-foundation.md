---
title: "Como a FDA constrói governança de dado sobre Databricks for Government"
date: 2026-09-02T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Governança", "Setor Público"]
summary: "A FDA construiu o HALO, plataforma sobre Databricks em AWS GovCloud, pra resolver silo de dado entre centros regulatórios distintos, usando Unity Catalog como camada de governança única e um modelo de isolamento por área que a Databricks chama de 'apartment complex'."
ShowToc: false
---

Órgão regulador americano também sofre do mesmo problema clássico de dado espalhado em silo, só que com a complicação extra de exigência de segurança de governo.

A Databricks detalhou como a FDA (Food and Drug Administration) modernizou a própria infraestrutura de dado construindo o HALO (Harmonized AI and Lifecycle Operations for Data), rodando sobre Databricks em AWS GovCloud. O objetivo declarado é permitir capacidade de IA segura e governada pra trabalho regulatório, sem repetir o problema de cada centro da agência manter seu próprio pedaço isolado de dado.

A peça central é o Unity Catalog funcionando como camada única de governança pra descobrir e gerenciar ativo confiável entre região e formato diferente. O modelo de isolamento usado é descrito como "apartment complex": cada centro regulatório compartilha a mesma infraestrutura de base, mas mantém espaço isolado e governado por política própria, parecido com prédio de apartamento onde a estrutura é comum mas cada unidade tem sua própria porta trancada.

Pontos técnicos que valem atenção:
- Unity Catalog como camada única de governança de dado e IA entre região e formato
- Modelo "apartment complex": infraestrutura compartilhada entre centro regulatório, mas isolamento e política por unidade
- PrivateLink, chave de criptografia gerenciada pelo cliente e perfil de segurança de compliance provisionados via Terraform
- Compute serverless e model serving usados na camada de execução
- 30% de ganho de performance em consulta SQL reportado após a otimização

**Minhas considerações:** o modelo "apartment complex" é basicamente multi-tenant com governança fina de sempre, o que muda aqui é o contexto, é órgão de governo tratando isolamento entre departamento regulatório com o mesmo rigor que uma empresa trataria isolamento entre cliente pagante. Vale de referência pra qualquer organização grande e descentralizada que precisa de dado compartilhado sem abrir mão de fronteira de acesso entre área.

**Fonte:** https://www.databricks.com/blog/how-fda-building-secure-ai-ready-data-foundation-databricks-government

#Databricks #UnityCatalog #Governanca
