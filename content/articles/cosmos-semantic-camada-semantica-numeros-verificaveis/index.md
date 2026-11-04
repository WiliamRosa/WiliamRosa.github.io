---
title: "Cosmos Semantic 0.1: uma camada semântica open source em que cada número traz a própria prova"
date: 2026-11-04T09:00:00-03:00
draft: false
tags: ["Camada Semântica", "Open Source", "Agentes de IA", "MCP", "Databricks", "Python"]
ShowToc: true
summary: "Publiquei a primeira versão do Cosmos Semantic, uma camada semântica com motor próprio, código aberto sob Apache 2.0. A ideia central não é só definir métrica uma vez: é fazer cada resposta, pra uma pessoa ou pra um agente de IA, vir com a fórmula expandida, as regras de negócio usadas, as políticas aplicadas e os hashes pra reproduzir o resultado. Validado em DuckDB, Postgres, SQL Server e Databricks."
---

Toda empresa que já tentou colocar um agente de IA pra responder pergunta de negócio esbarra no mesmo problema, e ele não é o modelo de linguagem. É que "receita" tem três definições diferentes espalhadas em três dashboards, "cliente ativo" significa 60 dias pra um time e 90 pra outro, e ninguém consegue dizer de onde saiu o número que o agente respondeu. Uma camada semântica resolve a primeira parte: define métrica, dimensão e relacionamento uma vez e serve o mesmo resultado pra todo mundo. A segunda parte, provar o número, quase ninguém resolve.

