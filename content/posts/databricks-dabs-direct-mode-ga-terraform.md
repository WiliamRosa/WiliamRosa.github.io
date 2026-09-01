---
title: "Direct mode virou padrão nos Databricks Asset Bundles — o Terraform está com os dias contados aqui"
date: 2026-08-28T09:00:00-03:00
draft: false
tags: ["Databricks", "Declarative Automation Bundles", "Terraform", "CI/CD", "Opinião"]
summary: "O engine 'direct' virou padrão pra bundles criados no workspace desde 13 de agosto, e vira padrão geral da CLI em 26 de agosto. O suporte ao Terraform está no caminho da deprecação."
ShowToc: false
---

🚀 O engine "direct" dos Declarative Automation Bundles (ex-Databricks Asset Bundles) já é o padrão para bundles criados a partir do workspace desde 13 de agosto de 2026, e vira padrão geral da CLI em 26 de agosto. Quem já testou reporta até 40% de deploy mais rápido, sem depender do provider do Terraform por trás.

Isso é o desfecho natural de uma mudança que já vinha sendo sinalizada: o engine direct nasceu como substituto drop-in do engine Terraform (que sempre esteve por baixo dos bundles desde o início), e agora a Databricks confirma o suporte ao Terraform como caminho de saída, não mais o padrão.

Por que isso interessa mesmo pra quem não usa bundle todo dia:
- Deploy mais rápido sem provider externo significa menos dependência de binário/plugin do Terraform no pipeline de CI/CD
- Quem ainda depende de customização via Terraform provider pode continuar usando (`bundle.engine: terraform`), mas já recebe aviso de depreciação
- É o tipo de mudança de infraestrutura interna que geralmente passa despercebida até quebrar um pipeline de CI/CD que ninguém tocava há meses

❗ Minha ressalva: migração de engine de deploy é sempre mais arriscada do que parece no changelog. Bundles com customização pesada via provider Terraform (recursos que o engine direct ainda não cobre) merecem um teste completo em ambiente de staging antes da virada de padrão — não vale confiar só no "drop-in replacement" da documentação sem validar o caso específico do seu pipeline.

🔗 Fonte: https://www.sunnydata.ai/blog/databricks-dabs-direct-mode-ga

#Databricks #DeclarativeAutomationBundles #DevOps
