---
title: "Skills de agente saíram do AI Dev Kit e viraram comando oficial da Databricks CLI"
date: 2026-09-15T09:00:00-03:00
draft: false
tags: ["Databricks", "Databricks CLI", "Claude Code", "Genie Code"]
summary: "O Databricks MVP Sudarshan Koirala mostrou que as Agent Skills, antes soltas no AI Dev Kit, agora fazem parte oficial da Databricks CLI, com um comando único que instala a mesma skill em Claude Code, Cursor, Copilot, Gemini CLI e no Genie Code."
ShowToc: false
---

Um comando só instala a mesma skill em Claude Code, Cursor, Copilot, Gemini CLI e no Genie Code, sem duplicar arquivo em cada ferramenta.

O Databricks MVP Sudarshan Koirala mostrou que as Agent Skills, que até então viviam soltas dentro do AI Dev Kit, agora são parte oficial da Databricks CLI, com um comando de instalação que resolve sozinho onde cada agente de código espera encontrar o arquivo de skill.

Uma skill continua sendo um único arquivo, SKILL.md, escrito em linguagem natural simples, funcionando como o conjunto de regras que o agente lê antes de escrever código, não como uma ferramenta que ele chama durante a execução. O comando `databricks aitools install` detecta quais agentes de código já estão configurados na máquina, Claude Code, Cursor, GitHub Copilot, Gemini CLI e outros, e instala a mesma skill no formato e no lugar que cada ferramenta espera, sem exigir que a pessoa configure cada uma manualmente. A mesma skill também funciona dentro do Genie Code, direto no workspace, sem precisar copiar o arquivo pra um editor local.

O que muda na prática:

- SKILL.md continua sendo texto em linguagem natural, e não uma tool chamável pelo agente
- `databricks aitools install` identifica os agentes já presentes no ambiente e instala a skill no formato que cada um exige
- Compatível com Claude Code, Cursor, GitHub Copilot e Gemini CLI, entre outros agentes de código
- A mesma skill roda também dentro do Genie Code, sem precisar de editor local
- Koirala escreveu a própria skill só pra forçar convenção de nome de tabela e de tag no time dele, e o agente passou a seguir essa regra sem precisar repetir o pedido a cada conversa

**Minha ressalva:** isso ataca um problema diferente do que já vimos em Unity Catalog Skills (skill como objeto governado, com dono e permissão) e do Genie Code carregando skill automaticamente por conta própria: aqui o alvo é distribuir a mesma regra pra ferramentas de terceiros que o time já usa no dia a dia, fora do Databricks. Fica em aberto se essa convenção informal de SKILL.md continua interoperável conforme cada fornecedor de agente de código evoluir seu próprio formato de skill.

**Fonte:** https://www.linkedin.com/in/sudarshan-koirala/#databricks-agent-skills-cli-oficial

#Databricks #ClaudeCode #GenieCode
