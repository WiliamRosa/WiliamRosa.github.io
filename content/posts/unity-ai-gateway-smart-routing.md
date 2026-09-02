---
title: "Unity AI Gateway ganhou roteamento automático de modelo pra tarefa de código"
date: 2026-08-14T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity AI Gateway", "IA Generativa", "Opinião"]
summary: "Smart Routing no Unity AI Gateway classifica cada tarefa de codificação e escolhe automaticamente entre modelo mais barato ou mais caro, com ganho reportado de até 65% de economia mantendo qualidade próxima do Opus 5."
ShowToc: false
---

Escolher manualmente qual modelo usar em cada tarefa de código é trabalho que já devia ter virado automático.

A Databricks lançou o Smart Routing dentro do Unity AI Gateway, um roteador que decide sozinho qual modelo chamar pra cada tarefa de codificação, sem o desenvolvedor precisar trocar de modelo na mão. A ideia central é que boa parte do trabalho de agente de código, corrigir erro de sintaxe, ajustar import, escrever teste simples, não precisa do modelo mais caro disponível, e mandar tudo pro modelo de ponta é desperdício.

O roteador usa um classificador leve que olha o componente do sistema envolvido, a evidência no código, o padrão da falha e onde a correção provavelmente precisa acontecer, e a partir disso decide entre escalar pra um modelo mais forte ou descer pra um mais barato. Essa decisão acontece no nível da sessão inteira, não a cada chamada isolada, justamente pra não quebrar cache de contexto no meio de uma tarefa.

Pontos técnicos que valem atenção:
- Funciona nativamente dentro do Claude Code e do Codex, sem mudança de fluxo pro time
- Integra com o Omnigent pra otimizar a escolha entre múltiplos harnesses de agente
- Benchmark interno da Databricks reportou 35% de economia mantendo qualidade equivalente
- Benchmark público citado aponta até 56% de economia de custo mantendo resultado perto do Opus 5, com claim de até 65% de redução de custo por tarefa

**Minha ressalva:** todo número de economia divulgado aqui vem de benchmark da própria Databricks, e roteamento automático erra quando a tarefa é ambígua, o risco real é escalar tarde demais numa tarefa que parecia simples e não era. Vale medir taxa de re-trabalho, não só custo por chamada, antes de confiar o roteamento sem supervisão num pipeline crítico.

**Fonte:** https://www.databricks.com/blog/smart-routing-unity-ai-gateway-match-frontier-quality-30-lower-cost-task

#Databricks #UnityAIGateway #IAGenerativa
