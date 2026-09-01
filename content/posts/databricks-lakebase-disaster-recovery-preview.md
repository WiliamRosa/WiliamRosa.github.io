---
title: "Lakebase ganha disaster recovery entre regiões, mas ainda deixa Delta table de fora"
date: 2026-08-29T09:00:00-03:00
draft: true
tags: ["Databricks", "Lakebase", "DisasterRecovery", "Opinião"]
summary: "Lakebase Disaster Recovery replica metadado do Unity Catalog, dado de tabela gerenciada e ativos de workspace pra uma região secundária, mas Delta table e pipelines de sincronização ficam fora da replicação por enquanto."
ShowToc: false
---

Falha de região inteira é um cenário diferente de falha de zona de disponibilidade, e até agora o Lakebase não tinha resposta pra isso.

O Databricks MVP Mani Kandasamy apontou o Lakebase Disaster Recovery como um dos lançamentos que mais valeu acompanhar depois do Data + AI Summit, junto com Genie Ontology e Lakehouse//RT. A funcionalidade replica os dados do seu projeto pra um workspace secundário numa região diferente, protegendo contra falha completa de região (incluindo apagão), não só falha de máquina isolada ou de zona de disponibilidade.

O mecanismo replica metadado do Unity Catalog, dado de tabela gerenciada e ativos de workspace de forma contínua, mantém uma URL estável que sobrevive ao failover, e permite disparar o failover manualmente pelo console de conta. Durante o Private Preview, a disponibilidade é restrita a replicação entre regiões só na AWS, e a própria documentação é explícita: não é recomendado pra uso em produção enquanto estiver nessa fase.

Limitações que valem registrar antes de considerar adotar:
- Tabelas sincronizadas (synced tables) e pipelines de Lakebase CDF terminam no failover e não retomam automaticamente depois
- Dado Delta não é replicado, o disaster recovery do Lakebase não cobre Delta table
- Só cross-region na AWS durante o preview, sem confirmação ainda de quando chega no Azure

**Minha ressalva:** disaster recovery que não cobre Delta table nem retoma pipeline de sincronização sozinho ainda deixa um bocado de trabalho manual pro time de operação no momento em que mais precisa de automação, que é logo depois de uma região inteira cair. Vale acompanhar como isso evolui até a disponibilidade geral, mas por enquanto eu trataria como proteção parcial, não como plano de disaster recovery completo pronto pra depender dele sozinho.

**Fonte:** https://docs.databricks.com/aws/en/oltp/projects/disaster-recovery

#Databricks #Lakebase #DisasterRecovery
