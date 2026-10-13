---
title: "MLflow 3.17.0 traz juiz Jev pronto pra usar e permissão granular com DENY explícito"
date: 2026-10-13T10:00:00-03:00
draft: false
tags: ["Azure Databricks", "MLflow", "GenAI", "Governança"]
summary: "O release 3.17.0 do MLflow adiciona modelo Jev da TypeSafe como juiz de avaliação pronto pra usar em mlflow.genai.evaluate(), permissão fina por run/trace/model version com DENY explícito, dashboard de Trace Analytics mais rápido em escala, e exige upgrade de banco pra servidor SQL-backed."
ShowToc: false
---

O Databricks MVP Awadelrahman Ahmed resumiu o pacote de novidades do MLflow 3.17.0, e dois itens chamam mais atenção que o resto da lista de correção.

O primeiro é suporte nativo a modelo da TypeSafe, chamado Jev, como juiz de avaliação dentro do fluxo já conhecido de `mlflow.genai.evaluate()`. Pra checagem binária ou de categoria finita, basta apontar o identificador do modelo Jev como juiz; cada decisão fica registrada como assessment, incluindo metadado de probabilidade, o que ajuda a identificar caso de fronteira em vez de só aceitar o veredito do juiz sem contexto.

O segundo é controle de acesso mais fino pra run, trace e versão de modelo: em vez de só conceder permissão por wildcard, agora dá pra montar um papel com DENY explícito pra uma ação específica, mesmo que outro grant mais amplo liberaria aquilo. Isso muda o modelo de permissão de "a permissão mais aberta sempre vence" pra algo que aceita negar pontualmente, útil pra workspace com equipe grande e política de acesso mais granular que um simples leitor-ou-admin.

Pontos técnicos do release:

- Juiz Jev entra como mais uma opção de avaliador automatizado dentro do pipeline de avaliação de GenAI já existente no MLflow, sem exigir infraestrutura própria de hospedagem de juiz
- A permissão com DENY se aplica a run, trace e model version, com exemplo oficial de papel "leitor de experimento" que ainda assim é bloqueado numa ação específica
- Dashboard de Trace Analytics ganhou otimização de performance voltada pra workspace com volume alto de trace
- Servidor SQL-backed exige migração de banco pra atualizar; upgrade misto de versão (parte do cluster numa versão, parte em outra) não é suportado, então o upgrade precisa ser coordenado

**Minha ressalva:** a documentação de RBAC atual do MLflow descreve o modelo de permissão como resolução por máximo entre grants, sem override de negação explícita, o que contradiz exatamente o que o anúncio do 3.17.0 promete. Pode ser que a doc geral ainda não tenha sido atualizada pra essa versão especificamente, mas antes de depender de DENY pra isolar dado sensível em produção, vale testar o comportamento manualmente num ambiente não produtivo, porque a documentação e o release note não estão alinhados nesse ponto.

**Fonte:** https://mlflow.org/releases/3.17.0/

#MLflow #GenAI #Governanca
