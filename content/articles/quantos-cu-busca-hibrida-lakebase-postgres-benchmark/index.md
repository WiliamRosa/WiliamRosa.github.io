---
title: "Quantos CU você precisa pra busca híbrida no Postgres? Um benchmark com 4 milhões de passagens responde melhor do que a intuição"
date: 2026-10-16T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Lakebase", "Performance"]
ShowToc: true
summary: "Dimensionar compute pra busca híbrida (vetorial mais texto) dentro do Lakebase Postgres costuma ser chute. Um benchmark end-to-end, de uma aplicação real a um corpus sintético de 4 milhões de passagens, mostra onde o gargalo realmente mora: cache quente, não CPU bruto, e dá número concreto de CU, requisição por segundo e custo em dólar pra cada ponto da curva."
---

Já cobri aqui antes a chegada do Lakebase Search, a combinação de busca vetorial e busca por palavra-chave direto dentro do Postgres operacional, sem precisar de um banco vetorial separado. O que faltava era a pergunta que toda equipe de plataforma faz na prática antes de colocar isso em produção: quanto compute eu realmente preciso pra isso não ficar lento quando o tráfego crescer? Um benchmark recente, partindo de uma aplicação real com cerca de 23 mil linhas de slide e escalando até um corpus sintético de 4 milhões de passagens, respondeu essa pergunta com número, não com regra de bolso.

## O mecanismo: busca híbrida numa única consulta SQL

Antes de chegar ao benchmark, vale entender o que exatamente está sendo medido. O Lakebase Search expõe duas extensões dentro do próprio Postgres: uma de busca vetorial (com índice aproximado tipo IVF e quantização RaBitQ, que compacta o vetor sem perder tanta precisão de busca) e uma de busca textual via BM25, o algoritmo clássico de ranking por palavra-chave usado por motor de busca há décadas.

A parte elegante é como as duas se combinam: em vez de rodar duas consultas separadas e juntar os resultados na aplicação, a busca híbrida roda como uma única instrução SQL. Ela pega um conjunto de candidatos do lado vetorial, outro conjunto do lado textual, funde os dois rankings usando Reciprocal Rank Fusion (RRF, uma fórmula que dá peso a um item com base na posição dele em cada ranking, não no valor bruto do score) e ainda aplica filtro adicional, como peso por título ou contagem de voto, tudo dentro do mesmo banco que já guarda os dados da aplicação.

```sql
-- Esboço conceitual de busca híbrida com RRF, escrito a partir do mecanismo
-- descrito (não copiado de nenhuma fonte), ilustrando a ideia central:
-- combinar ranking vetorial e ranking textual com Reciprocal Rank Fusion.

WITH busca_vetorial AS (
    SELECT id, row_number() OVER (ORDER BY embedding <-> :query_embedding) AS posicao
    FROM slides
    ORDER BY embedding <-> :query_embedding
    LIMIT 200
),
busca_textual AS (
    SELECT id, row_number() OVER (ORDER BY bm25_score DESC) AS posicao
    FROM slides, bm25_rank(conteudo, :query_texto) AS bm25_score
    ORDER BY bm25_score DESC
    LIMIT 200
)
SELECT
    coalesce(v.id, t.id) AS id,
    -- Reciprocal Rank Fusion: 1 / (k + posicao), k=60 amortece o peso
    -- de posições muito baixas em qualquer um dos dois rankings
    coalesce(1.0 / (60 + v.posicao), 0) + coalesce(1.0 / (60 + t.posicao), 0) AS score_final
FROM busca_vetorial v
FULL OUTER JOIN busca_textual t USING (id)
ORDER BY score_final DESC
LIMIT 10;
```

## Os dois gargalos que competem entre si

O benchmark identifica dois pontos de contenção que crescem em direções diferentes: o compute do Lakebase Postgres (medido em CU, Compute Unit) e o compute do próprio Databricks App que recebe a requisição e fala com o banco (com um número fixo de processos worker e pool de conexão). A recomendação prática que sai do teste é escalar primeiro o Postgres, até um teto em torno de 8 CU, e só depois começar a somar worker de aplicação, porque até esse ponto o banco costuma ser o fator limitante, não a camada de aplicação.

Isso por si só já desafia uma intuição comum: diante de latência alta, o primeiro instinto costuma ser aumentar o compute da aplicação (mais réplica, mais worker), quando na prática boa parte do ganho inicial vem de dar mais memória e CPU pro próprio banco.

## O achado mais contraintuitivo: pool de conexão supera CPU bruto

Com 50 usuários simultâneos, simplesmente ativar um pool de conexão (reaproveitar conexão já aberta com o banco em vez de abrir uma nova a cada requisição) quase dobrou o throughput, e cortou a latência de percentil 95 de bem mais de 2 segundos pra menos de 1. Esse ganho veio de configuração, não de CU adicional.

**Minha leitura:** esse é o tipo de resultado que deveria vir antes, não depois, de qualquer decisão de escalar hardware. Pool de conexão malconfigurado é um problema de engenharia de aplicação, invisível num gráfico de utilização de CPU do banco, e ainda assim, nesse teste, valeu mais do que boa parte do range de CU testado. Quem dimensiona banco olhando só métrica de infraestrutura, sem revisar como a aplicação abre e reusa conexão, está otimizando a variável errada primeiro.

## Cache quente é o que decide a latência em escala

A descoberta central do benchmark, e a que dá mais substância prática pro título deste artigo, é sobre o comportamento do cache local (o Local File Cache que faz a ponte entre a memória da instância de compute e o armazenamento em disco separado). O teste varia a proporção entre tamanho do cache e tamanho do índice vetorial, de 0,07 até 2,3, e mede taxa de acerto de cache e latência em cada ponto.

