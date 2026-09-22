---
title: "Consulta pontual em tabela de 50 bilhões de linhas em 0,33 segundo: o que o Lakehouse//RT resolve sem sair do Unity Catalog"
date: 2026-08-06T09:00:00-03:00
draft: false
tags: ["Databricks", "Azure Databricks", "Lakehouse", "SQL Warehouse", "Performance"]
summary: "Lakehouse//RT é um novo tipo de warehouse serverless da Azure Databricks, em Beta, construído sobre o motor Reyden para entregar latência sub-segundo em consulta de leitura direto sobre tabela Delta e Iceberg do Unity Catalog, sem exigir um banco separado de serving em tempo real."
ShowToc: true
---

Toda arquitetura de dado que cresce o suficiente esbarra na mesma bifurcação: o lakehouse é ótimo pra consulta analítica pesada e barata, mas péssimo quando a aplicação precisa de resposta em milissegundos pra milhares de usuário concorrente. A saída padrão da indústria virou duplicar o dado, uma cópia no lakehouse pra análise, outra num banco de serving dedicado, tipo um Postgres ajustado, um Redis, ou uma engine de OLAP em tempo real como Apache Pinot ou StarTree, só pra aguentar o padrão de acesso pontual e de baixa latência. Isso funciona, mas custa duas vezes: dinheiro de infraestrutura duplicada, e a dor recorrente de manter duas cópias de verdade sincronizadas e duas camadas de governança separadas.

O Lakehouse//RT ataca exatamente esse ponto de fricção. É um novo tipo de warehouse SQL serverless do Azure Databricks, em Beta, desenhado pra consulta de leitura com latência sub-segundo direto sobre tabela do Unity Catalog, sem copiar dado pra lugar nenhum.

## O motor por trás da promessa de milissegundo

Lakehouse//RT roda sobre o Reyden, um motor novo construído especificamente pra workload de baixa latência e alta concorrência, o tipo de carga que hoje força muita empresa a manter uma camada de serving separada só pra aplicação, dashboard operacional ou sistema de observabilidade que precisa de resposta rápida com centenas ou milhares de consulta concorrente.

A diferença estrutural em relação a um SQL Warehouse serverless comum está em dois pontos. Primeiro, o dado nunca sai do formato aberto, Delta Lake ou Apache Iceberg, gerenciado pelo Unity Catalog, então a mesma tabela que alimenta seu pipeline de ETL e seu dashboard de BI também serve a aplicação em tempo real, com a mesma política de acesso e a mesma linhagem. Segundo, o modelo de escala é diferente: em vez de dimensionar cluster inteiro, o autoscaling do Lakehouse//RT adiciona ou remove só a fração de computação necessária, medida em DBU, e o parâmetro que controla a velocidade de uma consulta individual, chamado query size, é independente do parâmetro que controla quanta concorrência o warehouse aguenta. Na prática isso significa que dá pra combinar uma query size pequena com um teto de autoscaling alto, pra aguentar muita consulta simultânea sem pagar mais por cada consulta isolada ser mais rápida do que precisa.

## Os números que sustentam a promessa

Um benchmark independente rodou dezenove cenários de teste, variando de 1 milhão a 50 bilhões de linhas, comparando Lakehouse//RT contra um SQL Warehouse clássico. O resultado: Lakehouse//RT venceu em praticamente todo cenário, exceto join grande entre tabela. Um lookup de registro único numa tabela de 50 bilhões de linhas caiu de 66,2 segundos pra 0,33 segundo. Em tabela pequena, na casa de 1 milhão de linha, com boa poda de dado a consulta chegou a 10 milissegundos. O preço acompanha o de um SQL Warehouse pequeno, com uma promoção de lançamento de 30% de desconto, então o ganho de latência não veio junto com penalidade de custo proporcional.

**Na prática:** eu testaria qualquer workload de join pesado, acima de uns 100 GB, contra um SQL Warehouse clássico antes de migrar de olhos fechados. O próprio benchmark aponta que join grande ainda perde pro warehouse tradicional, e a saída recomendada, pré-computar uma materialized view, exige decisão de modelagem que não é automática, alguém precisa desenhar essa camada intermediária antes.

## Mão na massa: criando e testando um warehouse Real-Time

