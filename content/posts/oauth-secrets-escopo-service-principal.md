---
title: "Segredo OAuth vazado agora pode ter dano limitado por escopo de API"
date: 2026-08-30T09:00:00-03:00
draft: false
tags: ["Databricks", "Segurança", "Opinião"]
summary: "Agora dá pra restringir o segredo OAuth de um service principal a escopos de API específicos, como sql ou jobs, em vez de liberar acesso total. Um token gerado por segredo restrito não consegue ultrapassar esses escopos."
ShowToc: false
---

A Databricks passou a permitir restringir o segredo OAuth de um service principal a escopos de API específicos, em vez de deixar cada segredo valer para qualquer API da conta.

O problema que isso resolve é conhecido de quem já lidou com incidente de segredo vazado: historicamente, um segredo OAuth de service principal dava acesso a tudo que aquela identidade tinha permissão de fazer, API de SQL, de jobs, de cluster, todas juntas atrás do mesmo segredo. Agora é possível emitir um segredo já limitado a um escopo, como sql ou jobs, e qualquer token gerado a partir desse segredo carrega essa mesma limitação, não importa o que o service principal tenha de permissão em outros lugares. Na prática, isso separa "o que o service principal pode fazer" de "o que esse segredo específico pode fazer", e são duas coisas diferentes agora.

Onde isso muda o cálculo de risco:
- Um segredo vazado com escopo sql não vira porta de entrada pra disparar job ou mexer em cluster, mesmo que o service principal tenha essas permissões
- Isso incentiva o padrão de emitir um segredo por integração, com escopo mínimo necessário pra aquela integração específica, em vez de um segredo genérico reaproveitado em vários lugares
- Reduz o raio de explosão de um pipeline de CI/CD comprometido, que normalmente usa um único segredo pra tudo que precisa automatizar

**Minhas considerações:** essa é o tipo de feature de segurança que só entrega valor se alguém de fato for revisar os segredos já existentes e recriá-los com escopo restrito, porque segredo antigo continua com acesso total até ser trocado. Recomendo tratar isso como gatilho pra um inventário de segredos de service principal ativos hoje, não só como opção disponível pra segredo novo daqui pra frente.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/dev-tools/auth/oauth-m2m

#Databricks #Segurança
