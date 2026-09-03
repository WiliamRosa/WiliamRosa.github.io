---
title: "AgentOps ganha um manual: a Databricks tenta dar nome à disciplina de operar agente em produção"
date: 2026-09-03T09:00:00-03:00
draft: false
tags: ["Databricks", "AgentOps", "MLflow", "Unity AI Gateway"]
summary: "O Big Book of AgentOps organiza em seis capítulos e sete fases de projeto o que já vínhamos vendo em pedaços soltos por aqui: MLflow pra avaliação e rastreamento, Unity Gateway pro tráfego de modelo e ferramenta, Unity Catalog pro controle de acesso, com resultado de cliente como FactSet e DXC Technology."
ShowToc: false
---

Todo mundo que já tentou colocar um agente de IA em produção sabe que o trabalho difícil começa depois do demo funcionar.

A Databricks lançou o Big Book of AgentOps, um material que tenta dar estrutura a algo que este blog já cobriu em pedaços separados: rastreamento automático de chamada de ferramenta, orçamento de gasto com IA, governança de acesso a modelo externo. O ebook organiza isso em seis capítulos, cobrindo desde arquitetura de agente até padrão de implantação que vai de workspace único até topologia multi-conta pra empresa grande, passando por um ciclo de vida de projeto em sete fases.

A base técnica não é novidade isolada, é a mesma peça que já apareceu aqui antes em contexto pontual: MLflow pra avaliação e rastreamento de execução, Unity Gateway administrando tráfego de modelo e ferramenta, Unity Catalog controlando acesso com privilégio mínimo. O que muda é a tentativa de amarrar essas peças num ciclo operacional parecido com DevOps, só que pensado pra sistema que decide sozinho, não só executa código determinístico.

Pontos técnicos que valem atenção:
- Seis capítulos cobrindo arquitetura de agente, padrão de implantação e ciclo de vida de projeto em sete fases
- Recomenda construir dataset de avaliação a partir de rastro real de produção, não só caso sintético de teste
- Reforça controle de acesso de privilégio mínimo via Unity Catalog como parte do ciclo operacional, não como item avulso de segurança
- Cita resultado de cliente: FactSet reportou 44% de melhora de acurácia, DXC Technology cortou 30% de custo de plataforma
- Trata validação de chamada de ferramenta, atribuição de custo e rastreamento de execução multi-etapa como prática operacional recorrente, não exceção

**Minha ressalva:** material assim tende a soar mais consolidado do que a realidade de quem está no dia a dia, a maioria das empresas ainda nem tem rastreamento básico de chamada de ferramenta funcionando, quanto mais um ciclo de sete fases rodando redondo. Serve mais como mapa de onde chegar do que como retrato do que já é padrão hoje.

**Fonte:** https://www.databricks.com/blog/announcing-databricks-big-book-agentops

#Databricks #AgentOps #MLflow
