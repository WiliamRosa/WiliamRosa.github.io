---
title: "Um Genie Agent por commodity não escala: o padrão de composição MCP para federar vários agentes estreitos"
date: 2026-09-26T09:00:00-03:00
draft: false
tags: ["Databricks", "Genie Agents", "MCP", "Azure Databricks"]
summary: "Cada Genie Agent aceita até 25 tabelas do Unity Catalog, um limite que parece pequeno até você perceber que é isso que força o design certo: em vez de um agente gigante e genérico, vários agentes estreitos por domínio, cada um exposto como servidor MCP, compostos atrás de um proxy que roteia por nome."
ShowToc: true
---

Existe uma tentação natural ao modelar um Genie Agent: colocar tabela demais dentro dele. Se o agente pode responder pergunta sobre vendas, por que não incluir também estoque, logística e financeiro no mesmo espaço, já que o usuário às vezes pergunta coisa que atravessa mais de uma área? O problema é que essa tentação esbarra num limite técnico real, e o limite existe por um bom motivo.

Um Genie Agent no Azure Databricks é escopado a até 25 tabelas do Unity Catalog que ele mantém em contexto. Não é um teto arbitrário de produto, é o que garante que o agente continue preciso: quanto mais tabela heterogênea dentro do mesmo espaço, mais ambígua fica a pergunta "de qual dessas tabelas vem a resposta". Uma equipe de energia da S&P Global bateu de frente com essa realidade ao tentar tornar conversacional um data estate que cobria múltiplas commodities, e o padrão arquitetural que usaram pra contornar o limite, sem abrir mão de precisão, vale entender mesmo fora do contexto específico deles.

## O limite de 25 tabelas não é o problema, é o guia de design

Um Genie Agent MCP server no Azure Databricks é um managed MCP server que deixa um agente externo consultar um único Genie Agent em linguagem natural, sem escrever SQL: a pergunta chega em texto livre, o Genie gera e roda o SQL contra as tabelas daquele espaço específico, e a permissão do Unity Catalog é aplicada em cada requisição. Isso funciona bem quando o espaço é coerente. Quando o espaço mistura domínio demais, a mesma mecânica que dá precisão vira fonte de erro, porque o modelo por trás do Genie Agent tem que decidir sozinho qual das 25 tabelas de assuntos variados é relevante pra cada pergunta.

A saída não é pedir um limite maior, é aceitar o limite como sinal de design: um Genie Agent por domínio coeso, não um agente generalista tentando cobrir a empresa inteira.

## A arquitetura em três camadas

O padrão que a equipe aplicou separa claramente responsabilidade de curadoria, de exposição, e de composição:

**Camada 1, curadoria por especialista de domínio.** Quem entende profundamente uma área específica (não o time de dados central) escolhe as tabelas relevantes, sejam nativas do Unity Catalog ou federadas de fora via Lakehouse Federation, e monta um Genie Agent por subdomínio, não por commodity inteira. No caso de gás natural liquefeito, isso virou sete agentes distintos: ativos, carga, licitação, interrupção, oferta e demanda, netback, e preço, cada um com seu próprio conjunto coeso de tabelas.

**Camada 2, exposição automática como servidor MCP.** Cada Genie Agent criado já expõe automaticamente um endpoint MCP próprio, no padrão `https://<workspace>/api/2.0/mcp/genie/{genie_space_id}`, com escopo OAuth `genie` e permissão do Unity Catalog herdada e aplicada em cada chamada. Não é um passo de configuração manual à parte, é consequência direta de criar o agente.

**Camada 3, composição via proxy com namespace.** Um proxy (a equipe usou o padrão FastMCP) agrupa múltiplos servidores MCP de Genie Agent num bundle único por área maior de negócio, prefixando o nome de cada ferramenta pra evitar colisão e ajudar o modelo que consome o bundle a rotear certo. Um bundle de commodity LNG, por exemplo, expõe ferramentas como `cargo_genie_query_agent` e `outages_genie_query_agent`, cada prefixo apontando pro Genie Agent certo por trás.

## Mão na massa: compondo o bundle

Uma composição desse tipo, escrita do zero seguindo o mesmo princípio (não é código copiado de fonte nenhuma, é o padrão geral aplicado), tem essa forma:

```python
from fastmcp import FastMCP
from fastmcp.client.transports import StreamableHttpTransport

# Um agente Genie por domínio coeso, não um agente generalista
GENIE_AGENTS = {
    "ativos": "https://<workspace>/api/2.0/mcp/genie/space-ativos-lng",
    "carga": "https://<workspace>/api/2.0/mcp/genie/space-carga-lng",
    "interrupcao": "https://<workspace>/api/2.0/mcp/genie/space-interrupcao-lng",
}

bundle = FastMCP("lng-commodity-bundle")

for prefixo, url in GENIE_AGENTS.items():
    sub_server = FastMCP.as_proxy(
        StreamableHttpTransport(url, headers={"Authorization": f"Bearer {token}"})
    )
    # Namespace evita colisão: vira "{prefixo}_genie_query_agent" no bundle final
    bundle.mount(sub_server, prefix=prefixo)

bundle.run()
```

O consumidor final do bundle (o LLM que orquestra a conversa) enxerga um conjunto só de ferramentas nomeadas por prefixo, mas cada chamada continua sendo roteada pro Genie Agent certo, com a permissão do Unity Catalog daquele espaço específico aplicada por baixo.

## O padrão pergunta-então-consulta, e por que ele existe

Chamar um Genie Agent via MCP não é uma requisição síncrona simples de pergunta-resposta. O fluxo descrito segue um padrão de pergunta-então-consulta: uma chamada inicial dispara a pergunta e recebe de volta um identificador de conversa e de resposta, e uma segunda chamada, feita em polling, recupera o progresso e o resultado final assim que fica pronto. Esse desenho existe porque o Genie Agent às vezes precisa rodar mais de uma consulta SQL em sequência antes de montar a resposta final, e uma chamada síncrona simples deixaria o cliente esperando sem visibilidade de progresso.

**Minha leitura:** o detalhe mais fácil de subestimar nesse padrão é que ele resolve um problema de composição que a maioria dos times só percebe depois de já ter modelado o primeiro agente grande demais. Modelar por domínio coeso desde o início custa mais disciplina de curadoria na largada, exige um especialista por área em vez de um time central fazendo tudo, mas evita a reforma dolorosa de quebrar um agente monolítico em pedaços depois que ele já está em produção e todo mundo depende dele do jeito errado.

## O que isso não resolve

O padrão de composição resolve escala e organização, não resolve precisão semântica por si só. Cada Genie Agent individual ainda depende inteiramente da curadoria feita pelo especialista de domínio, descrição de tabela, exemplo de consulta, definição de termo de negócio, e nenhuma camada de composição corrige um Genie Agent mal modelado por baixo. O servidor MCP de Genie Agent também é estritamente somente leitura, não escreve em tabela nenhuma, e não repassa histórico de conversa entre chamadas, então contexto multi-turno precisa ser resolvido por fora, num sistema multiagente que gerencie isso explicitamente. E a arquitetura em camadas não elimina a necessidade de avaliação contínua: um Genie Agent Benchmark mal cuidado dentro de qualquer uma das camadas contamina a resposta que chega até o usuário final, exatamente como aconteceria num agente único.

## Vale adotar esse padrão antes de precisar dele?

Um punhado de tabelas cabe confortavelmente dentro do limite de um único Genie Agent, então a tentação de não se preocupar com composição cedo é real. Mas o custo de migrar de um agente monolítico pra um conjunto de agentes federados depois que a organização já depende do primeiro é bem mais alto do que desenhar os limites de domínio direito desde o começo. Se a resposta pra "quantas tabelas heterogêneas esse Genie Agent vai precisar cobrir daqui a um ano" for incerta, o padrão de composição por domínio, com exposição MCP e proxy de namespace, é a aposta mais segura mesmo que pareça esforço adiantado demais hoje.

## Referências

- Databricks Docs, "Genie Agent MCP server": https://docs.databricks.com/aws/en/agents/mcp-tools/genie-agent
- Microsoft Learn, "Genie Agent MCP server - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/agents/mcp-tools/genie-agent
- Databricks Docs, "Federated queries": https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-federated-queries
- Databricks Blog, "From Data to Dialogue: How S&P Global Energy Made Its Structured Data Estate Conversational with Databricks": https://www.databricks.com/blog/data-dialogue-how-sp-global-energy-made-its-structured-data-estate-conversational-databricks

#Databricks #GenieAgents #MCP #AzureDatabricks
