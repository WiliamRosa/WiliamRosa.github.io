---
title: "Databricks e SAP prometem acesso zero-copy ao dado de aplicação, mas boa parte ainda é promessa"
date: 2026-10-31T09:00:00-03:00
draft: false
tags: ["Databricks", "Integracoes", "Azure Databricks"]
summary: "Databricks e SAP ampliaram a parceria em torno do SAP Application Data Foundation, trazendo Genie, Lakeflow, Unity Gateway e Lakebase pro ambiente SAP Databricks, com acesso zero-copy ao dado de aplicação SAP via SAP Business Data Cloud Connect como único mecanismo técnico detalhado."
ShowToc: false
---

Databricks e SAP prometem acesso zero-copy ao dado de aplicação SAP, mas a letra fina ainda está em construção.

A Databricks e a SAP ampliaram a parceria em torno do SAP Application Data Foundation, trazendo Genie, Lakeflow, Unity Gateway e Lakebase pra dentro do ambiente SAP Databricks, com a promessa central de acesso zero-copy ao dado de aplicação SAP através do SAP Business Data Cloud Connect.

O mecanismo técnico concreto aqui é esse zero-copy via SAP BDC Connect: em vez de extrair dado de sistema SAP pra uma cópia separada antes de qualquer análise, caminho que historicamente exigia pipeline de extração customizado e gerava silo, o dado de aplicação SAP passa a ficar disponível direto pros motores do SAP Business Data Cloud, incluindo o Databricks hospedado dentro do SAP. O restante do anúncio, integração bidirecional entre Genie e o assistente Joule da SAP, uso de Lakeflow pra combinar dado SAP com IoT, CRM e fonte de terceiro, governança via Unity Gateway, ainda aparece descrito em nível de produto, sem detalhe de arquitetura, e parte dessas capacidades é citada como planejada, não disponível hoje.

Pontos técnicos que valem atenção:
- SAP Application Data Foundation disponibiliza dado de aplicação SAP pros motores do SAP Business Data Cloud via SAP BDC Connect, sem pipeline de extração customizado
- OpenSharing bidirecional entre Databricks e SAP é mencionado, mas sem detalhe de arquitetura publicado
- Integração planejada entre Genie e o Joule da SAP ainda não está disponível, segundo o próprio anúncio
- Único resultado quantificado do anúncio é o case da SAF-Holland, reportando análise cinco vezes mais rápida

**Minha ressalva:** é um anúncio de parceria com mecanismo real só na parte de zero-copy, o resto fica em nível de intenção de produto. Vale esperar documentação técnica detalhada antes de desenhar arquitetura em torno de capacidade que o próprio anúncio chama de futura.

**Fonte:** https://www.databricks.com/blog/databricks-and-sap-unleash-end-end-data-ai-capabilities-level-enterprise-ai-transformation

#Databricks #Integracoes #AzureDatabricks
