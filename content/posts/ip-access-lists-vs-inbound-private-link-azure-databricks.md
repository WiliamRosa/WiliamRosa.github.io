---
title: "Lista de IP e Private Link não precisam ser escolhas excludentes no Azure Databricks"
date: 2026-10-27T13:00:00-03:00
draft: true
tags: ["Azure Databricks", "Seguranca", "Rede"]
summary: "O Databricks MVP Shashank Shekhar documentou a migração de uma lista de IP liberado pra um modelo híbrido com Inbound Private Link no Azure Databricks, combinando conectividade privada com acesso público controlado por política de ingress baseada em contexto."
ShowToc: false
---

Restringir acesso ao workspace por IP e usar Private Link não precisam ser escolhas excludentes.

O Databricks MVP Shashank Shekhar documentou como migrar de uma lista de IP liberado pra um modelo híbrido com Inbound Private Link no Azure Databricks, mostrando o caminho pra sair de uma coisa pra outra sem quebrar acesso de quem já está liberado.

O modelo híbrido mantém o Private Link ativo pra conexão privada, mas deixa o acesso público ligado, controlado por política de ingress baseada em contexto e por lista de IP. Isso difere do modelo de acesso totalmente privado, que exige que todo tráfego de usuário venha de uma VNet conectada via endpoint privado, incluindo o plano de compute clássico via Private Link. O caminho híbrido serve justamente quem só usa compute serverless ou interage via UI e API, sem precisar ainda de conectividade privada bidirecional completa.

Pontos técnicos que valem atenção:
- Arquitetura recomendada usa uma VNet de trânsito central, hub-and-spoke, hospedando os private endpoints de acesso ao workspace e de autenticação de browser
- Workspace precisa estar no plano Premium e usar VNet injection
- Política de ingress baseada em contexto permite restringir por identidade, tipo de requisição e origem de rede, combinando com lista de IP estático de escritório
- Recomenda-se testar a política em modo dry run antes de aplicar em modo enforced, já que negação em dry run só é registrada em log, não bloqueia acesso

**Minha ressalva:** migrar pra esse modelo híbrido ainda exige parar todo compute em execução durante a mudança de configuração de rede, o que implica negociar uma janela de manutenção; não é uma troca que se faz em produção sem planejamento prévio de downtime.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/security/network/front-end/front-end-private-connect

#AzureDatabricks #Seguranca #Rede
