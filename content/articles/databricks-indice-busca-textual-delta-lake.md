---
title: "Índice de texto no Delta Lake: o que muda quando o Databricks para de escanear tudo pra achar uma palavra"
date: 2026-07-18T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Delta Lake", "Performance", "SQL"]
summary: "O índice de busca textual do Unity Catalog (Beta na Databricks Runtime 18.2) deixa de varrer arquivo por arquivo atrás de uma palavra e passa a pular direto pra onde ela realmente está. O ganho de performance é real, mas vem com manutenção manual e uma lista de recursos incompatíveis que vale conhecer antes de sair criando índice em tudo."
ShowToc: true
---

Quem já rodou um `WHERE message LIKE '%connection refused%'` numa tabela de log com alguns bilhões de linhas conhece a sensação. A query sobe, o cluster consome crédito, e minutos depois volta meia dúzia de linhas relevantes escondidas em terabytes de dado irrelevante. O Delta Lake sabe pular arquivo quando o filtro é numérico, é uma igualdade exata ou o dado está ordenado por aquela coluna, mas contra substring dentro de texto livre ele historicamente não tinha resposta boa: sem abrir o arquivo, o motor não tem como saber se a palavra está lá dentro.

O índice de busca textual chegou em Beta na Databricks Runtime 18.2 justamente pra atacar esse ponto cego. A lógica é a mesma que já sustenta min/max statistics e Z-Ordering no Delta Lake, só que estendida pra um tipo de predicado que aquelas técnicas nunca cobriram: substring e palavra dentro de texto livre. Numa tabela de log real, onde um termo raro costuma aparecer numa fração pequena dos arquivos, isso não é ajuste fino de configuração, é mudança de classe de problema, do tipo que decide se uma tela de busca em produção é usável ou não.

## O mecanismo: pular arquivo em vez de ler tudo

O índice de busca textual não guarda o texto inteiro numa estrutura de busca à parte, nem substitui o motor de query por algo parecido com Elasticsearch. Ele guarda, por arquivo do Delta, se aquele arquivo pode conter o padrão buscado. Quando a query usa as novas funções `search` ou `isearch`, o otimizador consulta o índice antes de tocar em disco e descarta de cara todo arquivo onde a resposta é "certamente não". Sobra pra leitura só o subconjunto de arquivos onde a palavra pode estar, e é aí que mora o ganho: numa tabela de log real, a fração de arquivos que efetivamente contém um termo raro costuma ser pequena, então o corte de I/O é desproporcional ao tamanho da tabela.

Essa é a mesma lógica de file skipping que o Delta já usa com min/max statistics e Z-Ordering, só que aplicada a um tipo de predicado que aquelas técnicas não cobrem: substring e palavra dentro de texto livre. O índice não altera o resultado da query, só decide quais arquivos vale a pena abrir.

## Mão na massa: criando e consultando um índice

O recurso exige tabela gerenciada (Delta ou Iceberg) com row tracking ligado, Databricks Runtime 18.2 ou superior, e o Beta habilitado no workspace. Do lado de permissão, é preciso ter `MODIFY` na tabela base e `CREATE TABLE` no schema pai pra poder criar o índice, e a coluna indexada não precisa ser só texto solto: `STRING`, `VARIANT`, `STRUCT` e `ARRAY` são todos aceitos, desde que uma `STRUCT` tenha pelo menos um campo folha do tipo certo em algum nível de aninhamento. Criar e usar um índice é direto em SQL:

```sql
CREATE TABLE logs (
  event_time TIMESTAMP,
  message STRING,
  error_detail STRING
)
TBLPROPERTIES ('delta.enableRowTracking' = 'true');

CREATE SEARCH INDEX log_idx
  ON logs (message, error_detail)
  OPTIONS (tokenizer = 'ngram', ngram_size = 4);

-- busca case-insensitive por substring
SELECT event_time, message
FROM logs
WHERE isearch(message, 'connection refused');

-- busca por todas as palavras, em qualquer ordem
SELECT event_time, message
FROM logs
WHERE search(message, 'timeout gateway upstream', mode => 'word');
```

