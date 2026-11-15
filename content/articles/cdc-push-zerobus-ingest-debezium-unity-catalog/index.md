---
title: "CDC sem Kafka pra manter: por que faz sentido o banco empurrar a mudança em vez de alguém de fora vir buscar"
date: 2026-11-06T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Unity Catalog", "CDC", "Ingestão de Dados"]
ShowToc: true
summary: "Captura de mudança de banco de dados sempre teve um dilema de rede: ou o banco abre uma porta de entrada pra alguém buscar os dados, ou alguém mantém um cluster Kafka só pra transporte. O Zerobus Ingest, combinado ao Debezium Server, inverte a lógica: o time que já opera o banco também decide o que sai dele, sem broker no meio e com confirmação de durabilidade antes de cada avanço de offset."
---

Toda arquitetura de captura de mudança de dados (CDC) carrega uma decisão de rede incômoda. Pra alguém de fora ler o log de transação de um banco de produção, geralmente é preciso abrir uma porta de entrada numa rede que, por boa razão, foi desenhada pra não ter nenhuma. A alternativa clássica, pooling via `SELECT ... WHERE atualizado_em > ?`, sobrecarrega o banco e ainda assim perde exclusão de linha, porque uma linha apagada não aparece mais em nenhuma consulta.

A combinação de Zerobus Ingest com Debezium Server ataca esse problema invertendo quem inicia a conexão. Em vez de alguém de fora entrar pra buscar, o próprio lado do banco empurra a mudança pra fora. Isso parece um detalhe de implementação, mas desloca a decisão de governança pra onde ela deveria estar desde o início: o time que já opera o banco de produção.

## O mecanismo: leitura de log, não consulta repetida

Debezium é uma plataforma de CDC baseada em log, de código aberto, que existe desde 2015. Em vez de consultar a tabela repetidamente, ele lê diretamente o write-ahead log do PostgreSQL, o binlog do MySQL, ou o change stream do MongoDB, dependendo da origem. Cada mudança captada vira um evento com uma estrutura fixa: `before` (estado da linha antes, nulo em inserção), `after` (estado depois, nulo em exclusão), `op` (`c` de create, `u` de update, `d` de delete, `r` de leitura de snapshot inicial), `source` (banco, esquema, tabela, posição no log, ID de transação) e `ts_ms` (timestamp do evento).

Existem dois jeitos de rodar Debezium. O mais conhecido usa Kafka Connect, com Debezium como plugin de conector nativo pra Apache Kafka. O segundo, Debezium Server, é uma aplicação Quarkus independente que não precisa de Kafka Connect, só de um sink adaptado pro destino de escolha. É nesse segundo modelo que o Zerobus entra: a partir do Debezium Server 3.7, existe um sink nativo pro Zerobus Ingest, construído pela própria Databricks, com NVIDIA contribuindo o modo envelope e as salvaguardas de entrega.

## O que o Zerobus Ingest resolve que um conector tradicional não resolve

Zerobus Ingest é um serviço de ingestão serverless do Azure Databricks, orientado a push, que escreve direto em tabela Delta governada pelo Unity Catalog, sem exigir broker de mensagem nenhum rodando no meio do caminho. O produtor (no nosso caso, o Debezium Server) se conecta direto a um endpoint do Zerobus e transmite os registros. No Azure Databricks, esse endpoint segue o padrão `<id-do-workspace>.zerobus.<regiao>.azuredatabricks.net`, autenticado via service principal ou via federação com Microsoft Entra ID.

A diferença pra uma arquitetura clássica com barramento de mensagem é estrutural: nessa última, alguém precisa dimensionar e operar o cluster Kafka (quantidade de broker, partição), e o lado do lakehouse ainda precisa de um segundo salto (Spark, um Kafka Connector ou equivalente) pra tirar o dado do tópico e colocar em Delta. É uma arquitetura de dois saltos. Com Zerobus, o salto único vai direto da origem pra tabela governada.

{{< figure src="arquitetura-zerobus-push-cdc.png" alt="Diagrama de arquitetura mostrando Debezium Server capturando mudança do write-ahead log do banco de origem e enviando via push direto pro Zerobus Ingest, que grava em tabela Delta no Unity Catalog, sem broker de mensagem no meio" caption="Arquitetura publicada pela Databricks: o lado da origem inicia a conexão de saída e empurra a mudança, em vez de alguém de fora entrar pra buscar." >}}

**Minha leitura:** o argumento que mais pesa aqui não é de performance, é de governança de rede. Permitir conexão de saída de dentro de um perímetro corporativo é, na prática, muito mais fácil de aprovar do que abrir uma porta de entrada pra um sistema externo. Isso muda quem precisa assinar o pedido de acesso, e em empresa grande essa diferença decide se o projeto sai do papel em semanas ou em meses.

## Mão na massa: os dois contratos de tabela do sink

