---
title: "Consistência de estilo no Databricks não é só sobre Python, SQL também precisa de linter"
date: 2026-08-02T09:00:00-03:00
draft: true
tags: ["Databricks", "SQL", "Declarative Automation Bundles", "Opinião"]
summary: "O Databricks MVP Bartosz Konieczny mostra como usar o SQLFluff pra padronizar scripts SQL no Databricks, integrando a verificação ao ciclo de deploy dos Declarative Automation Bundles."
ShowToc: false
---

O Databricks MVP Bartosz Konieczny documentou como usar o SQLFluff pra impor um estilo consistente em scripts SQL no Databricks, indo além do Ruff, que ele já havia coberto pro lado Python. A configuração passa por um arquivo `pyproject`, com uma tarefa Poe compartilhada que pode servir tanto como aviso de commit local quanto como barreira de CI/CD.

O padrão de integração é o mesmo que ele já recomenda pro Ruff: não travar deploy em ambiente de sandbox com verificação de lint, reservar isso pra CI/CD em branch principal ou de release, e usar um hook de pre-commit local pra pegar o problema antes mesmo do código sair da máquina do desenvolvedor.

Por que isso importa pra quem já lida com Declarative Automation Bundles:
- SQL costuma ficar de fora das discussões de qualidade de código, tratado como "menos código de verdade" do que Python, na prática, é código que roda em produção do mesmo jeito
- Ter um linter dedicado pra SQL fecha a lacuna de quem já padronizou Python mas deixou os scripts SQL sem controle nenhum
- A mesma tarefa Poe compartilhada entre Ruff e SQLFluff mantém a configuração de qualidade centralizada, em vez de duas ferramentas com dois fluxos diferentes

**Minha ressalva:** com agente de código gerando cada vez mais SQL dentro de pipelines Databricks, um linter de estilo ajuda com legibilidade, mas não substitui revisão de lógica, SQL sintaticamente limpo e SQL correto são coisas diferentes, e nenhuma ferramenta de lint pega uma junção errada ou um filtro que muda silenciosamente o resultado de uma query.

**Fonte:** https://www.waitingforcode.com/databricks/sqlfluff-keeping-sql-queries-clean/read

#Databricks #SQL #QualidadeDeCodigo
