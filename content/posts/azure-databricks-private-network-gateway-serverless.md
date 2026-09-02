---
title: "Serverless do Azure Databricks ganha um jeito de chegar na sua rede inteira, não só num recurso por vez"
date: 2026-08-31T10:00:00-03:00
draft: false
tags: ["AzureDatabricks", "Serverless", "Rede", "Opinião"]
summary: "Private Network Gateway conecta compute serverless a toda a VNet (e redes conectadas via ExpressRoute ou VPN) através de um único gateway gerenciado, complementando em vez de substituir os Private Endpoints."
ShowToc: false
---

Conectividade privada pro serverless do Azure Databricks até aqui era recurso por recurso, um Private Endpoint de cada vez.

O Databricks MVP Daniel Sahal chamou atenção pro Private Network Gateway logo na semana em que entrou em preview privado: uma opção nova pra quando o serverless precisa alcançar API interna, banco de dado, sistema on-premises ou passar pelo próprio firewall da empresa, em vez de só alcançar um recurso específico de nuvem de forma privada.

O mecanismo funciona delegando uma sub-rede da sua VNet pro Azure Databricks: o compute serverless passa a alcançar tudo que essa sub-rede alcança, incluindo rede conectada transitivamente via ExpressRoute ou VPN, como sistema on-premises. Ele não substitui Private Link, complementa: use Private Endpoint pra conexão privada direta com um recurso específico gerenciado na nuvem (como object storage), e use o gateway quando o objetivo for alcançar toda a rede, rotear egresso por appliance de segurança próprio, ou garantir IP de origem estável pra permitir allowlist em ambiente multi-tenant.

Detalhes técnicos que valem nota:
- Dois modos de tráfego: SPECIFIC_DESTINATIONS (roteia só os destinos listados) ou ALL_TRAFFIC (roteia todo egresso serverless pelo gateway)
- Regra de Private Link sempre tem prioridade: se existir Private Endpoint pra um recurso, o tráfego usa ele em vez do gateway, mesmo em modo ALL_TRAFFIC
- Limite durante o preview: uma NCC suporta no máximo dois gateways, e cada gateway suporta até dois resolvedores DNS e cem destinos
- Configuração hoje é só via API REST de conta, sem suporte de UI ou Terraform ainda

**Minha ressalva:** ainda está em Private Preview e, segundo a própria documentação, não é cobrado agora mas vai ser cobrado no futuro, o que muda o cálculo de quem for adotar cedo. Além disso, sem suporte a Terraform ainda, quem já trata toda a infraestrutura de rede como código vai ter que abrir uma exceção manual via API pra esse pedaço específico, ao menos até o recurso amadurecer.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/security/network/serverless-network-security/private-network-gateway

#AzureDatabricks #Serverless #Rede
