---
title: "Já falei que Knowledge Assistant virou legado, mas não falei no que ele virou: o DurableAgentServer"
date: 2026-10-14T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Agentes de IA", "Agent Bricks", "Arquitetura"]
summary: "DurableAgentServer, parte do AgentKit do Agent Bricks CLI, serve agente via uma única API de invocação cobrindo execução síncrona, em stream e em segundo plano, com invocação idempotente via ID gerado pelo cliente, sessão ordenada e recuperação automática de execução interrompida por crash."
ShowToc: false
---

Complementando o que já vimos sobre Knowledge Assistant e Supervisor Agent virando legado, vale entender o mecanismo real por trás do que substitui os dois pra quem escreve agente em código: o DurableAgentServer, parte da biblioteca AgentKit que o Agent Bricks CLI já traz por padrão.

A peça central é tratar execução de agente como um servidor HTTP com estado persistente, não como uma chamada síncrona que morre se o worker cair no meio. Toda invocação carrega um ID gerado pelo cliente que funciona como chave de idempotência, reenviar a mesma requisição devolve o resultado já existente em vez de rodar o agente de novo. Invocação que compartilha o mesmo ID de sessão roda em ordem, uma de cada vez, e todo o estado de execução, status, evento e resultado, sobrevive a reinício de worker porque fica guardado numa Runtime Store dedicada, provisionada automaticamente num projeto Lakebase gerenciado pela própria Databricks.

A recuperação de crash funciona por batimento cardíaco: cada tentativa em andamento manda um sinal de vida a cada poucos segundos, e se esse sinal parar, o servidor detecta a execução travada em questão de segundos e dispara uma tentativa de substituição automaticamente, chamando um handler de recuperação que você registra separado do handler principal de invocação.

Pontos técnicos do mecanismo:

- Uma única API de invocação, `/api/invocations`, cobre os três modos de execução, síncrono, em stream via Server-Sent Events, e em segundo plano com URL de status, todos servidos pelo mesmo handler
- Recuperação cobre worker interrompido, não erro de código do próprio agente; se o handler lançar exceção, a invocação falha e não é reexecutada automaticamente
- Autorização com permissão do usuário que fez a requisição é suportada via `agent.toml`, mas invocação nesse modo não pode ser recuperada depois de uma falha, porque a credencial do usuário nunca fica persistida na Runtime Store
- Servidor é uma aplicação FastAPI por baixo, então dá pra adicionar rota HTTP própria além da API de invocação padrão
- Não dá pra trocar o tipo de servidor de agente de uma implantação já existente, trocar exige criar um projeto novo com `agentbricks init --server` e implantar sob outro nome

**Minhas considerações:** o detalhe mais revelador aqui é a Databricks estar migrando a hospedagem de agente pra um modelo que trata interrupção de worker como evento esperado e recuperável por padrão, em vez de algo que a aplicação precisa tratar manualmente toda vez. Isso é uma mudança de postura arquitetural que faz sentido na medida em que agente de produção passa a rodar tarefa mais longa e mais cara de reiniciar do zero. O ponto que exige atenção de quem for adotar isso agora é justamente a lacuna de recuperação em modo de autorização por usuário, útil saber disso antes de desenhar um agente que depende de permissão individual pra operação de longa duração.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/agents/deploy/agent-server

#AzureDatabricks #AgentesDeIA #AgentBricks