Criar um Lakehouse//RT segue o mesmo fluxo de um SQL Warehouse comum, com um tipo de warehouse diferente selecionado na criação. Depois de habilitar o preview no workspace, em **Compute > SQL Warehouses > Create SQL Warehouse**, escolhendo o tipo **Real-Time**, você define o `query size` (`Small`, `Medium`, `Large` ou `X-Large`), o teto de autoscaling em DBU, e o tempo de auto stop.

Pra validar se uma consulta é boa candidata antes de migrar, o padrão recomendado é começar num SQL Warehouse serverless comum e confirmar que ela já roda em poucos segundos, com filtro seletivo e poucas colunas selecionadas:

```sql
-- consulta candidata a Lakehouse//RT: seletiva, poucas colunas, tabela gerenciada
SELECT customer_id, status, last_event_ts
FROM catalog_prod.gold.customer_events
WHERE customer_id = :id
  AND event_date >= current_date() - INTERVAL 7 DAYS
```

Pra conectar uma aplicação externa, o Lakehouse//RT só aceita conexão via Statement Execution API, não o protocolo Thrift legado. Usando o conector Python:

```python
from databricks import sql

connection = sql.connect(
    server_hostname="<workspace-host>",
    http_path="<lakehouse-rt-warehouse-http-path>",
    access_token="<token>",
    use_kernel=True,  # obrigatório para Lakehouse//RT
)

with connection.cursor() as cursor:
    cursor.execute(
        "SELECT customer_id, status FROM catalog_prod.gold.customer_events WHERE customer_id = %s",
        (customer_id,),
    )
    row = cursor.fetchone()
```

Esquecer o `use_kernel=True` é o erro mais comum: um driver que tenta conectar sem passar pela Statement Execution API recebe um erro `501`, direto.

## Onde ele ainda não chega

Lakehouse//RT roda só consulta de leitura, `SELECT`, em modo ANSI estrito, sem exceção. Isso pega gente desprevenida: `CAST` implícito que antes só devolvia `NULL` silenciosamente agora pode lançar erro em tempo de execução, e comparação entre tipo incompatível em `COALESCE`, `CASE` ou `IN` pode falhar em tempo de análise em vez de coagir tipo silenciosamente. Nenhuma escrita é suportada, nem `INSERT`, `UPDATE`, `MERGE`, `CREATE TABLE AS SELECT`, nem manutenção de Delta como `OPTIMIZE` ou `VACUUM`.

A lista de recurso ainda fora do escopo também é longa pra uma Beta: Genie e Genie Agents não funcionam sobre esse tipo de warehouse, ABAC (incluindo row-level security e column mask) não é suportado, e tabela do Hive metastore, tabela externa do Unity Catalog, Delta Sharing e tabela em outro formato que não Delta ou Iceberg também ficam de fora. Função de IA, UDF em Python e função espacial SQL também não rodam.

Nada disso invalida a proposta, mas explica por que a documentação oficial é enfática: valide a consulta antes, use tabela gerenciada com liquid clustering e predictive optimization ativados, e não trate isso como substituto de warehouse pra carga de trabalho mista que ainda depende de escrita ou de recurso de governança fina.

## Vale a pena testar agora

Lakehouse//RT ainda está em Beta, restrito a região suportada e dependente de habilitação manual pela conta Databricks, então não é decisão de migrar workload crítico de produção hoje. Mas o problema que ele resolve é real e caro: manter duas cópias de verdade, uma no lakehouse e outra num banco de serving dedicado, é fricção operacional que a maioria dos times de dado sente na pele, mesmo quando não fala sobre isso em voz alta. Se sua aplicação já tem uma consulta seletiva, bem indexada por clustering, batendo num Postgres ou Redis só porque o SQL Warehouse clássico não entrega latência suficiente, vale rodar o mesmo teste que o benchmark fez: comparar antes e depois numa réplica de produção, sem apostar tudo de uma vez.

## Referências

- Databricks Blog, "Introducing Lakehouse//RT: Real-Time Performance on a Unified Lakehouse": https://www.databricks.com/blog/introducing-lakehousert-real-time-performance-unified-lakehouse
- Microsoft Learn, "Lakehouse Real-Time - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/compute/sql-warehouse/real-time
- Databricks Docs, "Lakehouse Real-Time": https://docs.databricks.com/aws/en/compute/sql-warehouse/real-time

#Databricks #AzureDatabricks #Lakehouse #Performance
