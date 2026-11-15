---
title: "Uma constraint que ninguém valida, mas o otimizador leva a sério: UNIQUE com RELY no Azure Databricks"
date: 2026-11-04T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Unity Catalog", "SQL", "Performance"]
ShowToc: true
summary: "UNIQUE chegou em Public Preview no Azure Databricks como mais uma constraint informacional, que não é validada contra dado existente nem imposta em escrita futura. A parte que importa é o que acontece quando ela é declarada com RELY: eliminação de join e remoção de DISTINCT que, num benchmark TPC-DS de 10 TB, cortaram mais de 99,99% do shuffle e chegaram a 12 vezes mais rápido, com o Catalog Explorer agora desenhando esse relacionamento num diagrama visual."
---

Toda tabela real tem mais de uma garantia de unicidade, mas o Azure Databricks só deixava declarar uma: a chave primária. Uma tabela de usuário típica tem `user_id` como identificador principal, mas também tem nome de usuário único, e-mail único, e às vezes um par composto como `(workspace_id, external_user_id)` que também não pode repetir. Sem um jeito de declarar isso no esquema, nem ferramenta nem otimizador de consulta sabem que essas garantias existem.

A constraint `UNIQUE`, agora em Public Preview no Databricks SQL e no Databricks Runtime 18.2 e superior, para tabela Unity Catalog e Delta Lake, resolve a parte de declaração. A parte interessante, que vale todo o artigo, é o que ela destrava quando combinada com a palavra-chave `RELY`.

## O mecanismo: informacional primeiro, otimização depois

O Azure Databricks trata `PRIMARY KEY`, `FOREIGN KEY` e `UNIQUE` como constraints informacionais. Isso quer dizer que elas não são impostas na escrita: inserir um valor duplicado numa coluna com `UNIQUE` declarado não falha a transação. A diferença entre `PRIMARY KEY` e `UNIQUE` é que a chave primária é única por tabela e suas colunas são implicitamente `NOT NULL`, enquanto `UNIQUE` permite várias por tabela e aceita coluna anulável, com a semântica de que valor `NULL` é tratado como distinto de outro `NULL` (ou seja, duas linhas com `NULL` na mesma coluna `UNIQUE` não violam a constraint).

Por padrão, toda constraint informacional nasce com `NORELY`. Isso significa "estou documentando essa garantia, mas não autorizo o otimizador a confiar nela pra reescrever consulta". Pra destravar a otimização, é preciso recriar a constraint explicitamente com `RELY`.

A versão mínima de runtime pra usar `RELY` varia por tipo de constraint, e isso importa pra quem ainda não atualizou todos os workspaces: chave primária exige Databricks Runtime 14.2 ou superior, chave estrangeira exige 15.4 ou superior, e `UNIQUE` exige 18.2 ou superior. As três só funcionam em tabela do Unity Catalog, nenhuma delas é suportada no hive_metastore legado.

## Mão na massa: declarando e promovendo pra RELY

A sintaxe de criação de tabela aceita a constraint direto:

```sql
CREATE OR REPLACE TABLE main.default.usuarios (
  id INTEGER NOT NULL,
  email STRING NOT NULL,
  CONSTRAINT usuarios_uq_email UNIQUE(email)
);
```

Ou adicionada depois, numa tabela que já existe:

```sql
ALTER TABLE main.default.usuarios
  ADD CONSTRAINT usuarios_uq_email UNIQUE(email);
```

Statement `CREATE TABLE AS SELECT` (CTAS) não aceita cláusula de constraint, então em pipeline que recria tabela via CTAS a constraint precisa ser adicionada num passo `ALTER` separado depois.

Uma chave estrangeira pode referenciar uma constraint `UNIQUE`, não só a chave primária, bastando nomear a coluna explicitamente:

```sql
ALTER TABLE main.default.pedidos
  ADD CONSTRAINT pedidos_usuario_fk
  FOREIGN KEY (email_usuario)
  REFERENCES main.default.usuarios (email);
```

