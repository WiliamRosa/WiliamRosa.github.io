---
title: "Replit ganhou suporte nativo a Lakebase pra criar app full-stack com dado corporativo"
date: 2026-09-12T09:00:00-03:00
draft: false
tags: ["Databricks", "Lakebase", "Databricks Apps", "Integrações"]
summary: "A integração entre Replit e Databricks virou geral e passou a incluir suporte nativo ao Lakebase, com o Replit Agent provisionando banco automaticamente no deploy e mudança de schema proposta por IA exigindo aprovação humana antes de ir pra produção."
ShowToc: false
---

Provisionar banco de dados deixou de ser passo manual num fluxo que já era pensado pra ser rápido.

A Databricks tornou geral a integração com o Replit, agora com suporte nativo ao Lakebase: dá pra construir aplicação full-stack completa usando o Replit Agent enquanto o dado corporativo fica hospedado e governado no Azure Databricks. A proposta é dividir responsabilidades: Replit acelera a criação da aplicação, Databricks garante acesso governado e seguro ao dado ao vivo.

Na prática, o Replit Agent provisiona o banco Lakebase automaticamente no momento do deploy, sem configuração manual, e cria um ambiente de preview separado pra isolar dado de teste do dado real de produção. Quando uma mudança de schema é proposta pela IA, ela passa por um fluxo chamado Supervised AI Migration Flow, que exige aprovação da equipe antes de qualquer coisa chegar em produção, com Unity Catalog cuidando de permissão, linhagem e log de auditoria por trás disso.

Pontos técnicos que valem atenção:
- Provisionamento automático de banco Lakebase acontece no deploy, sem passo manual de configuração
- Ambiente de preview isolado separa dado de teste do dado de produção real
- Mudança de schema sugerida por IA passa pelo Supervised AI Migration Flow, com aprovação humana obrigatória antes do deploy
- Unity Catalog aplica permissão, linhagem e auditoria sobre o acesso ao dado, mesmo vindo de fora do Databricks
- Casos de uso citados incluem dashboard interativo, ferramenta interna customizada e acesso a dado governado por departamento com controle baseado em papel

**Minha ressalva:** automatizar a criação de banco a partir de um agente de IA é conveniente, mas o ponto que realmente importa aqui é quem participa da aprovação das migrações de schema. Vale conferir com atenção como esse fluxo "supervisionado" funciona na prática antes de confiar cegamente no rótulo, porque uma aprovação virada rotina sem revisão real anula boa parte da proteção que o desenho promete.

**Fonte:** https://replit.com/blog/databricks2026

#Databricks #Lakebase #DatabricksApps
