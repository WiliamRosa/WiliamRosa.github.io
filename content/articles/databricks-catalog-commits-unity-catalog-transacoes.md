---
title: "Quando o Unity Catalog vira coordenador de transação, não só o dicionário de tabelas"
date: 2026-06-06T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Delta Lake", "Governança", "Arquitetura"]
summary: "Catalog Commits tira a coordenação de transação do Delta Lake do object storage e coloca dentro do Unity Catalog, habilitando transação atômica entre várias tabelas e leitura de metadado sem round-trip pra nuvem. O recurso central já é GA desde maio de 2026, com Delta Spark, Flink, Trino e DuckDB entre os engines suportados, mas escrita de engine externo continua em Beta e tabela Iceberg gerenciada em Private Preview."
ShowToc: true
---

Delta Lake sempre resolveu concorrência de escrita de um jeito engenhoso e um tanto invisível: cada tabela mantém o próprio log de transação dentro do object storage, e todo writer que quer confirmar uma mudança precisa negociar diretamente com aquele log, arquivo por arquivo, tabela por tabela. Funciona bem pra uma tabela por vez. O problema aparece quando a operação de negócio real mexe em duas ou três tabelas ao mesmo tempo, um pedido que atualiza estoque e cria registro de auditoria, por exemplo, e não existe garantia nativa de que as duas escritas aconteçam juntas ou falhem juntas.

O Catalog Commits muda onde mora a coordenação dessa transação: em vez de cada tabela negociar sozinha com o object storage, o Unity Catalog passa a ser a fonte da verdade sobre o estado de cada tabela gerenciada. O dado continua exatamente onde sempre esteve, em formato aberto no seu storage account, o que muda é quem arbitra a escrita. Vale uma atualização de status logo de cara: a Databricks anunciou GA do recurso central em 12 de maio de 2026, e a documentação da Microsoft (atualizada em agosto) confirma isso, mas com duas exceções importantes que ainda carregam rótulo de preview, tratadas na seção de limitações mais abaixo.

## O mecanismo: metadado sai do storage e entra no catálogo

Na arquitetura tradicional, um cliente que quer ler o estado atual de uma tabela Delta precisa ir até o object storage, listar arquivo de log, e reconstruir o estado a partir dali, um processo que soma latência de rede a cada consulta de metadado. Com Catalog Commits habilitado, o Unity Catalog já sabe o estado da tabela e entrega essa informação direto pro cliente Delta na hora do acesso, sem esse round-trip. Isso acelera tanto planejamento de query quanto escrita, porque o gargalo de metadado deixa de existir.

O ganho estrutural maior, porém, é a possibilidade de transação atômica atravessando múltiplas tabelas: como o Unity Catalog já está no meio de cada commit, ele consegue coordenar um conjunto de mudanças em tabelas diferentes como uma unidade só, tudo confirma junto ou nada confirma, mantendo a garantia ACID que o Delta Lake sempre teve, só que agora numa escala de várias tabelas e não apenas uma. Some a isso a possibilidade de engine externo escrever com segurança numa tabela gerenciada pelo Unity Catalog, porque é o próprio catálogo que arbitra conflito de concorrência, prevenindo corrupção de dado que hoje só existe informalmente por convenção de time.

## Mão na massa: ligando e verificando o recurso

Habilitar Catalog Commits é uma propriedade de tabela, não uma mudança de arquitetura:

```sql
-- numa tabela nova
CREATE TABLE vendas (
  id_venda BIGINT,
  valor DECIMAL(10,2),
  data_venda DATE
)
TBLPROPERTIES ('delta.feature.catalogManaged' = 'supported');

-- numa tabela existente
ALTER TABLE vendas
SET TBLPROPERTIES ('delta.feature.catalogManaged' = 'supported');

-- confirmando que está ativo
DESCRIBE DETAIL vendas;
-- procure 'catalogManaged' na coluna tableFeatures
```

Um detalhe que quem administra plataforma de dado precisa saber de antemão: ligar Catalog Commits numa tabela existente dispara uma sincronização do estado da tabela com o catálogo, e em tabela com alto volume histórico de escrita essa sincronização pode levar minutos, não é uma troca de flag instantânea. Vale planejar essa janela como faria com qualquer outra migração de metadado, de preferência fora do horário de pico de escrita.

