---
title: "Cosmos Semantic 0.1: uma camada semântica open source em que cada número traz a própria prova"
date: 2026-11-04T09:00:00-03:00
draft: false
tags: ["Camada Semântica", "Open Source", "Agentes de IA", "MCP", "Governança de Dados", "Databricks", "Snowflake", "Python"]
ShowToc: true
summary: "Publiquei a primeira versão do Cosmos Semantic, uma camada semântica com motor próprio, código aberto sob Apache 2.0. A ideia central não é só definir métrica uma vez: é fazer cada resposta, pra uma pessoa ou pra um agente de IA, vir com a fórmula expandida, as regras de negócio usadas, as políticas aplicadas e os hashes pra reproduzir o resultado. A 0.1 foi validada em DuckDB, Postgres, SQL Server e Databricks; a 0.2, já no PyPI, soma Snowflake, MySQL, MariaDB e Oracle."
---

Toda empresa que já tentou colocar um agente de IA pra responder pergunta de negócio esbarra no mesmo problema, e ele não é o modelo de linguagem. É que "receita" tem três definições diferentes espalhadas em três dashboards, "cliente ativo" significa 60 dias pra um time e 90 pra outro, e ninguém consegue dizer de onde saiu o número que o agente respondeu. Uma camada semântica resolve a primeira parte: define métrica, dimensão e relacionamento uma vez e serve o mesmo resultado pra todo mundo. A segunda parte, provar o número, quase ninguém resolve.

