---
title: "Migrar dashboard do Tableau ou Power BI pro Databricks virou upload de arquivo"
date: 2026-08-26T09:00:00-03:00
draft: false
tags: ["Databricks", "GenieCode", "AIBI", "Opinião"]
summary: "Genie Code agora aceita arquivo .twb, .twbx, .tds, .tdsx ou .pbit e gera automaticamente um dashboard AI/BI equivalente, com Metric Views replicando a lógica de negócio original."
ShowToc: false
---

Migrar dashboard legado sem reconstruir do zero deixou de ser promessa e virou funcionalidade.

O Databricks MVP Soufiane Darraz destacou a novidade assim que ela chegou: agora dá pra fazer upload direto de arquivo do Tableau (.twb, .twbx) ou do Power BI (.tds, .tdsx, .pbit) no Genie Code e deixar a IA gerar um dashboard AI/BI que replica as visualizações originais, sem reescrever cada gráfico manualmente.

O mecanismo funciona em duas camadas. Primeiro, o Genie Code interpreta a estrutura do arquivo importado (fonte de dado, campo calculado, tipo de visualização) e monta o dashboard equivalente. Segundo, e essa é a parte que importa pra quem se preocupa com governança: a lógica de negócio por trás dos gráficos vira Metric View, promovida ao Unity Catalog, onde passa a ter linhagem, controle de acesso e fica disponível pra reuso em outros dashboards, não só isolada dentro daquele relatório importado.

Detalhes técnicos que valem registrar:
- Formatos suportados: .twb e .twbx do Tableau, .tds e .tdsx (fontes de dado do Tableau), .pbit do Power BI
- Arquivos de referência ficam armazenados em volumes do Unity Catalog
- Metric Views geradas automaticamente podem ser promovidas ao Unity Catalog pra governança, linhagem e reuso

**Minha ressalva:** replicar visualização automaticamente é diferente de replicar a intenção de negócio por trás dela. Um campo calculado complexo do Tableau, cheio de lógica condicional acumulada ao longo de anos, é exatamente o tipo de coisa que uma tradução automática tende a simplificar demais ou errar sutilmente. Eu revisaria cada Metric View gerada linha por linha antes de promover pro Unity Catalog, principalmente se o dashboard original alimenta decisão financeira ou regulatória.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/dashboards/manage/import-bi

#Databricks #GenieCode #AIBI
