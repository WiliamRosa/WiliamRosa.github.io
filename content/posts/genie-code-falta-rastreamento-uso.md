---
title: "Genie Code resolve a fricção de codar com agente, mas ainda não sabe dizer quem fez o quê"
date: 2026-09-24T09:00:00-03:00
draft: true
tags: ["Databricks", "Genie Code", "Unity Gateway", "MLflow", "Opinião"]
summary: "O Databricks MVP Casper Lubbers elogia o Genie Code por manter quem está acostumado com a UI do Databricks longe da fricção de configurar contexto num IDE, mas aponta que a plataforma ainda não rastreia quem usa o quê dentro do próprio Genie Code, apesar de já ter toda a infraestrutura pronta para isso."
ShowToc: false
---

Um agente de código que já resolve o problema de contexto ainda deixa uma pergunta básica sem resposta: quem está usando o quê.

O Databricks MVP Casper Lubbers testou o Genie Code de perto e reconhece o mérito dele: bridging a fricção técnica que ainda existe em codificação agêntica, principalmente para quem está acostumado a trabalhar direto na UI do Databricks e não quer migrar de fluxo de trabalho toda vez que precisa automatizar algo. Só que ao lado desse elogio vem uma cobrança pontual, o Genie Code ainda não expõe rastreamento de uso, quem chamou o quê, quando, com que resultado, mesmo a plataforma já tendo praticamente todas as peças prontas para isso.

O argumento técnico é direto: Unity Gateway já centraliza toda a requisição de modelo passando por ele, existe um servidor MLflow gerenciado que escala sem esforço, e o Zerobus Ingest já permite levar trace direto pro Unity Catalog sem pipeline intermediário. Juntar essas três peças pra rastrear uso do próprio Genie Code, não só do agente que ele orquestra, deveria ser questão de configuração, não de nova infraestrutura. Sem isso, times como o dele, que registram todo o uso interno do Databricks para aprender com o padrão de trabalho de cada pessoa, ficam sem visibilidade justamente sobre a ferramenta que mais cresce dentro da plataforma.

Pontos técnicos que valem registrar:
- Genie Code reduz fricção para quem prefere permanecer na UI do Databricks em vez de migrar pra um IDE como VS Code ou Zed
- A alternativa de trabalhar num IDE, com harness próprio como Claude Code ou Codex, ainda dá mais controle de contexto para quem já está confortável nesse fluxo
- Unity Gateway, MLflow gerenciado e Zerobus Ingest já formam, juntos, a base técnica que faltaria só ligar para rastrear uso do Genie Code
- Hoje não existe visão de quem usou o Genie Code, para qual tarefa e com que resultado, dentro da própria ferramenta

**Minha ressalva:** faz sentido a plataforma priorizar a experiência de quem está codificando antes de expor telemetria de uso para quem administra, mas esse tipo de lacuna tende a aparecer justamente quando a adoção cresce e alguém no time de plataforma precisa justificar custo ou investigar um gasto fora do esperado. Se as peças de infraestrutura já existem soltas, como o próprio Casper argumenta, a ausência de rastreamento built-in parece mais prioridade de roadmap adiada do que limitação técnica real.

**Fonte:** https://www.linkedin.com/feed/update/urn:li:activity:7508541241312051200/

#Databricks #GenieCode #Observabilidade