O sink do Zerobus pro Debezium Server oferece dois formatos de tabela de destino. O modo **typed** (padrão) mapeia cada evento de mudança numa tabela com as colunas originais da fonte, column a column. O modo **envelope** grava o evento de mudança completo do Debezium numa tabela de nove colunas fixas: `target_table`, `destination`, `partition`, `operation`, `idempotency_key`, `key`, `value`, `source_position` e `headers`. O conteúdo pode ser codificado como JSON (em coluna do tipo `VARIANT`) ou Protobuf.

O detalhe mais importante do modo envelope é o `idempotency_key`: um identificador SHA-256 derivado do destino, partição, chave, operação e posição de origem. Isso significa que um evento reentregue gera exatamente a mesma chave de idempotência, o que importa porque a garantia de entrega aqui é **pelo menos uma vez**, não exatamente uma vez. Se um grupo de registros posterior falha, um grupo anterior já confirmado como durável pode ser reentregue, e é o `idempotency_key` que permite tratar a duplicata depois, na camada seguinte.

O gate de durabilidade funciona assim: o sink envia cada grupo contíguo de registros de uma tabela, espera o Zerobus confirmar esse grupo como durável, e só então libera o Debezium pra avançar o offset de origem.

```text
# Fluxo de confirmação de durabilidade, resumido do comportamento documentado
1. Debezium lê um lote de eventos do WAL
2. Sink agrupa por tabela de destino e envia ao Zerobus
3. Zerobus confirma durabilidade do grupo (escrita em Delta)
4. Só após a confirmação, Debezium avança o offset de leitura do WAL
# Se o passo 3 falhar, o offset NÃO avança, e o grupo é reenviado
```

Como o Zerobus é somente acréscimo (append-only), reconstruir o estado atual de uma linha exige um merge posterior, que mantém a versão mais recente por chave primária. É aqui que entra o desenho em camadas: bronze guarda o evento de mudança bruto, uma linha por evento, com operação, imagem antes/depois e posição de origem; silver desduplica pelo `idempotency_key` e ordena pela posição de origem (o LSN do PostgreSQL, por exemplo); gold agrega em nível de negócio. Pra manter o estado atual (tipo 1) em vez do histórico completo (tipo 2), o padrão recomendado usa `AUTO CDC`, sequenciando pelo LSN de origem.

## O que isso não resolve

Nem o blog oficial, nem a documentação, trazem número de throughput ou latência pra essa combinação específica, só a afirmação qualitativa de que o Zerobus "continua funcionando no horário de pico sem ajuste fino". Isso é razoável de acreditar dado o desenho serverless, mas eu testaria com o volume real da sua origem antes de assumir que o comportamento em pico vai ser transparente, principalmente se a tabela de destino tiver muita contenção de merge na camada silver.

Vale reparar também que o esquema da tabela de destino, no modo envelope, é fixo em nove colunas. Isso significa que toda a flexibilidade de modelagem fica concentrada na camada silver, onde você extrai o `VARIANT` pra colunas tipadas. Não é uma limitação grave, mas muda o ponto onde o time de dado precisa investir esforço de modelagem, que passa a ser depois da ingestão, não durante.

**Minha ressalva:** autenticação via identidade de serviço (service principal, com client ID e secret, ou federação via Microsoft Entra ID com troca de token) e os grants `USE CATALOG`, `USE SCHEMA` e `GRANT MODIFY, SELECT` na tabela de destino precisam estar corretos antes do primeiro evento chegar, porque a documentação é explícita que pedir privilégio diferente de `SELECT` ou `MODIFY` no token faz a requisição falhar de forma direta. Em ambiente corporativo com processo de aprovação de permissão lento, esse é o passo que mais atrasa um piloto, não a configuração do Debezium em si.

## Vale adotar?

Sim, especificamente pra quem já roda Debezium (ou está disposto a rodar) e tem uma política de rede que trata conexão de entrada como risco maior do que conexão de saída, o que descreve a maioria das empresas com dado sensível em produção. Pra quem já tem Kafka rodando estável pra outros fins e só precisa de mais um consumidor, a vantagem é menor, já que o custo operacional do broker já está pago. O ganho real aparece quando Kafka existiria só pra essa finalidade de transporte, e aí o Zerobus corta um salto inteiro da arquitetura.

## Referências

- Databricks Blog, "Push-based CDC into Unity Catalog with Zerobus Ingest and Debezium": https://www.databricks.com/blog/push-based-cdc-unity-catalog-zerobus-ingest-and-debezium
- Microsoft Learn, "Zerobus Ingest - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/ingestion/zerobus-ingest
- Databricks Docs (AWS), "Zerobus Ingest": https://docs.databricks.com/aws/en/ingestion/zerobus-ingest
- Debezium Project, "Debezium 3.7 Final Released": https://debezium.io/blog/2026/09/29/debezium-3-7-final-released/#databricks_zerobus_ingest_sink_adapter

#AzureDatabricks #UnityCatalog #CDC #Ingestao