Com proporção de cache baixa (0,07, ou seja, cache cobrindo só 7% do índice), a taxa de acerto fica em torno de 45% e a latência de consulta a quente (warm, já com algum cache aquecido) fica em 187 milissegundos. Subindo a proporção pra algo acima de 2 (cache maior que o próprio índice), a taxa de acerto sobe pra 97% e a latência a quente despenca pra 4 milissegundos, quase 47 vezes mais rápido. Cada página que precisa ser lida do armazenamento em disco (um "miss" de cache) adiciona cerca de 0,3 milissegundo, um custo pequeno isoladamente, mas que se acumula rápido quando a taxa de acerto é baixa e a maioria das consultas sofre múltiplos misses.

{{< figure src="latencia-vs-tamanho-indice.png" alt="Gráfico mostrando latência de consulta vetorial a quente permanecendo entre 11 e 23 milissegundos conforme o corpus cresce de 1 para 4 milhões de passagens, enquanto o tamanho do índice cresce de 5,8 para 23 gigabytes" caption="Com cache dimensionado corretamente, a latência a quente se mantém praticamente estável mesmo quando o corpus (e o índice) crescem 4 vezes, de 1 para 4 milhões de passagens." >}}

Esse gráfico é o resumo visual do argumento inteiro do benchmark: o problema de escala não é "CPU insuficiente pra calcular distância vetorial", é "cache insuficiente pra manter o índice de trabalho quente em memória". Escalando de 1 para 4 milhões de passagens (o índice crescendo de 5,8 GB pra 23 GB), a latência a quente permaneceu estável, entre 11 e 23 milissegundos, contanto que o cache acompanhasse o crescimento do índice.

## Precisão também é uma escolha de configuração, não um dado fixo

Outro eixo que o benchmark testa é o trade-off entre velocidade de construção do índice e qualidade de busca. O modo padrão de índice entrega recall@10 (a fração dos 10 resultados mais relevantes que de fato aparecem no top 10 retornado) em torno de 0,74 a 0,75. Um modo de construção alternativo, voltado pra qualidade, sobe esse número pra 0,80 com configuração padrão de busca, e pra 0,97 aumentando o número de "probes" (quantos clusters do índice IVF são verificados por consulta) pra 2.000. O custo dessa qualidade extra é tempo de construção do índice: 52 minutos, nesse teste, contra um tempo bem menor pro modo padrão.

Isso significa que "recall" não é uma propriedade fixa do sistema, é um parâmetro de configuração com custo explícito em tempo de indexação, algo que vale decidir conscientemente com base em quão crítico é não perder um resultado relevante no seu caso de uso específico, em vez de aceitar o padrão sem questionar.

## O que isso não resolve

O benchmark usa um corpus sintético (MIRACL, em inglês) e um padrão de consulta artificial (mix "enviesado", simulando popularidade desigual entre documentos) pra montar a curva de cache. Isso é ótimo pra isolar variável e entender o mecanismo, mas o número exato de CU recomendado pra 4 milhões de passagens no seu caso específico depende do seu padrão real de acesso, da distribuição real de popularidade dos seus documentos, e do tamanho real dos seus embeddings. Trate os números aqui como ordem de grandeza e ponto de partida pra teste próprio, não como tabela de dimensionamento definitiva.

O benchmark também não cobre o que acontece em escrita concorrente pesada (inserção e atualização de documento em volume alto ao mesmo tempo que consulta), só leitura em volume. Pipeline que precisa reindexar com frequência, em paralelo com tráfego de busca ativo, é um cenário diferente que merece teste próprio.

**Minha ressalva:** o dado de custo do teste (um teste de carga de 14 minutos processando mais de cem mil requisições por cerca de 13 centavos de dólar) é real e impressionante, mas é custo de um teste controlado e de curta duração, não custo de operação contínua em produção com picos de tráfego reais, SLA de disponibilidade e necessidade de manter compute sempre ligado (always-on) pra evitar latência de start up a frio. A recomendação do próprio benchmark de manter um piso de 0,5 CU sempre ativo, por algo entre 31 e 40 dólares mensais, é o número mais honesto pra orçar, não o custo do teste de carga isolado.

## Vale usar esse benchmark pra dimensionar o seu projeto?

Vale, com a ressalva de tratá-lo como ponto de partida, não como tabela pronta. Três decisões concretas saem direto dele: primeiro, escale o Lakebase Postgres antes de escalar o Databricks App, até a faixa de 8 CU, porque é ali que normalmente mora o gargalo inicial. Segundo, confirme que a aplicação está usando pool de conexão antes de qualquer decisão de CU, porque esse ajuste sozinho já entregou quase o dobro de throughput no teste. Terceiro, e mais importante, dimensione o cache (CU suficiente) pensando no tamanho do índice de trabalho, não no tamanho total dos dados, porque é a proporção entre os dois que determina se sua consulta fica em milissegundos de um dígito ou em centenas.

## Referências

- Databricks Blog, "Sizing Lakebase Search: lessons from a real app and 4 million passages": https://www.databricks.com/blog/sizing-lakebase-search-lessons-real-app-and-4-million-passages
- Databricks Docs (AWS), "Lakebase Search": https://docs.databricks.com/aws/en/oltp/projects/lakebase-search
- Microsoft Learn, "Lakebase Search - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/lakebase-search
- Databricks Docs (AWS), "Manage computes": https://docs.databricks.com/aws/en/oltp/projects/manage-computes
- Microsoft Learn, "Manage computes - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/oltp/projects/manage-computes
- Databricks Blog, "Lakebase Search: state of the art full-text and vector search on Postgres": https://www.databricks.com/blog/lakebase-search-state-art-full-text-and-vector-search-postgres

#AzureDatabricks #Lakebase #Performance #Postgres
