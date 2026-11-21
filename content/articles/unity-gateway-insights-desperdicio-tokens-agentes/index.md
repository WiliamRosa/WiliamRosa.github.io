---
title: "Seu agente de código está gastando token em quê? O relatório que o Unity Gateway Insights tira do trace"
date: 2026-11-19T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Unity Gateway", "Agentes de IA", "FinOps"]
ShowToc: true
summary: "Unity Gateway Insights usa Genie Code para ler o histórico de trace de agentes como Claude Code e Codex e devolver um relatório priorizado de onde o token está sendo desperdiçado: erro de ferramenta MCP recorrente, modelo caro em tarefa simples, fluxo repetido manualmente. Um exemplo real corrigiu sete bugs pequenos de servidor MCP e recuperou cerca de 1,2 milhão de dólares por ano."
---

Toda equipe que coloca agente de código em produção chega, mais cedo ou mais tarde, no mesmo ponto cego: o trace existe, a conta do provedor de modelo existe, mas ninguém sabe exatamente para onde o token está indo. A sessão parece bem sucedida, a tarefa foi concluída, e mesmo assim o custo sobe mês a mês sem explicação clara. O problema não é falta de dado, é falta de alguém (ou algo) que leia milhares de sessões e aponte o padrão que nenhum humano teria paciência de achar manualmente.

É esse ponto cego específico que o Unity Gateway Insights ataca. A ideia central não é nova (análise de log sempre existiu), o que muda é usar o próprio Genie Code para ler o trace à luz do seu contexto de negócio e devolver, em linguagem direta, onde está o desperdício e quanto ele custa.

## O problema que motivou a feature

O artigo oficial lista três categorias recorrentes de gasto evitável que aparecem em trace de agente: ferramenta MCP com erro recorrente, onde o agente tenta de novo ou contorna o problema e a sessão parece bem sucedida enquanto o custo sobe; tarefa simples rodando em modelo caro, quando um trabalho rotineiro não precisava do modelo de fronteira mais caro disponível; e fluxo de trabalho repetido, onde o mesmo conjunto de passos é refeito manualmente em sessão após sessão, sem nunca virar automação.

O exemplo mais concreto citado é direto: corrigir sete bugs pequenos em servidor MCP recuperou uma estimativa de 1,2 milhão de dólares por ano. Outro achado interessante vai na direção contrária da intuição de "modelo mais novo é sempre melhor": uma repetição offline mostrou que atualizar de Opus 4.8 para Opus 5 não trazia ganho de desempenho mensurável para aquele conjunto de tarefa, e a equipe decidiu manter o modelo mais barato.

## O mecanismo, antes do detalhe técnico

Para o relatório funcionar, três peças precisam estar no lugar. Primeiro, rastreamento automático: a CLI `ug` lança Claude Code, Codex ou GitHub Copilot já com rastreamento OpenTelemetry ativado, e os spans resultantes caem numa tabela Delta governada no Unity Catalog, a tabela de trace unificada. Segundo, contexto de negócio: a Genie Ontology permite que as respostas usem nome de projeto e termo de negócio da sua organização, em vez de identificador técnico sem significado. Terceiro, escala de consulta: o Databricks SQL lê o histórico completo de trace sem precisar exportar nada, e por padrão só o dono da tabela consegue consultar, até que um admin libere acesso via grant e row filter do Unity Catalog.

Com essas três peças no lugar, o Genie Code amostra sessões, agrupa em "workstreams" (tipos de trabalho), verifica cada workstream em busca das quatro categorias de desperdício, e ordena os achados pelo volume de token em jogo.

{{< figure src="report-overview.png" alt="Visão geral de um relatório do Unity Gateway Insights mostrando o gráfico de workstreams comparando participação de sessões com participação de tokens, e a lista de categorias de desperdício ordenadas por custo" caption="A primeira tela de um relatório do Unity Gateway Insights: quais tipos de trabalho consomem mais token do que sua fatia de sessões sugeriria, e onde o desperdício está concentrado." >}}

## Mão na massa: gerando e lendo um relatório

Gerar um relatório é um fluxo direto dentro do workspace: abrir **AI Gateway**, clicar em **Observability**, entrar em **Insights**, escolher a janela de tempo (último dia, últimos 7 ou últimos 30 dias), selecionar um SQL warehouse e clicar em **Generate report**. O relatório leva de 15 a 20 minutos para ficar pronto, e é possível gerar mais de um ao mesmo tempo.

