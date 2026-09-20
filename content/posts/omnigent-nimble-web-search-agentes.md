---
title: "Busca na web de agente de IA virou parte do Omnigent, com Nimble no lugar da busca genérica"
date: 2026-09-18T07:30:00-03:00
draft: true
tags: ["Databricks", "Omnigent", "Agentes de IA", "Unity AI Gateway"]
summary: "A Databricks integrou o provedor de busca Nimble ao Omnigent pra resolver a inconsistência de qualidade entre as ferramentas de busca na web embutidas em cada harness de agente, com ganho relatado de 46% pra 71% de acurácia em benchmark e custo de busca cortado pela metade."
ShowToc: false
---

A mesma pergunta dava resposta diferente dependendo de qual harness respondia por ela.

A Databricks identificou um problema recorrente em quem constrói agente de IA: Claude Code, Codex e chamada de API crua vêm cada um com sua própria ferramenta de busca na web embutida, com qualidade inconsistente entre eles, o que trava qualquer tentativa de padronizar custo, governança ou trilha de auditoria entre plataformas diferentes.

A resposta veio pelo Omnigent, a camada de definição única de agente da própria Databricks: em vez de reconstruir a mesma lógica em cada harness, dá pra definir o agente uma vez (modelo, ferramenta, política e limite) e rodar em qualquer um deles, com toda chamada de modelo passando pelas Foundation Model APIs pra manter custo e governança num só lugar. Especificamente pra busca na web, o Omnigent passou a integrar o Nimble, um provedor especializado que substitui a ferramenta genérica embutida por capacidade mais próxima do domínio da pergunta.

Pontos técnicos e resultados relatados:
- Acurácia em benchmark de LLM subiu de 46% pra 71% ao trocar a busca padrão pela busca via Nimble
- Custo de busca caiu pela metade em comparação com a busca web padrão do Claude
- Nimble lida com conteúdo renderizado via JavaScript e paginação, cenário onde ferramenta de busca genérica costuma falhar
- O provedor reaproveita caminho de retrieval que já funcionou antes num mesmo domínio, reduzindo custo de token em consultas repetidas
- Toda chamada continua sob o mesmo controle de custo e governança do Unity AI Gateway, independente de qual harness disparou a busca

**Minhas considerações:** o salto de acurácia relatado, de 46% pra 71%, é grande o bastante pra merecer teste próprio antes de aceitar de olhos fechados, já que benchmark divulgado pelo próprio fornecedor tende a favorecer o cenário testado. Mas o argumento de fundo, unificar a ferramenta de busca em vez de deixar cada harness reinventar a própria, faz sentido pra quem já sofre com inconsistência entre ambientes diferentes de agente no dia a dia.

**Fonte:** https://www.databricks.com/blog/web-search-your-agent-inherited-isnt-good-enough

#Databricks #Omnigent #AgentesDeIA