Duas regras de validação valem a pena conhecer antes de desenhar o esquema. Primeiro, o tipo de dado de cada coluna filha precisa casar com o tipo da coluna pai correspondente, e se a lista de coluna pai for omitida, o Azure Databricks assume a ordem de declaração da chave primária da tabela pai, não a ordem alfabética nem a ordem física da tabela. Segundo, duas chaves estrangeiras não podem compartilhar exatamente o mesmo conjunto de colunas, e duas chaves que diferem só na ordem de permutação das mesmas colunas também não são permitidas.

A gramática completa do bloco de constraint aceita `RELY` ou `NORELY` como opção, junto de `NOT ENFORCED`, `DEFERRABLE` e `INITIALLY DEFERRED` (essa última dupla existe por compatibilidade com dialeto SQL não padrão, junto de `ENABLE NOVALIDATE` como atalho equivalente). É possível declarar as duas coisas juntas numa única instrução, como no próprio exemplo da documentação oficial pra chave estrangeira:

```sql
ALTER TABLE main.default.pedidos
  ADD CONSTRAINT pedidos_usuario_fk
  FOREIGN KEY (email_usuario)
  REFERENCES main.default.usuarios (email)
  NOT ENFORCED RELY;
```

A sintaxe de chave primária também aceita um qualificador `TIMESERIES` numa das colunas (`PRIMARY KEY (coluna TIMESERIES)`, disponível desde o Databricks Runtime 13.3 LTS), mas a documentação oficial só diz que ele "rotula opcionalmente o componente de chave primária como representando uma série temporal", sem detalhar o efeito prático disso no otimizador ou em qualquer outra parte do sistema. Eu trataria isso como metadado declarativo por enquanto, não como algo que já mude comportamento de consulta de forma documentada.

**Na prática:** eu trataria a promoção pra `RELY` como uma etapa de rollout separada da declaração inicial, nunca simultânea. Declare `NORELY` primeiro, valide o dado real contra a garantia por um tempo, e só promova pra `RELY` quando tiver confiança de que nenhum pipeline downstream vai inserir duplicata. Fazer as duas coisas no mesmo deploy é apostar que a validação manual que você fez uma vez vai continuar válida pra sempre.

## Removendo sem quebrar nada: RESTRICT trava, CASCADE arrasta

Apagar uma constraint que outra depende dela tem duas rotas opostas, e vale saber qual é o padrão antes de rodar isso num workspace de produção. `DROP CONSTRAINT` (ou `DROP PRIMARY KEY`, ou `DROP FOREIGN KEY` listando as colunas) aceita `RESTRICT` ou `CASCADE`, com `RESTRICT` sendo o comportamento padrão quando nenhum dos dois é informado.

```sql
-- Numa tabela "persons" com chave primária, e "pets" com chave estrangeira
-- apontando pra ela, tentar apagar a chave primária sem CASCADE falha:
ALTER TABLE persons DROP CONSTRAINT persons_pk RESTRICT;
-- Error: A foreign key `pets_persons_fk` depends on the primary key

-- CASCADE apaga a chave primária e qualquer chave estrangeira dependente junto
ALTER TABLE persons DROP PRIMARY KEY CASCADE;

-- Pra apagar só a chave estrangeira de "pets", por lista de coluna,
-- sem precisar saber o nome dela
ALTER TABLE pets DROP FOREIGN KEY IF EXISTS (owner_first_name, owner_last_name);
```

`CHECK` e `UNIQUE` só podem ser apagadas pelo nome da constraint. Chave estrangeira pode ser apagada pela lista de coluna, sem precisar do nome. E `IF EXISTS` torna a instrução um no-op caso a constraint já não exista, o que ajuda a manter script de migração idempotente.

**Minha leitura:** esse comportamento de `CASCADE` apagar chave estrangeira dependente sem perguntar nada é conveniente, mas perigoso dentro de pipeline automatizado que roda `DROP CONSTRAINT` como parte de um deploy. Eu sempre deixaria `RESTRICT` (o padrão) no script automatizado, deixaria a operação falhar quando houver dependente, e trataria esse erro como sinal pra revisão manual, não como obstáculo pra sufocar com `CASCADE` automático.

## Visualizando o relacionamento: o Entity Relationship Diagram do Catalog Explorer

