---
title: "Governance Hub junta dado, IA e custo numa tela só, e ainda faltava exatamente isso"
date: 2026-08-31T09:00:00-03:00
draft: false
tags: ["Databricks", "Governança", "UnityCatalog", "Opinião"]
summary: "Governance Hub (Beta) é uma visão no nível de conta que reúne saúde de dado, gasto e uso de IA, e recomendações de custo num só lugar, sem substituir Unity Catalog ou orçamentos existentes."
ShowToc: false
---

Faltava um lugar só pra enxergar governança no Databricks, e agora existe.

O Databricks MVP Daniel Sahal apontou o Governance Hub assim que ele apareceu: até aqui, entender cobertura de dado, uso e gasto com IA, principais fontes de custo e tag faltando exigia navegar entre abas diferentes, system tables separadas e telas de administração distintas, o que fica difícil de acompanhar em ambiente grande.

O Governance Hub é uma UI no nível de conta (não de workspace) organizada em quatro páginas: Data (acesso a objeto, uso de ativo, tags governadas, classificação e qualidade de dado), AI (uso de token, orçamento, atividade por modelo e usuário), Cost (fonte de custo, orçamento, cobertura de tag e recomendações) e Tags (atribuições recentes e lacunas de cobertura). Um admin de conta ativa a funcionalidade pela página de Previews do console de conta, e os dados levam até um dia pra carregar depois disso.

Detalhes técnicos que valem nota:
- Não introduz permissão nova: cada pessoa vê só o que já tinha acesso via Unity Catalog
- Admin de workspace vê a página de Cost só dos workspaces que administra
- Admin de metastore vê a página de Data só dos metastores que administra
- Não substitui Unity Catalog nem orçamentos existentes, é uma camada de visão consolidada por cima do que já existe

**Minha ressalva:** ainda está em Beta, e "uma tela só pra tudo" tem um risco embutido: vira o ponto de referência padrão do time mesmo antes de a cobertura de dado estar completa ou o cálculo de custo estar totalmente ajustado. Eu trataria os números do Governance Hub como direção, não como verdade absoluta, até a funcionalidade sair de Beta e a Databricks confirmar paridade completa com as fontes originais que ele está resumindo.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/admin/governance-hub/

#Databricks #Governança #UnityCatalog
