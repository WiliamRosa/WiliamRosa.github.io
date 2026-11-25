---
title: "Mais da metade dos incidentes de pipeline exige conhecimento que só sua empresa tem, e o Genie ZeroOps aprendeu isso com 80 mil casos reais"
date: 2026-11-20T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Genie ZeroOps", "Observabilidade", "Agentes de IA"]
ShowToc: true
summary: "Genie ZeroOps saiu do preview privado pra Beta Público depois de observar mais de 80 mil incidentes reais de pipeline em centenas de empresas, e o achado mais importante não foi técnico: mais da metade dos problemas só é resolvido com conhecimento específico daquele negócio, o que levou a quatro recursos novos (inbox compartilhada, instrução customizada, notificação com resumo e PR de um clique) em vez de só mais automação genérica."
---

Toda empresa que já rodou pipeline de dado em produção conhece os dois tipos de falha que tiram alguém do sono. A primeira é a falha barulhenta: um job quebra, uma atualização de pipeline estoura erro, alguém recebe página. A segunda é pior, porque ninguém percebe na hora: uma tabela para de atualizar, ou uma carga chega com metade das linhas de sempre, e só alguém nota quando um dashboard já está errado há dias.

O Genie ZeroOps, anunciado em junho e testado em preview privado com centenas de clientes reais, promete detectar, investigar e já propor correção pros dois tipos de falha. Agora, em Beta Público, o Azure Databricks publicou algo mais interessante do que o anúncio de disponibilidade: o que aprendeu observando mais de 80 mil incidentes reais antes de abrir pra todo mundo.

## O mecanismo: cinco etapas, da detecção ao pull request

O agente segue um fluxo declarado em cinco etapas. Primeiro, **detectar**: monitoramento contínuo de job, pipeline e tabela, cobrindo tanto falha dura (via monitoramento de execução) quanto falha silenciosa de frescor ou completude (via Data Quality Monitoring, sinalizando quando um commit chega atrasado demais ou a contagem de linha cai abaixo do esperado). Segundo, **investigar**: reúne contexto cruzando log, código-fonte, metadado de tabela e linhagem do Unity Catalog, roda consulta SQL pra achar causa raiz, e prioriza o que investigar primeiro pelo impacto rio abaixo. Terceiro, **verificar**: testa a correção proposta com teste unitário e execução seca num sandbox, antes de aplicar qualquer coisa de verdade. Quarto, **notificar**: manda alerta pro Slack, Microsoft Teams ou PagerDuty com resumo e correção recomendada, com filtro pra silenciar incidente de baixa prioridade. Quinto, **remediar**: propõe a correção em código e, pra job com backing em Git, já cria o pull request com os detalhes preenchidos.

A diferença declarada em relação a simplesmente pedir pra um agente de código genérico investigar é o acesso embutido: o ZeroOps já enxerga histórico de execução, linhagem do Unity Catalog, histórico do Delta e sinal de qualidade de dado, respeitando a permissão existente do Unity Catalog, sem precisar que alguém monte esse contexto manualmente a cada chamada.

{{< figure src="inbox-zeroops-incidentes.png" alt="Inbox do Genie ZeroOps listando incidentes recentes detectados em pipeline, job e tabela" caption="A inbox compartilhada do ZeroOps: todo incidente detectado aparece listado, com status e prioridade visíveis pra qualquer pessoa do time." >}}

## O achado real: mais da metade dos incidentes exige conhecimento tribal

Durante o preview privado, o Genie ZeroOps observou mais de 80 mil incidentes reais, espalhados por centenas de empresas. O achado que a própria Databricks destaca como o mais importante não é sobre acurácia de modelo: é que mais da metade dos incidentes só pôde ser triada, priorizada e resolvida corretamente com conhecimento específico daquela organização, não com conhecimento genérico de engenharia de dado.

Isso molda diretamente os quatro recursos novos do Beta Público:

- **Inbox compartilhada**: gerenciar pipeline é esporte de equipe, então o mesmo incidente aparece pra todo mundo do time, eliminando lacuna de cobertura entre pessoas de plantão diferentes.
- **Instrução customizada de agente**: cada time opera diferente, então é possível registrar fonte de dado conhecida por ser instável, correção preferida da equipe, ou convenção de nomenclatura própria, pra o agente levar isso em conta antes de propor qualquer coisa.
- **Notificação com resumo**: um resumo e uma recomendação por novo incidente, com ruído filtrável via instrução customizada.
- **PR de um clique**: passar de diagnóstico pra resolução com um clique, com a correção de código e os detalhes do PR já pré-preenchidos.