Declarar a constraint não serve só o otimizador. Desde que uma tabela tenha uma chave estrangeira declarada, o Catalog Explorer mostra um ícone de chave primária e de chave estrangeira ao lado da coluna correspondente no esquema da tabela.

{{< figure src="schema-tabela-pills-pk-fk.png" alt="Captura de tela do esquema de uma tabela no Catalog Explorer mostrando ícones de chave primária e chave estrangeira ao lado dos nomes de coluna" caption="No esquema da tabela, colunas com constraint declarada ganham um ícone visual de chave primária ou chave estrangeira." >}}

A partir daí, clicando em "View relationships" na aba de visão geral da tabela, o Catalog Explorer abre o Entity Relationship Diagram (ERD): um grafo mostrando como as tabelas do catálogo se conectam via chave primária e chave estrangeira declaradas.

{{< figure src="diagrama-relacionamento-pk-fk-catalog-explorer.png" alt="Entity Relationship Diagram no Catalog Explorer mostrando tabelas conectadas por linha representando chave primária e chave estrangeira declaradas entre elas" caption="O ERD do Catalog Explorer desenha o relacionamento declarado entre tabelas, aqui usando o dataset de exemplo Wanderbricks." >}}

Vale notar a distinção que a própria documentação faz: o ERD mostra relacionamento declarado via constraint, não relacionamento real de uso. Pra ver como as tabelas se conectam de fato no fluxo de consulta (join que efetivamente aconteceu em produção, independente de constraint declarada ou não), a ferramenta certa é o grafo de lineage do Catalog Explorer, não o ERD.

## Os dois ganhos reais: eliminação de join e remoção de DISTINCT

Com `RELY` ativo e compute habilitado com Photon, o otimizador passa a usar a garantia de duas formas. A primeira é **remoção de agregação `DISTINCT`**: se a coluna selecionada está coberta por uma constraint `UNIQUE` ou `PRIMARY KEY` com `RELY`, a agregação inteira é removida do plano, porque o resultado já é garantidamente distinto.

```sql
-- Antes: o otimizador não sabe, por padrão, que c_customer_sk é único
SELECT DISTINCT c_customer_sk FROM customer;

-- Com PRIMARY KEY ou UNIQUE em RELY sobre c_customer_sk,
-- o otimizador reescreve pra isso, porque o DISTINCT já não faz nada:
SELECT c_customer_sk FROM customer;
```

A segunda é **eliminação de join**. O exemplo oficial usa `store_sales` com `LEFT JOIN` pra `customer`, onde `customer.c_customer_sk` é chave primária com `RELY`:

```sql
-- Antes: parece que o join é necessário pra garantir o resultado certo
SELECT SUM(ss_quantity)
FROM store_sales ss
LEFT JOIN customer c ON ss.customer_sk = c.c_customer_sk;

-- Depois: o otimizador elimina o LEFT JOIN inteiro
SELECT SUM(ss_quantity) FROM store_sales ss;
```

A lógica por trás da eliminação: como `c_customer_sk` é chave primária (no máximo uma correspondência por valor), cada linha de `store_sales` casa com, no máximo, uma linha de `customer`. Como é `LEFT JOIN`, toda linha de `store_sales` sobrevive de qualquer forma, exista ou não correspondência em `customer`. O resultado da soma não muda com ou sem o join, então o otimizador corta ele inteiro.

O benchmark publicado usa TPC-DS na escala SF10000 (10 TB), com Photon. No teste de eliminação de join, `store_sales` (28,8 bilhões de linhas) junta com `customer` (65 milhões de linhas), com `UNIQUE` em `customer.c_customer_sk` e chave estrangeira em `store_sales.ss_customer_sk`, ambas `RELY`. O resultado eliminou mais de 99,99% do shuffle e o tempo mediano de execução caiu de 23,6 segundos pra 3,0 segundos, um ganho de 7,9 vezes. No teste de remoção de `DISTINCT`, com `UNIQUE` sobre o par `(ss_item_sk, ss_ticket_number)` em `store_sales`, o shuffle também caiu mais de 99,99%, e o tempo mediano foi de 33,7 segundos pra 2,8 segundos, 12 vezes mais rápido.

