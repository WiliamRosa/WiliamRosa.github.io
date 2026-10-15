---
title: "A Databricks CLI 1.20 não deprecia mais o Terraform em bundle, ela remove de vez"
date: 2026-10-14T19:00:00-03:00
draft: true
tags: ["Databricks", "Azure Databricks", "Databricks Asset Bundles", "Terraform", "DevOps"]
summary: "O Databricks MVP Daniel Sahal destacou que a Databricks CLI 1.20.0 removeu de vez o engine Terraform de Databricks Asset Bundles: setar bundle.engine: terraform ou a variável de ambiente equivalente agora retorna erro, e falha de migração de state também vira erro em vez de cair de volta pro Terraform."
ShowToc: false
---

Complementando o que já vimos aqui sobre o engine direct virar padrão em bundles, a Databricks deu o passo que faltava: não é mais deprecação, é remoção.

O Databricks MVP Daniel Sahal destacou o changelog da Databricks CLI 1.20.0, que elimina de vez o engine Terraform de dentro de Databricks Asset Bundles. Até a versão anterior, era possível forçar `bundle.engine: terraform` ou a variável `DATABRICKS_BUNDLE_ENGINE=terraform` pra manter o comportamento antigo; agora as duas opções simplesmente retornam erro. Quem ainda depende do Terraform pra fazer deploy de bundle precisa travar a CLI na série 1.19.x, porque não existe mais flag de volta.

Pontos técnicos que valem registrar:
- `bundle.engine: terraform` e `DATABRICKS_BUNDLE_ENGINE=terraform` agora retornam erro em vez de mudar o comportamento
- Falha na migração de state do Terraform existente também passou a ser erro, em vez de cair de volta pro Terraform como acontecia antes
- O campo `bundle.terraform` nas configurações de bundle está deprecado e não tem mais efeito nenhum, já que o engine por trás dele foi removido
- Quem precisa continuar usando Terraform pra deploy de bundle tem que fixar a CLI na série 1.19.x

**Minha ressalva:** a diferença entre "deprecado" e "removido" parece sutil até alguém atualizar a CLI num pipeline de CI/CD sem revisar o changelog primeiro. Time que ainda tem bundle com state Terraform não migrado corre risco real de quebrar deploy automatizado da noite pro dia ao atualizar pra 1.20.0; vale auditar qual versão da CLI está fixada em cada pipeline antes que a atualização aconteça sozinha.

**Fonte:** https://github.com/databricks/cli/releases/tag/v1.20.0

#Databricks #AzureDatabricks #DevOps
