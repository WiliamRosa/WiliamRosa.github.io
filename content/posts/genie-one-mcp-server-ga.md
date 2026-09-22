---
title: "Genie One virou uma ferramenta MCP oficial, com permissão do Unity Catalog em cada chamada"
date: 2026-09-26T09:00:00-03:00
draft: true
tags: ["Databricks", "Genie", "MCP", "Azure Databricks"]
summary: "O servidor MCP do Genie One (system.ai.genie_one_mcp) chegou à disponibilidade geral no Unity Gateway, expondo o Genie como ferramenta conversacional pra qualquer cliente MCP, como Claude, ChatGPT ou Cursor, sempre respeitando a permissão do Unity Catalog; o endpoint Beta antigo será desligado em 31 de outubro."
ShowToc: false
---

Perguntar pro Genie deixou de exigir estar dentro do Databricks.

O Azure Databricks confirmou a disponibilidade geral do servidor MCP do Genie One, disponibilizado como um MCP Service pronto, system.ai.genie_one_mcp, dentro do Unity Gateway. Na prática, qualquer cliente ou agente que fale o protocolo MCP, Claude, ChatGPT, Cursor ou uma ferramenta interna construída na mão, passa a conseguir perguntar direto pro Genie e receber resposta baseada em dado governado, sem reimplementar a lógica de conversa nem expor a API do Genie por fora.

O que muda em relação a simplesmente chamar a API do Genie na mão é o empacotamento: o servidor já vem pronto como serviço do Unity Gateway, então ele entra no mesmo controle de acesso, orçamento e observabilidade que qualquer outro MCP Service registrado ali. E a permissão aplicada em cada chamada é a de quem está perguntando, não a do agente ou da credencial que ele usa por trás, o que evita o cenário clássico de agente com acesso mais amplo que a pessoa que o está operando.

Pontos técnicos que valem atenção:
- O serviço roda como system.ai.genie_one_mcp dentro do Unity Gateway, sem precisar hospedar servidor MCP próprio
- Toda chamada respeita a permissão do Unity Catalog de quem está perguntando, aplicada por requisição
- O endpoint Beta antigo (/api/2.0/mcp/genie) fica obsoleto e será desligado em 31 de outubro de 2026
- Qualquer cliente MCP genérico consegue se conectar, não só ferramenta feita pela própria Databricks

**Minha ressalva:** o prazo de desligamento do endpoint Beta é curto, pouco mais de um mês contando da disponibilidade geral, então quem já tinha algo em produção usando o caminho antigo precisa migrar rápido. Fora isso, expor o Genie via MCP pra qualquer cliente externo levanta a pergunta de sempre com esse protocolo: a superfície de ataque cresce junto com a conveniência, e a garantia de permissão por requisição ajuda, mas não substitui revisar quem tem acesso a qual cliente MCP.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/agents/mcp-tools/genie-mcp

#Databricks #Genie #MCP