O requisito de versão de runtime varia conforme a operação, não é um número único pra decorar: Databricks Runtime 16.4 ou superior já lê, escreve e cria tabela gerenciada com Catalog Commits ligado; ativar ou desativar o recurso numa tabela existente exige Runtime 18.0 ou superior; streaming table e materialized view pedem Runtime 17.3 ou superior pra ler e escrever, e Runtime 18 LTS ou superior especificamente pra desativar o recurso nelas depois de ligado. Também não dá pra alternar Catalog Commits usando `CREATE OR REPLACE TABLE` ou `REPLACE TABLE`, só `CREATE TABLE` (na criação) ou `ALTER TABLE` (numa tabela já existente) funcionam pra esse propósito.

**Minha leitura:** o nome do recurso sugere uma feature de conveniência, mas o efeito é uma mudança de modelo mental sobre onde mora a verdade dos seus dados. Hoje, muita gente ainda pensa em Unity Catalog como um dicionário de metadado e controle de acesso, um verniz de governança sobre um Delta Lake que continua se virando sozinho por baixo. Catalog Commits empurra o catálogo pra dentro do caminho crítico de escrita, o que é ótimo pra consistência entre tabelas, mas também faz do Unity Catalog um ponto de coordenação do qual a plataforma passa a depender de verdade, não só de fachada.

## Um cenário concreto: leitura via Delta Kernel de fora da Databricks

Pense num time que já consulta a mesma tabela gerenciada a partir de mais de um motor, Databricks SQL de um lado, e Trino, DuckDB ou um pipeline Flink de outro. Sem Catalog Commits, cada engine reconstrói o estado da tabela lendo o log de transação direto do object storage, e nada garante que os vários engines estejam vendo exatamente o mesmo commit no mesmo instante. A leitura via integração com Delta Kernel já é o caminho suportado hoje: Delta Spark, Delta Flink, Starburst Trino, DuckDB e StreamNative aparecem explicitamente na lista de engines com suporte a Catalog Commits.

Escrita a partir de engine externo é uma história diferente: continua listada como Beta na documentação, atrás de habilitação explícita na página de Previews do workspace, então "qualquer engine externo escreve com segurança hoje" ainda é otimismo antecipado. O que já é GA é a leitura consistente entre engines e a coordenação de commit para o que já escreve através da própria Databricks (Delta Sharing, Zerobus, Lakeflow Connect, Unity AI Gateway, MLflow e Lakeflow Job Triggers foram citados nominalmente pela Databricks como já integrados).

## O que isso não resolve

A lista de incompatibilidades é longa o suficiente pra merecer checklist antes de ligar em produção, mesmo com o recurso central já em GA. Transação escrevendo em tabela gerenciada Iceberg via Catalog Commits continua em Private Preview, atrás de formulário de inscrição. Escrita de engine externo pelo Delta Kernel continua em Beta, atrás da página de Previews do workspace, então nem toda promessa de "engine externo escreve com segurança" já vale pra produção sem essa habilitação explícita. Tabela com Catalog Commits habilitado passa a ser compartilhada via OpenSharing usando URL pré-assinada em vez de token de nuvem, uma mudança de comportamento que pode pegar quem já tem consumidor externo configurado. Streaming table e materialized view com acesso externo já configurado precisam ter esse acesso desativado antes de habilitar Catalog Commits, é preciso escolher um dos dois. E cluster de usuário único simplesmente não consegue acessar streaming table com o recurso habilitado. Nenhum desses pontos invalida o recurso, mas todos empurram na mesma direção: teste em ambiente de não produção antes, com o inventário real de quem lê e escreve cada tabela candidata, e confirme na documentação qual pedaço específico da feature ainda carrega rótulo de preview antes de prometer algo pra outro time.

## Vale a pena adotar?

Pra time que já sofre com necessidade real de transação atômica entre tabelas, hoje resolvida via job sequencial e reprocessamento manual quando algo falha no meio, ou que sofre com latência de metadado em tabela consultada com muita frequência, Catalog Commits ataca um problema estrutural de verdade, não é feature cosmética, e o fato de já estar em GA desde maio remove boa parte da hesitação natural de adotar algo em Beta. Pra quem já usa OpenSharing, streaming table com consumidor externo, ou depende de cluster single-user pra algum fluxo específico, vale mapear esses casos antes de ligar o flag. E pra quem sonha com engine totalmente externo escrevendo direto na tabela gerenciada sem depender da Databricks pra nada, ainda vale esperar essa parte específica sair do Beta antes de prometer isso pra produção.

## Referências

- Microsoft Learn, "Catalog commits - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/delta/catalog-commits
- Databricks Blog, "The Convergence of Open Table Formats and Open Catalogs: Catalog Commits is Generally Available": https://www.databricks.com/blog/convergence-open-table-formats-and-open-catalogs-catalog-commits-generally-available

#Databricks #UnityCatalog #DeltaLake #Governança