## O que isso não resolve

A documentação é direta sobre o risco, com uma frase que vale repetir: "é responsabilidade do usuário garantir que a constraint realmente vale". O otimizador não confere nada na hora de usar a garantia, só confia que `RELY` significa o que deveria significar. Se o dado de fato violar a constraint, uma reescrita de consulta baseada numa garantia falsa pode produzir resultado incorreto, sem nenhum erro visível avisando, e isso continua valendo depois que `RELY` foi ativado: nada impede duplicata de entrar de novo, então manter a garantia válida é responsabilidade contínua do pipeline que escreve na tabela, não um cheque único feito na hora da promoção.

A documentação sugere validar duplicata com `GROUP BY` sobre as colunas da constraint (adicionando `IS NOT NULL` pra coluna anulável) e órfão de chave estrangeira com um left anti join, além de confirmar a declaração via `SHOW CREATE TABLE`, `DESCRIBE TABLE EXTENDED` ou as views do `information_schema` (`TABLE_CONSTRAINTS`, `KEY_COLUMN_USAGE`, `CONSTRAINT_TABLE_USAGE`, `CONSTRAINT_COLUMN_USAGE`, `REFERENTIAL_CONSTRAINTS`), e checar o plano final com `EXPLAIN`.

Chave primária e chave estrangeira também podem ser declaradas numa materialized view, não só numa tabela normal, mas a documentação não confirma o mesmo suporte pra `UNIQUE` sobre materialized view, e não menciona nada sobre tabela de streaming. Eu não assumiria suporte pra `UNIQUE` em materialized view sem testar antes num workspace que não seja produção.

**Minha ressalva:** a otimização descrita aqui exige Photon, e a documentação é específica sobre o tipo de compute do Azure Databricks que destrava isso: SQL warehouse serverless ou pro, ou compute serverless. Quem roda em compute clássico sem Photon habilitado, ou em SQL warehouse clássico, não vai ver nenhum dos dois ganhos, mesmo declarando tudo corretamente com `RELY`. Vale confirmar isso antes de prometer o número do benchmark pra alguém no time, porque o ganho de 7,9x a 12x é real, mas é condicionado a um tipo de compute específico que nem todo workspace Azure Databricks usa por padrão.

## Vale adotar?

Sim, pra quem já tem relação de chave bem definida entre tabela de fato e tabela de dimensão num modelo analítico, especialmente em tabela de fato muito grande (bilhões de linha) juntando com dimensão relativamente pequena, que é exatamente o padrão onde eliminação de join rende mais. O custo de adoção é baixo (é só uma declaração de esquema), mas o processo de validação antes de promover pra `RELY` não deve ser pulado, porque o preço de uma garantia falsa é resultado incorreto silencioso, não um erro que alguém nota a tempo. E mesmo que o workspace ainda não tenha Photon habilitado em todo lugar, vale declarar a constraint desde já: o ganho de documentação e o diagrama visual no Catalog Explorer já compensam, e a otimização de consulta vem de brinde no dia em que o compute certo entrar em cena.

## Referências

- Databricks Blog, "Declare and optimize with UNIQUE constraints on Databricks": https://www.databricks.com/blog/declare-and-optimize-unique-constraints-databricks
- Microsoft Learn, "Constraints on Databricks - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/tables/constraints
- Databricks Docs (AWS), "Constraints on Databricks": https://docs.databricks.com/aws/en/tables/constraints
- Databricks Docs (AWS), "CREATE TABLE constraint clause": https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-table-constraint
- Microsoft Learn, "ALTER TABLE ADD CONSTRAINT clause - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-alter-table-add-constraint
- Microsoft Learn, "ALTER TABLE DROP CONSTRAINT clause - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/sql-ref-syntax-ddl-alter-table-drop-constraint
- Microsoft Learn, "Optimize queries with constraints - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/sql/user/queries/query-optimization-constraints
- Microsoft Learn, "View the Entity Relationship Diagram - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/catalog-explorer/entity-relationship-diagram

#AzureDatabricks #UnityCatalog #SQL #Performance
