---
title: "MLflow 3.15 trata servidor MCP como ativo organizacional, não mais config local de cada um"
date: 2026-08-12T09:00:00-03:00
draft: true
tags: ["Databricks", "MLflow", "MCP", "Opinião"]
summary: "O MCP Registry é o terceiro 'primo' da família Registry do MLflow, depois de Model e Prompt. O Databricks MVP Awadelrahman Ahmed detalha essa e outras novidades da versão 3.15."
ShowToc: false
---

O Databricks MVP Awadelrahman Ahmed descreve bem o padrão que se repete no MLflow 3.15, que trouxe o MCP Registry: modelo virou ativo compartilhado que times precisam versionar e promover, depois prompt seguiu o mesmo caminho, e agora servidor MCP está indo na mesma direção. Um MCP Registry só faz diferença real quando várias equipes já compartilham os mesmos servidores MCP, pra quem usa um ou dois sozinho, é overhead desnecessário.

A versão também trouxe outras mudanças que, juntas, mostram pra onde o MLflow está indo: suporte a Claude Code e Codex no MLflow Assistant, com visibilidade de chamadas de ferramenta, aprovações e custo de token durante a execução; juízes multimodais capazes de avaliar imagem dentro de traces, não só texto; visualizações compartilháveis de tabela de execuções (defina coluna, filtro e ordenação uma vez, compartilhe o link); e transferência de artefato sem proxy, relevante pra quem lida com artefato grande.

Por que essa versão é mais significativa do que um changelog qualquer:
- Servidor MCP virar "ativo organizacional com registro" é reconhecimento de que múltiplos agentes dentro da mesma empresa já compartilham as mesmas ferramentas, e isso precisa de governança, não só configuração local
- Visibilidade de chamada de ferramenta, aprovação e custo de token durante a execução do assistant é exatamente o tipo de observabilidade que falta na maioria dos fluxos de agente hoje
- Juiz multimodal fecha uma lacuna real: avaliação de agente que trabalha com imagem não tinha, até aqui, um jeito nativo de ser avaliada automaticamente

**Minha ressalva:** "registro para servidor MCP" resolve o problema de descoberta e versionamento, mas não resolve sozinho a pergunta mais difícil de governança de MCP, quem decide qual time pode usar qual servidor, com qual escopo de permissão. Um registro sem uma camada de política de acesso por cima é só um catálogo bem organizado; a parte difícil de "quem pode usar o quê" continua em aberto.

**Fonte:** https://www.linkedin.com/in/awadelrahman/

#Databricks #MLflow #MCP
