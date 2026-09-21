---
title: "Testei Genie Ontology, Pages, Domains e Skills lado a lado, e o workspace enriquecido respondeu até 40% mais rápido"
date: 2026-09-19T09:00:00-03:00
draft: false
tags: ["Databricks", "Genie", "Genie Ontology", "Unity Catalog"]
summary: "A Databricks MVP Julia Førde comparou dois workspaces com o mesmo dado, um enriquecido com Genie Ontology, Pages, Domains e Skills e outro sem, e viu respostas melhores e até 40% mais rápidas no workspace enriquecido."
ShowToc: false
---

Mesmo dado, mesmas metric views, dois workspaces: um só com Genie Ontology, Pages, Domains e Skills ativados, o outro sem nada disso.

A Databricks MVP Julia Førde passou uma semana testando o conjunto mais recente de recursos ao redor do Genie Ontology no Azure Databricks, Domains, Pages e Skills, num pipeline de dados que ela mesma construiu do zero pra esse fim. O teste comparou lado a lado dois workspaces com exatamente o mesmo dado e as mesmas metric views, um enriquecido com esses recursos e o outro deixado como referência sem eles.

Domains agrupam ativos como Genie Agents, dashboards, apps e Pages, e a recomendação dela é definir esse agrupamento pela forma como o usuário de negócio entende os ativos, não pela estrutura interna dos times que constroem cada peça. Pages documentam modelo de dado, o que existe em cada tabela e como um processo de negócio funciona de fato, e passam a integrar a camada de contexto modelada por humano dentro do Genie Ontology: quando uma Page é relevante pra uma pergunta, o Genie One prioriza essa informação sobre o que teria inferido sozinho, e cita a Page na resposta. Skills, por sua vez, fixam um fluxo obrigatório, por exemplo, toda pergunta sobre um assunto específico passa sempre pelas mesmas Pages, ativos de dado e Genie Agents, em vez de depender de o Genie descobrir esse caminho sozinho a cada conversa.

O que mais chamou atenção no teste:

- Domains devem refletir como o negócio consome os ativos, não o organograma do time de desenvolvimento por trás deles
- Pages viram parte do contexto modelado por humano e ganham prioridade sobre inferência automática, com citação da fonte na resposta do Genie One
- Skills escritas à mão aumentam a chance de o fluxo certo ser seguido de forma consistente, mesmo quando o Genie conseguiria chegar lá sozinho sem a regra explícita
- É possível inspecionar as fontes de conhecimento por trás de uma resposta, pequenos trechos extraídos automaticamente de metric views, dashboards, consultas SQL e Genie Agents
- No caso de teste dela, o workspace enriquecido deu respostas melhores e cerca de 30% a 40% mais rápidas que o workspace sem esses recursos

**Minha ressalva:** a própria Julia Førde é honesta ao dizer que isso não é um benchmark científico, é o teste de uma pessoa com um dataset próprio, então o ganho de 30-40% deve ser lido como sinal promissor, não como número garantido em qualquer ambiente. Vale lembrar também que esse ganho depende de alguém manter Pages e Skills atualizadas, um glossário de negócio abandonado vira tão inútil quanto a wiki que ele veio substituir.

**Fonte:** https://www.linkedin.com/in/julia-f%C3%B8rde-725258100/#genie-ontology-pages-domains-skills-teste

#Databricks #Genie #DatabricksMVP
