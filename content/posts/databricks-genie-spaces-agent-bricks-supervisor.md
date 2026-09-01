---
title: "Criar Genie Space parou de ser trabalho manual de clicar em tela"
date: 2026-08-14T09:00:00-03:00
draft: true
tags: ["Databricks", "Genie", "AgentBricks", "Opinião"]
summary: "Um MVP usou o Agent Bricks Multi-Agent Supervisor pra criar, atualizar e apagar Genie Spaces automaticamente, sem escrever código de agente do zero."
ShowToc: false
---

O maior gargalo pra escalar o Genie dentro de uma empresa nunca foi a experiência de fazer pergunta em linguagem natural, foi o trabalho manual de criar cada Genie Space.

O Databricks MVP Aarni Sillanpää encarou esse problema de frente: usou o Agent Bricks Multi-Agent Supervisor com sete funções do Unity Catalog empacotadas como ferramentas, mais um agente Knowledge Assistant, pra descobrir dados automaticamente, criar Genie Spaces, aplicar descrição de política da empresa, e atualizar ou apagar spaces existentes, tudo via chamada de API REST e system tables, sem precisar escrever código de agente customizado do zero.

A prova de conceito mostrou algo importante: o supervisor conseguiu criar um space novo a partir de descoberta dinâmica de dado no Unity Catalog e, na sequência, usar esse mesmo space recém-criado sem precisar de nenhuma reconfiguração manual. Deletar space também funcionou, mas acionou barreiras de segurança no caminho, sinal de que o sistema não deixa a ação mais destrutiva passar sem fricção.

Pontos que valem destacar:
- Sete funções do Unity Catalog fazem o trabalho pesado, sem exigir agente customizado escrito do zero
- Criação, atualização e exclusão de Genie Space viraram operação orquestrada, não clique manual repetido
- A automação de exclusão esbarrou em guardrails de segurança, o que é bom sinal, não falha

**Minha ressalva:** o próprio autor é claro que essa é uma prova de conceito, não algo pronto pra produção sem trabalho adicional de observabilidade e controle de segurança mais rígido. Orquestrar criação de Genie Space automaticamente é ótimo pra escala, mas também significa que um erro de escopo na automação cria (ou apaga) space errado em lote, não um de cada vez. Vale testar em ambiente controlado antes de apontar isso pra um catálogo de produção inteiro.

**Fonte:** https://www.ikidata.fi/post/automating-genie-management-with-agent-bricks-supervisor

#Databricks #Genie #AgentBricks
