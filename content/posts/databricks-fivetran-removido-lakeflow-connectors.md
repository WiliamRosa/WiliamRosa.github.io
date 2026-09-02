---
title: "O Fivetran sumiu da seção de Ingestão do Databricks, e ninguém anunciou isso"
date: 2026-09-01T06:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow Connect", "Ingestão de Dados", "Opinião"]
summary: "O Databricks MVP Hubert Dudek percebeu que o Fivetran, presente há anos na seção de Ingestão, desapareceu silenciosamente, junto com a chegada de novos conectores nativos do Lakeflow."
ShowToc: false
---

O Databricks MVP Hubert Dudek notou algo que passou batido no changelog oficial: o Fivetran, que estava presente na seção de Ingestão do workspace há muitos anos, sumiu, na mesma época em que novos conectores nativos do Lakeflow foram adicionados.

Esse tipo de mudança silenciosa (sem anúncio formal, só percebida por quem usa a interface no dia a dia) diz bastante sobre a direção do produto: a Databricks vem investindo pesado em conectores nativos do Lakeflow Connect, SharePoint, Workday, conectores baseados em query sem CDC, e cada conector nativo novo é, indiretamente, um motivo a menos pra manter uma ferramenta de ingestão terceirizada em destaque na interface principal.

Por que isso importa mesmo sem confirmação oficial:
- Times que hoje dependem do Fivetran via essa integração devem verificar se o acesso ainda existe por outro caminho, ou se é hora de migrar pra um conector nativo do Lakeflow
- É um sinal (não prova definitiva) de prioridade de produto: nativo primeiro, parceiro depois
- Mudanças de interface sem changelog formal são exatamente o tipo de coisa que só aparece quando alguém da comunidade presta atenção, reforça o valor de acompanhar MVPs que usam a plataforma de verdade, não só ler nota de release

**Minha ressalva:** isso é uma observação de um usuário avançado, não uma confirmação oficial da Databricks sobre descontinuar a parceria com o Fivetran. Vale tratar como um sinal de atenção, não como decisão automática de migrar tudo pra conector nativo, até vir uma confirmação (ou desmentido) oficial.

**Fonte:** https://www.linkedin.com/posts/hubertdudek_i-went-to-the-ingestion-section-and-see-activity

#Databricks #LakeflowConnect #Ingestão
