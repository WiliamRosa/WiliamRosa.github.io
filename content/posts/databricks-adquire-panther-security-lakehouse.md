---
title: "Databricks compra a Panther e aposta todas as fichas no 'security lakehouse'"
date: 2026-08-04T09:00:00-03:00
draft: false
tags: ["Databricks", "Segurança", "LakeWatch", "Opinião"]
summary: "Com a aquisição da Panther concluída, a Databricks une workflows de SOC e detecção de ameaças ao LakeWatch — uma tacada clara contra o modelo tradicional de SIEM."
ShowToc: false
---

A Databricks concluiu a aquisição da Panther, plataforma de SOC (Security Operations Center) com IA, unindo os workflows de detecção e investigação da Panther ao LakeWatch — o "security lakehouse" aberto da própria Databricks.

A Panther traz mais de 100 integrações de dados prontas, detecção como código, e workflows de SOC agênticos pra automatizar investigação de alerta. Juntando isso ao LakeWatch, a proposta é clara: reter petabytes de telemetria em formato aberto, rodar agentes autônomos de triagem em tempo real, e executar detecção como código sobre dado governado — em vez de depender de um SIEM tradicional fechado e caro por volume de log.

Por que essa aquisição merece atenção mesmo de quem não é do time de segurança:
- SIEM tradicional cobra pesado por volume de dado retido — o argumento do "security lakehouse" é justamente desacoplar retenção de custo de licença
- Trazer segurança pra dentro do mesmo Lakehouse que já governa o resto dos dados elimina mais uma cópia de dado vivendo isolada numa ferramenta à parte
- É outro sinal de que a Databricks está comprando capacidade especializada (como fez com Neon pro Lakebase) em vez de construir tudo internamente do zero

**Minha ressalva:** integrar uma aquisição de segurança é historicamente mais lento e mais arriscado do que integrar uma aquisição de infraestrutura de dados — workflow de SOC tem processo, certificação e confiança de analista construídos ao longo de anos, e isso não se copia junto com o código-fonte. Eu esperaria a integração real (não só o anúncio) antes de migrar operação crítica de segurança pra cá.

**Fonte:** https://www.databricks.com/blog/databricks-completes-acquisition-panther-accelerating-security-lakehouse-era

#Databricks #Segurança #LakeWatch
