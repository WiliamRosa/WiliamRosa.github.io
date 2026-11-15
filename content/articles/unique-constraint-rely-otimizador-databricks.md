---
title: "Uma constraint que ninguém valida, mas o otimizador leva a sério: UNIQUE com RELY no Azure Databricks"
date: 2026-11-04T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Unity Catalog", "SQL", "Performance"]
ShowToc: true
summary: "UNIQUE chegou em Public Preview no Azure Databricks como mais uma constraint informacional, que não é validada contra dado existente nem imposta em escrita futura. A parte que importa é o que acontece quando ela é declarada com RELY: eliminação de join e remoção de DISTINCT que, num benchmark TPC-DS de 10 TB, cortaram mais de 99,99% do shuffle e chegaram a 12 vezes mais rápido."
---

Toda tabela real tem mais de uma garantia de unicidade, mas o Azure Databricks só deixava declarar uma: a chave primária. Uma tabela de usuário típica tem `user_id` como identificador principal, mas também tem nome de usuário único, e-mail único, e às vezes um par composto como `(workspace_id, external_user_id)` que também não pode repetir. Sem um jeito de declarar isso no esquema, nem ferramenta nem otimizador de consulta sabem que essas garantias existem.

A constraint `UNIQUE`, agora em Public Preview no Databricks SQL e no Databricks Runtime 18.2 e superior, para tabela Unity Catalog e Delta Lake, resolve a parte de declaração. A parte interessante, que vale todo o artigo, é o que ela destrava quando combinada com a palavra-chave `RELY`.

## O mecanismo: informacional primeiro, otimização depois

O Azure Databricks trata `PRIMARY KEY`, `FOREIGN KEY` e `UNIQUE` como constraints informacionais. Isso quer dizer que elas não são impostas na escrita: inserir um valor duplicado numa coluna com `UNIQUE` declarado não falha a transação. A diferença entre `PRIMARY KEY` e `UNIQUE` é que a chave primária é única por tabela e suas colunas são implicitamente `NOT NULL`, enquanto `UNIQUE` permite várias por tabela e aceita coluna anulável, com a semântica de que valor `NULL` é tratado como distinto de outro `NULL` (ou seja, duas linhas com `NULL` na mesma coluna `UNIQUE` não violam a constraint).

Por padrão, toda constraint informacional nasce com `NORELY`. Isso significa "estou documentando essa garantia, mas não autorizo o otimizador a confiar nela pra reescrever consulta". Pra destravar a otimização, é preciso recriar a constraint explicitamente com `RELY`.

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

A gramática completa do bloco de constraint aceita `RELY` ou `NORELY` como opção, junto de `NOT ENFORCED`, `DEFERRABLE` e `INITIALLY DEFERRED` (essa última dupla existe por compatibilidade com dialeto SQL não padrão, junto de `ENABLE NOVALIDATE` como atalho equivalente). Pra promover uma constraint existente pra `RELY`, o caminho é recriar: apagar com `DROP CONSTRAINT` (que por padrão usa `RESTRICT` e rejeita a operação se existir chave estrangeira dependente, ou `CASCADE` pra apagar as dependentes junto, que depois precisam ser recriadas) e declarar de novo com `RELY` explícito.

**Na prática:** eu trataria a promoção pra `RELY` como uma etapa de rollout separada da declaração inicial, nunca simultânea. Declare `NORELY` primeiro, valide o dado real contra a garantia por um tempo, e só promova pra `RELY` quando tiver confiança de que nenhum pipeline downstream vai inserir duplicata. Fazer as duas coisas no mesmo deploy é apostar que a validação manual que você fez uma vez vai continuar válida pra sempre.

## Os dois ganhos reais: eliminação de join e remoção de DISTINCT

Com `RELY` ativo e compute habilitado com Photon, o otimizador passa a usar a garantia de duas formas. A primeira é **eliminação de join**: um `INNER JOIN` que não traz nenhuma coluna selecionada da tabela do lado "um" pode ser removido inteiramente quando a constraint `UNIQUE` (garantindo no máximo uma correspondência) e a chave estrangeira (garantindo que existe correspondência) estão ambas com `RELY`, e a coluna filha da chave estrangeira é `NOT NULL`. Se a coluna filha for anulável, o Azure Databricks remove o join e adiciona um filtro `IS NOT NULL` na coluna filha, pra preservar a semântica. Pra `LEFT OUTER JOIN`, só a garantia de "no máximo uma correspondência" da constraint `UNIQUE` já é suficiente, nem precisa da chave estrangeira.