O relatório final abre com números chave de token e sessão, seguido por um cabeçalho para cada pergunta embutida (contexto inchado, modelo sobredimensionado, gasto desperdiçado em MCP, chamada MCP com falha), além de até dez perguntas personalizadas que você mesmo inclui antes de gerar. Cada achado traz evidência: links diretos para as sessões que sustentam aquela conclusão, e um card de pergunta de acompanhamento que abre uma conversa no Genie Code dedicada àquele ponto específico.

Para quem quer entender o tipo de consulta que alimenta esse relatório por baixo dos panos, a tabela de trace unificada guarda um span por linha, em formato OpenTelemetry, com uso de token em atributos `gen_ai.usage.*`. Um exemplo ilustrativo, escrito aqui a partir da documentação do esquema e não copiado de nenhum relatório real, de como se aproximaria uma pergunta de "right-sizing" de modelo:

```sql
-- Ilustrativo: sessões que usaram modelo de fronteira (alto custo)
-- para chamadas de baixa complexidade (poucos tokens de saída),
-- candidatas a roteamento para modelo mais barato
SELECT
  attributes:['enduser.id']::string AS requester,
  attributes:`gen_ai.usage.output_tokens`::bigint AS tokens_saida,
  service_name
FROM main.observability.unity_gateway_otel_spans
WHERE name = 'anthropic.messages.create'
  AND kind = 'SPAN_KIND_CLIENT'
  AND service_name LIKE '%frontier%'
  AND attributes:`gen_ai.usage.output_tokens`::bigint < 200
ORDER BY tokens_saida ASC;
```

**Minha leitura:** o detalhe que separa essa feature de um dashboard de custo comum é o acoplamento com a Genie Ontology. Um relatório que diz "workstream X consome 35% do token com 10% das sessões" já é útil, mas um relatório que traduz isso para o nome do projeto de negócio certo, e sugere um prompt de skill reutilizável pronto para copiar, reduz a distância entre "identificar o problema" e "alguém realmente resolver o problema" de dias para minutos. O risco embutido é o oposto: se a ontologia estiver mal curada, o relatório erra a atribuição de custo para o time errado, e isso é pior do que não ter relatório nenhum, porque gera confiança falsa.

## O que isso não resolve

O Insights não corrige nada automaticamente, ele aponta. A correção do servidor MCP com bug, a decisão de trocar de modelo, a conversão de um fluxo manual repetido em skill, tudo isso continua dependendo de alguém agir sobre o achado. A feature também está em Beta e depende da tabela de trace unificada, que por sua vez depende do recurso em beta **Enhanced Unity Gateway** estar habilitado pelo admin da conta, então não é algo que simplesmente aparece pronto no seu workspace.

Vale notar também a questão de governança de acesso: por padrão, só quem gerou o relatório pode vê-lo ou excluí-lo, e só o dono da tabela de trace consegue consultar os dados brutos até que acesso seja concedido via Unity Catalog, de preferência com política de row filter (ABAC) para que cada time veja só o próprio tráfego. Sem esse cuidado de governança configurado com antecedência, abrir o Insights para muita gente pode significar expor prompt e resposta de outros times sem necessidade.

## Vale a pena adotar?

Vale, principalmente para quem já rodou agente de código por tempo suficiente para acumular trace real, mas ainda decide o que otimizar no feeling em vez de no dado. **Minha leitura final:** o maior ganho aqui não é a economia pontual de um caso como o dos sete bugs de MCP, é a mudança de hábito que isso induz, transformar "vamos revisar custo de agente" de uma tarefa manual trimestral em algo que roda sob demanda em minutos. Isso só vale a pena, porém, se a governança de acesso ao trace for configurada com o mesmo cuidado que se dá a qualquer outro dado sensível de uso interno.

## Referências

- Databricks Blog, "Introducing Unity Gateway Insights": https://www.databricks.com/blog/introducing-unity-gateway-insights
- Microsoft Learn, "Analyze agent usage with Insights - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/ai-gateway/insights
- Microsoft Learn, "Monitor all AI activity using the unified trace table - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/ai-gateway/unified-trace-table
- Microsoft Learn, "ug CLI reference - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/ai-gateway/coding-agent-ug-cli
- Microsoft Learn, "Genie Ontology - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/genie/genie-ontology

#AzureDatabricks #UnityGateway #AgentesDeIA #FinOps