Foi pra atacar as duas que eu construí o **Cosmos Semantic**, e hoje sai a versão 0.1, open source sob Apache 2.0: [github.com/WiliamRosa/cosmos-semantic-platform](https://github.com/WiliamRosa/cosmos-semantic-platform).

## O que ele é, em uma frase

Você define entidades, métricas, conceitos e regras de negócio uma vez, num YAML com o vocabulário do dbt Semantic Layer, e qualquer agente de IA ou aplicação consulta o mesmo número, com o SQL gerado e executado direto na sua fonte de dados. O motor é próprio: não é uma camada em cima do Cube nem do MetricFlow. Cube, dbt, Apache Ossie e Power BI entram como formatos que ele importa, não como dependências.

## Por que isso importa pra quem lidera dados e IA

Antes de entrar no técnico, vale separar o que muda pra quem responde pelo resultado, e não só pela implementação. Quando um agente de IA começa a responder pergunta de negócio, a pergunta que chega na mesa de quem lidera dados deixa de ser "funciona?" e passa a ser "posso confiar, e consigo provar?". É nessa pergunta que o projeto foca:

- **Confiança auditável, não confiança declarada.** Cada número sai com a fórmula, as regras de negócio, as políticas de acesso aplicadas e a data de referência. Quando a diretoria contestar um número do agente, a resposta é um registro que dá pra reproduzir, e não uma investigação de dois dias.
- **Risco e compliance.** Filtro de linha pelo usuário vindo do provedor de identidade, dado pessoal bloqueado pro canal de IA (pensando em LGPD) e log de auditoria de toda consulta. A governança fica no motor, não na boa vontade de cada prompt.
- **Mudança com dono e com histórico.** Toda regra tem dono, data de vigência e versões anteriores. Antes de mudar uma definição, dá pra ver quem será afetado; depois de mudar, dá pra medir o efeito.
- **Migração sem números divergentes.** Quem está levando relatório de SQL Server ou Oracle pro Databricks ou pro Snowflake pode comparar a métrica governada com o SQL legado e ver a causa provável de cada diferença, antes de desligar o relatório antigo.
- **Custo visível.** Um relatório de uso e custo estimado por métrica e por agente mostra quem está consultando o quê, e quanto isso custa no warehouse.
- **Sem aprisionamento.** Apache 2.0, motor próprio, o mesmo modelo rodando em bancos diferentes, e importação do que a empresa já tem (dbt, Power BI, Cube, Ossie). Trocar de plataforma não obriga a reescrever as definições de negócio.

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

Esse envelope traz a fórmula expandida da métrica e quais regras de negócio entraram, com dono, data de vigência e status dos testes. Mostra também quais filtros de linha foram aplicados pro usuário e de qual fonte o número veio. Registra a data de referência: "hoje" é fixado no fuso do modelo, não no relógio de cada servidor. Por fim, guarda os hashes do modelo, do SQL e do resultado. Com isso dá pra rodar `cosmos replay` meses depois e saber se o número mudou porque o dado mudou, porque o modelo mudou ou porque o motor mudou.

Em cima dessas mesmas evidências vêm três ferramentas que considero o coração do projeto:

- **Reconciliação** (`cosmos reconcile`): compara a métrica governada com o SQL legado que alguém já usa e diz a causa provável da divergência, como:
  - filtro diferente;
  - multiplicação de linhas em join;
  - divisão inteira ou média de inteiro truncada;
  - corte de dia em UTC em vez do fuso de negócio.

  Testei contra um "zoológico" de nove erros clássicos plantados de propósito. Ele tem ainda uma consulta legada correta como controle, que tem que dar "sem divergência".
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

### A IA sugere, o motor valida

O `cosmos suggest` usa o Claude pra propor sinônimos, descrições e regras de negócio a partir do modelo. Nada é aplicado automaticamente: toda sugestão passa pelo validador do motor e vai pra revisão de uma pessoa. Na primeira rodada contra a API real, ele aceitou umas 28 sugestões em cerca de 30 segundos, quase todas boas. Também propôs um sinônimo errado em português ("inadimplência" pra "collection gap"), que é exatamente o motivo da revisão humana.

O resultado mais útil, porém, foi outro. Uma regra sugerida combinava uma métrica booleana com outra condição, e isso expôs um bug de precedência no motor: uma expressão substituída perdia os parênteses e mudava de sentido sem dar erro. Os testes escritos à mão não pegaram esse caso, e a sugestão da IA pegou. O bug foi corrigido e virou teste de regressão. Pra mim é o modelo certo de IA em dados: ela amplia o que dá pra testar, mas não tem a palavra final.

## Mão na massa: do pip ao primeiro número

Tudo roda localmente em DuckDB, sem servidor e sem conta:

```bash
pip install "cosmos-semantic[duckdb,testdata]"
cosmos init demo && cd demo
cosmos demo-data
cosmos query revenue average_order_value --by orders.status --evidence
cosmos explain rule:active_customer
```

O `cosmos init` cria um projeto com o modelo de exemplo (um e-commerce com pedidos, itens, pagamentos, clientes, produtos e vendedores) e o `cosmos demo-data` gera dados sintéticos. Pra ligar um agente, o mesmo projeto já vem com uma chave de desenvolvimento, e no Claude Code basta um `claude mcp add`. O passo a passo completo está no [quickstart](https://github.com/WiliamRosa/cosmos-semantic-platform/blob/main/docs/quickstart.md).

## Em quais bancos roda

Esse era o teste que mais me importava. A promessa de "o mesmo número em todo lugar" só vale se for verificada em banco real, a cada mudança. A suíte inteira roda contra cada fonte:

- as consultas de referência, comparadas com SQL escrito à mão;
- 80 requisições aleatórias que precisam dar exatamente o mesmo número em todos os bancos;
- a reconciliação, o rascunho de modelo, a importação do Power BI e o restante.

A 0.1 foi validada em **DuckDB, Postgres, SQL Server e Databricks** (SQL Warehouse serverless com Unity Catalog). Databricks era o teste mais importante, porque é onde está boa parte do público e também o concorrente mais direto, com Metric Views e Genie. A validação pegou três problemas. O mais interessante: o `information_schema` do Databricks informa inteiros como `LONG`, e não como `BIGINT`, então o rascunho de modelo tratava `quantity` como texto. O SQL que o motor gera não precisou de nenhuma correção.

Desde o lançamento, a mesma suíte passou a rodar em mais quatro bancos, que chegaram na versão 0.2 (`pip install "cosmos-semantic[snowflake,mysql,oracle]"`):

- **Snowflake**;
- **MySQL** e **MariaDB**;
- **Oracle Database 23ai Free**.

São oito bancos no total; os seis que rodam em contêiner são testados a cada pull request. Cada banco novo trouxe sua própria pegadinha, e várias mudariam o número em silêncio:

- **Snowflake** devolve os nomes de coluna em maiúsculas e divide inteiros com casas decimais. Além disso, o primeiro dia da semana depende de um parâmetro de sessão.
- **MySQL e MariaDB** não têm `DATE_TRUNC`. A tradução automática de "semana" que a biblioteca de SQL gera nem começa na segunda-feira.
- **Oracle** foi o mais instrutivo. O `CURRENT_DATE` dele vem com a hora do dia, o que muda a contagem de "últimos 90 dias" dependendo de quando a consulta roda. E o `DOUBLE PRECISION` é, na verdade, um decimal: dois pedidos com o mesmo valor líquido calculado por caminhos diferentes caíam no mesmo grupo no Oracle e em grupos separados nos outros bancos.

Nenhuma dessas diferenças aparece em demo. Aparecem quando a mesma pergunta precisa dar o mesmo número em bancos diferentes. Pra empresa que tem dado espalhado em mais de uma plataforma, que é quase toda empresa, essa é a garantia que importa.

## O que mais vem na 0.1

- Importação de modelos do **Power BI** (`.bim` e TMDL), traduzindo o DAX simples em métricas e avisando tudo que não tem equivalente, em vez de perder em silêncio.
- **Rascunho de modelo a partir do banco** (`cosmos bootstrap`), sem IA, em poucos segundos até a primeira consulta.
- **Grafo de conhecimento** com times, sistemas e processos, e um relatório de **uso e custo por métrica e por agente**.
- **Exportação do glossário em SKOS/RDF** pra catálogos de dados.
- Um **pacote de varejo** que se adapta às tabelas de quem usa, por nome e sinônimo.

## O que ainda não tem

É uma versão 0.1, e prefiro ser direto sobre o que falta:

- não há cache de resultado;
- não há endpoint SQL pra conectar Power BI e Excel diretamente. Isso está pausado de propósito até ter usuários dizendo que vale o esforço;
- não há produto gerenciado;
- na 0.2, o validador de sugestões da IA checa o SQL em um banco só, e as regras derivadas são compiladas, mas não executadas. As duas lacunas já estão corrigidas no repositório e entram na próxima versão.

O formato de autoria pode mudar antes da 1.0, sempre registrado no changelog.

## Como avaliar na sua empresa

Se você lidera um time de dados e quer saber se isso resolve um problema real seu, um piloto pequeno basta:

1. **Escolha três métricas que geram discussão hoje**, aquelas que têm mais de um número circulando em reunião.
2. **Traga o que já existe:** importe o modelo do Power BI ou do dbt, ou gere um rascunho direto do banco com `cosmos bootstrap`.
3. **Rode a reconciliação contra o SQL legado** de cada uma e veja se as causas apontadas batem com o que o time já desconfiava.
4. **Ligue um agente pelo MCP** com um usuário de teste e confira o que ele consegue e o que não consegue ver.

Em poucas horas dá pra saber se o resultado convence o time e quem cobra o time.

## Como ajudar

Se você trabalha com dados e já brigou com número divergente, eu adoraria que testasse com um modelo seu, nem que seja importando um projeto dbt ou um modelo do Power BI pra ver se os números batem. Issue, crítica e pull request são muito bem-vindos no [repositório](https://github.com/WiliamRosa/cosmos-semantic-platform). E se quiser conversar sobre o projeto, me chama no LinkedIn.
