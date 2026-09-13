---
title: "Genie Code agora aceita Skills pra carregar contexto especializado só quando precisa"
date: 2026-09-14T12:00:00-03:00
draft: true
tags: ["Databricks", "Genie Code", "IA Generativa", "Opinião"]
summary: "Skills empacotam instrução, exemplo e script executável num arquivo SKILL.md dentro de .assistant/skills/, e o Genie Code carrega automaticamente a skill relevante conforme o pedido do usuário, em vez de manter tudo em instrução global que consome contexto em toda conversa."
ShowToc: false
---

O Databricks MVP Ajay Kumar Pandey chamou atenção pra uma peça nova de personalização do Genie Code que resolve um problema comum de quem tenta padronizar uso de agente de código dentro de um time.

Instrução customizada global sempre teve o problema de ser aplicada em toda conversa, mesmo quando a maior parte dela não tem nada a ver com a tarefa em questão, o que desperdiça janela de contexto e às vezes até confunde o agente com regra irrelevante. As Skills seguem o padrão aberto Agent Skills e resolvem isso empacotando conhecimento de domínio, boa prática e até script executável num arquivo `SKILL.md`, carregado pelo Genie Code automaticamente só quando a descrição da skill bate com o pedido do usuário, ou manualmente via menção com `@`.

Existem dois tipos: skill de workspace, criada por administrador e disponível pra todo mundo, útil pra forçar padrão organizacional como mascaramento de coluna sensível; e skill de usuário, pessoal, útil pra preferência individual de biblioteca ou estilo de código, e também como rascunho antes de promover a skill pro nível de workspace.

Pontos técnicos:

- Skill vive em `.assistant/skills/`, cada uma com pasta própria contendo um `SKILL.md` obrigatório
- `SKILL.md` tem frontmatter com `name` e `description`, seguido de instrução em Markdown com passo a passo, exemplo e caso de borda
- Genie Code carrega a skill automaticamente com base na descrição e no pedido do usuário, ou por menção manual com `@`
- Skill de workspace fica em `Workspace/.assistant/skills/`; skill de usuário fica em `/Users/{usuario}/.assistant/skills/`
- Suporta script e arquivo de referência adicional, referenciados por caminho relativo dentro da pasta da skill
- Editar uma skill exige abrir chat novo pra aplicar a mudança, chat já aberto não atualiza sozinho

**Minha ressalva:** a promessa de "contexto só quando relevante" depende inteiramente da qualidade da descrição de cada skill, porque é justamente esse texto que o Genie Code usa pra decidir quando carregar. Skill mal descrita tende a nunca ser acionada automaticamente ou, pior, ser acionada no momento errado, então o trabalho real de adoção está em escrever descrição precisa, não em criar a skill em si.

Fonte: https://learn.microsoft.com/en-us/azure/databricks/genie-code/skills

#Databricks #GenieCode #AzureDatabricks