Foi pra atacar as duas que eu construí o **Cosmos Semantic**, e hoje sai a versão 0.1, open source sob Apache 2.0: [github.com/WiliamRosa/cosmos-semantic-platform](https://github.com/WiliamRosa/cosmos-semantic-platform).

## O que ele é, em uma frase

Você define entidades, métricas, conceitos e regras de negócio uma vez, num YAML com o vocabulário do dbt Semantic Layer, e qualquer agente de IA ou aplicação consulta o mesmo número, com o SQL gerado e executado direto na sua fonte de dados. O motor é próprio: não é uma camada em cima do Cube nem do MetricFlow. Cube, dbt, Apache Ossie e Power BI entram como formatos que ele importa, não como dependências.

## O diferencial: números verificáveis

A maioria das camadas semânticas para no "a métrica está definida em um lugar só". Aqui, toda resposta vem com um envelope de evidências:

```text
evidence  q_2eae279c2b6b494da485
  model   edb8d14a70cd1e35  engine 0.1.0
  as of   2026-11-04 (America/New_York)  source local (duckdb)
  metric  revenue = SUM(orders.amount)
  lineage orders
  sql     eb5ca2c843244937  result 451c5e52d6f85089 (3 rows)
```

Esse envelope diz a fórmula expandida da métrica, quais regras de negócio entraram (com dono, data de vigência e status dos testes), quais filtros de linha foram aplicados pro usuário, de qual fonte veio, qual era a data de referência ("hoje" é fixado no fuso do modelo, não no relógio de cada servidor) e os hashes do modelo, do SQL e do resultado. Com isso dá pra rodar `cosmos replay` meses depois e saber se o número mudou porque o dado mudou, porque o modelo mudou ou porque o motor mudou.

Em cima dessas mesmas evidências vêm três ferramentas que considero o coração do projeto:

- **Reconciliação** (`cosmos reconcile`): compara a métrica governada com o SQL legado que alguém já usa e diz a causa provável da divergência. Filtro diferente, multiplicação de linhas em join, divisão inteira, média de inteiro truncada, corte de dia em UTC em vez do fuso de negócio. Testei contra um "zoológico" de nove erros clássicos plantados de propósito, mais uma consulta legada correta como controle, que tem que dar "sem divergência".
- **Análise de impacto** (`cosmos impact`): antes de mudar uma regra ou métrica, mostra tudo que depende dela, quem é o dono de cada parte e quem consultou aquilo segundo o log de auditoria.
- **Regras com histórico**: quando "cliente ativo" passou de 60 pra 90 dias, a regra guarda as duas versões. Uma consulta de junho usa a regra que valia em junho, a menos que você peça explicitamente a regra de hoje. A diferença entre as duas é exatamente o efeito da mudança.

## Feito pra agente de IA desde o primeiro dia

O servidor MCP expõe cinco ferramentas (`search_concepts`, `explain`, `list_members`, `query` e `show_sql`). O glossário tem rótulos e sinônimos em português e inglês, então o agente acha o conceito certo a partir da pergunta do usuário: "compradores ativos" chega em `active_customer`, que é uma regra de negócio com dono e teste.

Duas garantias valem pra todo canal, e foram as primeiras coisas que eu quis travar:

1. **Filtro de linha pelo usuário.** O contexto do usuário vem do token do provedor de identidade (Entra ID primeiro) e entra no SQL. O agente de um gerente regional só vê a região dele.
2. **Dado pessoal nunca chega no agente.** Colunas classificadas como pessoais ou sensíveis (pensando em LGPD) não podem ser agrupadas nem filtradas pelo canal MCP:

```text
error: `customers.email` is personal data (LGPD) and never reaches AI agents,
neither as a grouping nor as a filter
```

## Mão na massa: do pip ao primeiro número

Tudo roda localmente em DuckDB, sem servidor e sem conta:

```bash
pip install "cosmos-semantic[duckdb,testdata]"
cosmos init demo && cd demo
cosmos demo-data
cosmos query revenue average_order_value --by orders.status --evidence
cosmos explain rule:active_customer
```

O `cosmos init` cria um projeto com o modelo de exemplo (um e-commerce com pedidos, itens, pagamentos, clientes, produtos e vendedores) e o `cosmos demo-data` gera dados sintéticos. Pra ligar um agente, o mesmo projeto já vem com uma chave de desenvolvimento, e no Claude Code basta um `claude mcp add`; o passo a passo completo está no [quickstart](https://github.com/WiliamRosa/cosmos-semantic-platform/blob/main/docs/quickstart.md).

## E no Databricks?

Esse era o teste que mais me importava, porque é onde está boa parte do público e também o concorrente mais direto (Metric Views e Genie). A suíte inteira roda contra DuckDB, Postgres, SQL Server e Databricks: as consultas de referência comparadas com SQL escrito à mão, 80 requisições aleatórias que precisam dar exatamente o mesmo número nos quatro bancos, reconciliação, importação do Power BI e o restante. No Databricks rodei num SQL Warehouse serverless com Unity Catalog.

A validação pegou três problemas, e vale contar porque são o tipo de coisa que só aparece em banco real. O mais interessante: o `information_schema` do Databricks informa inteiros como `LONG`, e não como `BIGINT`, então o recurso que monta um rascunho de modelo a partir do catálogo tratava `quantity` como texto. O SQL que o motor gera não precisou de nenhuma correção. É pra isso que esses testes existem: o mesmo número em todo banco não é promessa de documentação, é um teste que roda a cada mudança.

## O que mais vem na 0.1

- Importação de modelos do **Power BI** (`.bim` e TMDL), traduzindo o DAX simples em métricas e avisando tudo que não tem equivalente, em vez de perder em silêncio.
- **Rascunho de modelo a partir do banco** (`cosmos bootstrap`), sem IA, e **sugestões com IA** (`cosmos suggest`) que o motor valida e que nunca são aplicadas sem revisão.
- **Grafo de conhecimento** com times, sistemas e processos, e um relatório de **uso e custo por métrica e por agente**.
- **Exportação do glossário em SKOS/RDF** pra catálogos de dados.
- Um **pacote de varejo** que se adapta às tabelas de quem usa, por nome e sinônimo.

## O que ainda não tem

É uma versão 0.1, e prefiro ser direto sobre o que falta: não há cache de resultado, nem endpoint SQL pra conectar Power BI e Excel diretamente (isso está pausado de propósito até ter usuários dizendo que vale o esforço), nem produto gerenciado. O formato de autoria pode mudar antes da 1.0, sempre registrado no changelog.

## Como ajudar

Se você trabalha com dados e já brigou com número divergente, eu adoraria que testasse com um modelo seu, nem que seja importando um projeto dbt ou um modelo do Power BI pra ver se os números batem. Issue, crítica e pull request são muito bem-vindos no [repositório](https://github.com/WiliamRosa/cosmos-semantic-platform). E se quiser conversar sobre o projeto, me chama no Linkedin.
