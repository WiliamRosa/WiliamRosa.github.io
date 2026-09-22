---
title: "Ambientes gerenciados por YAML chegam ao compute clássico do Azure Databricks"
date: 2026-09-18T09:00:00-03:00
draft: false
tags: ["Databricks", "Compute", "Azure Databricks"]
summary: "Base environments, o mecanismo de dependência declarada em YAML que já existia pro compute serverless, agora também funciona (em Beta) no compute clássico, unificando como o workspace gerencia biblioteca Python."
ShowToc: false
---

Gerenciar biblioteca Python parava de ser um problema resolvido assim que você saía do compute serverless.

O Azure Databricks estendeu, em Beta, o suporte a base environments para compute clássico. Até aqui, esse mecanismo de ambiente gerenciado por arquivo YAML só existia pro compute serverless; quem rodava cluster clássico continuava preso a instalar biblioteca manualmente, via init script ou reconstruindo imagem, cada abordagem com seu próprio jeito de divergir do que o time do lado estava usando.

O mecanismo em si não muda: um base environment define dependência Python de forma declarativa, seja um ambiente pronto oferecido pela própria Databricks, seja um ambiente customizado definido no nível do workspace. A novidade é que agora dá pra apontar esse mesmo ambiente pro compute clássico e pro compute padrão, selecionando o modo de dependência na definição do compute, em vez de esse fluxo ficar restrito a notebook e job serverless.

Pontos técnicos que valem atenção:
- Cobre tanto ambiente pronto oferecido pela Databricks quanto ambiente customizado definido no nível do workspace
- Configurado via dependency mode nas definições de compute, reaproveitando o mesmo fluxo que já existia pro serverless
- Reduz a divergência de "funciona no meu cluster, não funciona no seu" entre times que misturam serverless e clássico no mesmo workspace
- Ainda em Beta, então limitação de compatibilidade com biblioteca específica ou imagem customizada mais elaborada é esperada por enquanto

**Minha ressalva:** unificar o modelo de dependência entre serverless e clássico é o tipo de coisa que devia ter vindo junto desde o lançamento do serverless, não quase um ano depois. Vale testar antes de migrar pipeline de produção pra esse modo, principalmente se o cluster clássico já depende de init script customizado que essa abordagem declarativa ainda não cobre.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/compute/environments-mode

#Databricks #AzureDatabricks #DataEngineering
