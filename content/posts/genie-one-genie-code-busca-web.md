---
title: "Genie parou de responder com informação desatualizada, agora ele pode simplesmente buscar na web"
date: 2026-09-10T14:00:00-03:00
draft: true
tags: ["Databricks", "Genie", "IA"]
summary: "Genie One (em beta) e Genie Code passaram a ter acesso à web pública pra responder pergunta que depende de informação atual, como release note recente ou notícia, citando a fonte externa usada na resposta."
ShowToc: false
---

Perguntar pro Genie sobre algo que aconteceu essa semana deixou de ser um beco sem saída.

A Databricks liberou acesso à web pública para Genie One e Genie Code responderem pergunta que depende de informação atual, como release note recente, documentação de terceiro ou notícia fora do que já está indexado no Lakehouse. Genie One recebeu esse acesso agora, em beta; Genie Code já contava com ele há mais tempo, algo que MVPs da comunidade vinham sentindo falta especialmente pra pergunta sobre pacote de terceiro atualizado, informação que qualquer agente de código já assume como disponível hoje em dia.

Pontos técnicos que valem atenção:
- Genie One: acesso à web pública em Beta
- Genie Code: acesso à web já disponível há mais tempo, antes do Genie One
- A resposta cita as fontes externas usadas, como link, dentro do próprio retorno
- Cobre caso como release note recente, documentação de terceiro e notícia que não está no dado governado do Lakehouse

**Minhas considerações:** dar acesso à web pro Genie resolve um problema real de defasagem, mas também levanta a pergunta óbvia de governança: que critério decide o que é fonte confiável o suficiente pra citar numa resposta corporativa, e como isso interage com o restante da política de segurança do Unity Catalog e do Unity Gateway já aplicada ao resto do ambiente agêntico. Vale acompanhar como esse controle evolui antes de assumir que "beta" aqui significa "pronto pra ambiente com dado sensível".

**Fonte:** https://docs.databricks.com/aws/en/genie-one/chat#web-search

#Databricks #Genie #IA
