---
title: "Suas políticas de máscara de coluna agora podem confiar direto no Entra ID"
date: 2026-08-18T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Unity Catalog", "ABAC", "Microsoft Entra ID", "Opinião"]
summary: "Identity Attributes deixa políticas ABAC do Unity Catalog usarem atributos sincronizados do seu provedor de identidade — departamento, país — sem precisar recriar isso como grupo."
ShowToc: false
---

O Unity Catalog ganhou, em beta, a capacidade de escrever políticas ABAC de máscara de coluna e row filter usando **atributos de identidade** sincronizados do seu provedor (como o Microsoft Entra ID) — departamento, país, o que estiver disponível — em vez de depender só de pertencimento a grupo.

A diferença é sutil, mas resolve uma dor real de quem já mantém ABAC em produção: até aqui, se sua política precisava distinguir por atributo que não virou grupo explícito no Unity Catalog, a saída era criar um grupo só pra isso — e agora você tem mais um objeto de governança pra manter sincronizado manualmente.

Por que isso reduz trabalho de verdade:
- Atributo já existe no Entra ID — a política referencia ele direto, sem duplicar como grupo
- Menos objetos de governança pra manter alinhados entre identidade e Unity Catalog
- Política de máscara fica mais próxima da linguagem que RH e segurança já usam ("é do departamento X", não "está no grupo Y que criamos pra representar o departamento X")

**Minha ressalva:** depender de atributo sincronizado externamente introduz uma superfície de falha que grupo nativo do Unity Catalog não tem — se a sincronização com o Entra ID atrasar ou falhar silenciosamente, a política de máscara pode aplicar a regra errada sem nenhum alerta óbvio. Eu monitoraria a saúde dessa sincronização com o mesmo rigor que já dedico à política em si.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/august

#AzureDatabricks #UnityCatalog #EntraID