A escolha do tokenizer importa mais do que parece. `ngram` fatia o texto em blocos sobrepostos de N caracteres (aceita de 3 a 10, padrão 5) e é o que sustenta busca por substring parcial, tipo achar `"refus"` dentro de `"connection refused"`. `split` fatia por palavra inteira, com um `min_token_length` configurável (padrão 3) pra descartar token curto demais na hora de indexar, e é mais barato quando a necessidade real é checar se um conjunto de palavras aparece no texto, sem se importar com substring dentro delas. Dá pra manter até quatro índices por tabela, cada um numa coluna diferente, então também é possível ter um índice `ngram` numa coluna e `split` em outra. Um detalhe que também vale saber de antemão: renomear a coluna indexada ou mudar o tipo dela depois de criado o índice não é suportado, então essas duas operações de schema exigem recriar o índice do zero.

## Custo: o ganho não aparece só no relógio, aparece na fatura

O ponto de comparação que mais importa aqui não é "quanto tempo demora", é "quanto compute é preciso alugar pra terminar em tempo aceitável". Sem índice, uma busca textual em tabela grande normalmente empurra o time a escalar o warehouse pra um tamanho maior só pra tolerar a varredura completa, o que significa pagar por DBU maior durante todo o tempo da consulta. Com o índice fazendo file skipping antes da leitura, o mesmo warehouse pequeno resolve a consulta rápido o suficiente pra não justificar o upsize. Numa tela de busca usada com frequência por várias pessoas ao mesmo tempo, a diferença entre manter um warehouse XS ligado e precisar de um M ou L pra dar conta da carga é o tipo de conta que aparece de forma bem concreta na fatura mensal, não é só experiência de usuário.

## O detalhe que passa despercebido: refresh não é automático

Diferente de uma estatística de tabela, o índice de busca textual não se atualiza sozinho quando a tabela recebe escrita nova. É preciso rodar `REFRESH INDEX log_idx` pra incorporar linhas novas de forma incremental, ou `REFRESH INDEX log_idx FULL` quando também é preciso remover entradas de linhas deletadas. Ignorar isso não quebra a query, porque o Databricks garante corretude usando table scan como fallback pra dado não indexado, mas o ganho de performance vai encolhendo silenciosamente conforme a tabela recebe escrita e ninguém lembra de atualizar o índice.

**Minha leitura:** esse design é sensato pra evitar surpresa de resultado errado, mas cria um tipo de dívida técnica que é fácil não perceber, porque a query continua funcionando, só fica cada vez mais lenta sem avisar. Se o índice vai proteger uma tela de busca em produção, o refresh precisa entrar no mesmo job que faz a ingestão, não ficar como tarefa manual esporádica.

## O que isso não resolve

O índice de busca textual não é um substituto de motor de busca full-text de verdade. Não existe ranking por relevância, não existe stemming, não existe busca fuzzy tolerante a erro de digitação, e três recursos bem usados em ambiente corporativo ficam de fora da lista de compatibilidade: OpenSharing, shallow clone e qualquer tabela com controle de acesso baseado em atributo (ABAC), máscara de coluna ou row-level security. Se a tabela adotar qualquer um desses depois de o índice já existir, o Databricks simplesmente ignora o índice na hora da query, silenciosamente, sem erro. Vale testar explicitamente `DESCRIBE INDEX` depois de qualquer mudança de política de acesso na tabela pra confirmar que o índice ainda está sendo considerado.

Também vale lembrar que é Beta: a documentação já avisa que índice criado nessa fase não tem garantia de compatibilidade quando o recurso virar Public Preview, e que vai ser preciso recriar. Não é o tipo de coisa que eu colocaria como dependência crítica de um pipeline de produção ainda em 2026.

## Vale a pena adotar?

Pra tabela de log, auditoria, ou qualquer caso onde a consulta típica é "essa palavra aparece em algum lugar desse texto", o índice de busca textual resolve um problema que só tinha soluções ruins até aqui, replicar dado pra um Elasticsearch à parte, manter uma coluna derivada com truque de particionamento, ou simplesmente aceitar que a busca ia ser lenta. Pra qualquer time que já sofre com tabela de log gigante e dashboard de troubleshooting lento, vale o teste em ambiente de não produção, com atenção especial à rotina de refresh e à lista de incompatibilidades antes de prometer o ganho de performance pra alguém.

## Referências

- Microsoft Learn, "Full-text search indexes on Unity Catalog managed tables": https://learn.microsoft.com/en-us/azure/databricks/optimizations/full-text-search-indexes
- Databricks Docs, "Accelerate search queries with full-text search indexes on Databricks": https://www.databricks.com/blog/accelerate-search-queries-full-text-search-indexes-databricks

#Databricks #UnityCatalog #Performance #SQL