**Minha leitura:** esse é o tipo de achado que vale mais do que qualquer número de acurácia que a Databricks pudesse ter publicado. Um agente que resolve corretamente a metade "genérica" dos incidentes já economiza tempo real, mas a decisão de investir em instrução customizável e inbox compartilhada, em vez de tentar fazer o modelo absorver sozinho todo conhecimento tribal de cada cliente, é uma aposta de produto mais honesta do que prometer que IA generalista resolve tudo sem contexto local.

## Mão na massa: ativando e configurando

A ativação parte da página de Previews do workspace, como administrador, habilitando "Genie ZeroOps". Depois disso, o ponto de entrada é a própria página de Jobs & Pipelines:

```text
# Fluxo de configuração inicial, resumido da documentação oficial
1. Na página Jobs & Pipelines, clique em "Open ZeroOps"
2. Clique em "Configure" para abrir o chat do Genie Code
3. Escolha quais jobs, pipelines e tabelas monitorar
4. O ZeroOps faz backfill de insight das últimas 24 horas automaticamente
```

A permissão exigida pra configurar é `OWNER`, `CAN MANAGE` ou `CAN VIEW` sobre o recurso monitorado, e credencial Git é opcional, só necessária se você quiser o recurso de PR automático. A instrução customizada do agente fica salva em texto puro, em `/Workspace/Users/<seu-usuario>/.assistant/zeroops/instructions.md`, o que significa que dá pra versionar e revisar essa instrução como qualquer outro artefato de configuração do workspace.

## O que isso não resolve

A Databricks é explícita sobre o limite de autonomia: o ZeroOps "nunca muda seu código ou dado sem aprovação direta". Em job com backing em Git, a correção vai pra um branch novo via pull request, nunca direto pra produção. Mas a documentação também é honesta sobre um risco de longo prazo que ainda não tem solução fechada: acúmulo de contexto (instrução customizada, histórico, conhecimento tribal registrado) pode levar a alucinação ou queda de acurácia ao longo do tempo, o que exige avaliação contínua, não configuração única.

Nenhum número de acurácia ou taxa de resolução foi publicado, só o volume observado (80 mil incidentes) e a proporção qualitativa (mais da metade exige conhecimento local). Pra quem está decidindo adotar, vale tratar isso como limite real de transparência: dá pra confiar no volume de dado que embasa o produto, mas não dá pra citar uma taxa de acerto que a própria Databricks ainda não divulgou.

**Na prática:** eu trataria o recurso de PR automático com a mesma cautela que trataria qualquer ferramenta que escreve código sozinha: reservaria pra pipeline onde o schema e a lógica de negócio já são bem compreendidos pelo time, e manteria revisão humana obrigatória no PR, não só confiança de que o sandbox de verificação pegou todo problema possível antes da correção chegar até você.

## Vale adotar?

Vale testar em Beta Público pra quem já sente a dor de "ninguém sabe por que o pipeline quebrou" com frequência suficiente pra justificar o tempo de configurar instrução customizada e conectar canal de notificação. O ganho mais concreto não é o agente em si, é o reconhecimento de que conhecimento tribal precisa de um lugar formal pra morar (a instrução customizada, versionável) em vez de ficar só na cabeça de quem está de plantão naquela semana. Ainda assim, trate o PR de um clique como ponto de partida de revisão, não como aprovação automática, porque o próprio fornecedor reconhece que acurácia pode cair com o tempo sem avaliação contínua.

## Referências

- Databricks Blog, "Genie ZeroOps, now in public beta: An autonomous agent that fixes data pipelines, with lessons from 80,000 customer issues": https://www.databricks.com/blog/genie-zeroops-now-public-beta-autonomous-agent-fixes-data-pipelines-lessons-80000-customer
- Databricks Docs (AWS), "Get started with Genie ZeroOps": https://docs.databricks.com/aws/en/zeroops/get-started
- Microsoft Learn, "Get started with Genie ZeroOps - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/zeroops/get-started
- Microsoft Learn, "Data quality monitoring - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/data-quality-monitoring/

#AzureDatabricks #GenieZeroOps #Observabilidade #AgentesDeIA