A segunda é **remoção de agregação `DISTINCT`**: se as colunas selecionadas estão cobertas por uma constraint `UNIQUE` com `RELY` e são `NOT NULL`, a agregação inteira é removida do plano. Pra coluna `UNIQUE` anulável, a agregação só é removida se a consulta já tiver um filtro `IS NOT NULL` explícito sobre ela.

O benchmark publicado usa TPC-DS na escala SF10000 (10 TB), com Photon. No teste de eliminação de join, `store_sales` (28,8 bilhões de linhas) junta com `customer` (65 milhões de linhas), com `UNIQUE` em `customer.c_customer_sk` e chave estrangeira em `store_sales.ss_customer_sk`, ambas `RELY`. O resultado eliminou mais de 99,99% do shuffle e o tempo mediano de execução caiu de 23,6 segundos pra 3,0 segundos, um ganho de 7,9 vezes. No teste de remoção de `DISTINCT`, com `UNIQUE` sobre o par `(ss_item_sk, ss_ticket_number)` em `store_sales`, o shuffle também caiu mais de 99,99%, e o tempo mediano foi de 33,7 segundos pra 2,8 segundos, 12 vezes mais rápido.

## O que isso não resolve

A documentação é direta sobre o risco: `RELY` é inseguro se o dado de fato violar a constraint, porque uma reescrita de consulta baseada numa garantia falsa pode produzir resultado incorreto, sem nenhum erro visível avisando. A constraint não impede duplicata entrar depois que `RELY` foi ativado, então manter a garantia válida é responsabilidade contínua do pipeline que escreve na tabela, não um cheque único feito na hora da promoção.

A documentação sugere validar duplicata com `GROUP BY` sobre as colunas da constraint (adicionando `IS NOT NULL` pra coluna anulável) e órfão de chave estrangeira com um left anti join, além de confirmar a declaração via `SHOW CREATE TABLE`, `DESCRIBE TABLE EXTENDED` ou as views do `information_schema` (`TABLE_CONSTRAINTS`, `KEY_COLUMN_USAGE`, `CONSTRAINT_TABLE_USAGE`, `CONSTRAINT_COLUMN_USAGE`, `REFERENTIAL_CONSTRAINTS`), e checar o plano final com `EXPLAIN`.

**Minha ressalva:** a otimização descrita aqui exige Photon, e a documentação é específica sobre o tipo de compute do Azure Databricks que destrava isso: SQL warehouse serverless ou pro, ou compute serverless. Quem roda em compute clássico sem Photon habilitado não vai ver nenhum dos dois ganhos, mesmo declarando tudo corretamente com `RELY`. Vale confirmar isso antes de prometer o número do benchmark pra alguém no time, porque o ganho de 7,9x a 12x é real, mas é condicionado a um tipo de compute específico que nem todo workspace Azure Databricks usa por padrão.

## Vale adotar?

Sim, pra quem já tem relação de chave bem definida entre tabela de fato e tabela de dimensão num modelo analítico, especialmente em tabela de fato muito grande (bilhões de linha) juntando com dimensão relativamente pequena, que é exatamente o padrão onde eliminação de join rende mais. O custo de adoção é baixo (é só uma declaração de esquema), mas o processo de validação antes de promover pra `RELY` não deve ser pulado, porque o preço de uma garantia falsa é resultado incorreto silencioso, não um erro que alguém nota a tempo.

## Referências

- Databricks Blog, "Declare and optimize with UNIQUE constraints on Databricks": https://www.databricks.com/blog/declare-and-optimize-unique-constraints-databricks
- Microsoft Learn, "Constraints on Databricks - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/tables/constraints
- Databricks Docs (AWS), "Constraints on Databricks": https://docs.databricks.com/aws/en/tables/constraints
- Databricks Docs (AWS), "CREATE TABLE constraint clause": https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-syntax-ddl-create-table-constraint

#AzureDatabricks #UnityCatalog #SQL #Performance
