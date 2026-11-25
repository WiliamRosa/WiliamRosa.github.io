---
title: "Sua tag do Unity Catalog agora fala Iceberg: metadado de catálogo virando padrão aberto"
date: 2026-11-25T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Unity Catalog", "Apache Iceberg", "Governança"]
ShowToc: true
summary: "Tag Exchange, em Beta, expõe tag de tabela e coluna do Unity Catalog como labels dentro da resposta REST do Apache Iceberg, usando um campo opcional que a Databricks ajudou a adicionar ao padrão da comunidade. O resultado é que classificação de sensibilidade, domínio de negócio e outro metadado de catálogo deixa de morar só dentro de uma plataforma e passa a viajar com a tabela, pro motor, ferramenta ou agente que ler via Iceberg REST Catalog."
---

Toda empresa que usa mais de uma plataforma de dado conhece o mesmo problema: o contexto de negócio sobre uma tabela, quem é dono, pra que ela serve, qual coluna é sensível, fica preso na plataforma onde foi declarado primeiro. Ler a mesma tabela por outro motor de consulta, outra ferramenta de catálogo, ou um agente de IA que não tem acesso direto àquele catálogo original, significa recriar manualmente essa classificação, montar um pipeline próprio de sincronização de metadado, ou simplesmente aceitar que o agente vai operar sem esse contexto.

A Databricks, trabalhando junto da comunidade do Apache Iceberg, atacou esse problema de um jeito específico: em vez de mais uma integração proprietária, propôs e ajudou a implementar um campo opcional, `labels`, direto na resposta padrão do protocolo REST do Iceberg. A implementação da Databricks disso se chama Tag Exchange, agora em Beta.

## O mecanismo: um campo novo dentro de um protocolo que já existia

O Iceberg REST Catalog já definia como um cliente pede o carregamento de uma tabela (`LoadTable`). O que mudou é que essa resposta agora pode incluir um campo `labels`, contendo pares chave-valor de string tanto no nível da tabela (`object-labels`) quanto no nível de cada coluna, identificada pelo `field-id` do Iceberg, não pela posição física da coluna:

```json
{
  "labels": {
    "object-labels": {
      "domain": "finance"
    },
    "fields": [
      {
        "field-id": 3,
        "labels": {
          "pii": "ssn"
        }
      }
    ]
  }
}
```

O padrão define só o formato, não o vocabulário nem a interpretação: cada plataforma decide o que fazer com a chave `domain` ou `pii` que recebe. Isso é uma escolha deliberada de design, não uma lacuna. A Databricks implementa o lado de produção dessa troca expondo tag de tabela e coluna já existentes no Unity Catalog (incluindo tag de sistema, como `system.certification_status`) como esses labels, sempre que um cliente Iceberg pede a tabela via Iceberg REST Catalog.

## Mão na massa: da tag no Unity Catalog até o cliente Iceberg lendo o label

O fluxo começa com a tag sendo aplicada normalmente, via SQL do Unity Catalog:

```sql
ALTER TABLE unity.public.customers SET TAGS ('domain' = 'finance');
ALTER TABLE unity.public.customers ALTER COLUMN ssn SET TAGS ('pii' = 'ssn');
```

Do outro lado, um cliente Iceberg (Apache Iceberg 1.12.0 ou superior, que já suporta a API de labels) lê isso via chamada direta ao endpoint REST:

```bash
curl -X GET \
  -H "Authorization: Bearer $OAUTH_TOKEN" \
  -H "Accept: application/json" \
  "$DATABRICKS_HOST/api/2.1/unity-catalog/iceberg-rest/v1/catalogs/unity/namespaces/public/tables/customers"
```

Ou, de dentro de uma aplicação Spark com Iceberg, via Scala:

```scala
import scala.jdk.CollectionConverters._
import org.apache.iceberg.SupportsLabels
import org.apache.iceberg.spark.Spark3Util

val table = Spark3Util.loadIcebergTable(spark, "uc.public.customers")
val labels = table.asInstanceOf[SupportsLabels].labels()

labels.objectLabels().asScala.foreach { case (key, value) =>
  println(s"table: $key=$value")
}

labels.fields().asScala.foreach { field =>
  val column = table.schema().findColumnName(field.fieldId())
  field.labels().asScala.foreach { case (key, value) =>
    println(s"column $column: $key=$value")
  }
}
```

Pra habilitar o lado de produção no workspace, um admin precisa ativar "Tag Exchange via Iceberg REST Catalog" na página de Previews, além de ter acesso externo a dado habilitado por um admin de metastore, e o principal de leitura precisa das permissões `USE CATALOG`, `USE SCHEMA`, `SELECT` e `EXTERNAL USE SCHEMA`.

**Minha leitura:** o detalhe mais importante aqui, fácil de passar batido, é que o label é resolvido por `field-id` do Iceberg, não pela posição da coluna no schema. Isso importa porque schema de tabela muda com o tempo, coluna é adicionada e removida, e um motor que tentasse casar label por posição ordinal quebraria silenciosamente na primeira evolução de schema. Resolver pelo ID estável do campo é a decisão certa, mas também significa que qualquer implementação própria que você for escrever em cima disso precisa tratar o `field-id` como a chave de verdade, não a posição.

## Quem já está alinhado com o padrão

A lista de parceiro citada inclui Google Cloud, Salesforce, ClickHouse, Atlan, Collibra, DataHub, Immuta, Trust3 AI, PhoenixAI e Datastrato. O caso de uso mais concreto citado é de governança: uma plataforma de política como Trust3 AI consegue mapear um label de sensibilidade vindo do Unity Catalog direto pra uma regra de mascaramento definida localmente, sem precisar de um projeto de metadado separado só pra sincronizar essa classificação entre as duas ferramentas.

Vale notar que o PyIceberg (cliente Python do Iceberg) ainda não suporta leitura de label na versão atual, com suporte previsto pra versão 0.13, então quem depende de Python pra consumir esse metadado ainda precisa esperar esse release ou usar o caminho via Scala/Spark ou chamada REST direta.

## O que isso não resolve

O padrão define o formato do transporte, não a semântica. Duas plataformas podem usar a mesma chave `domain` com significado ligeiramente diferente, e nada no protocolo garante consistência de vocabulário entre elas, isso continua sendo acordo organizacional, não garantia técnica. A aplicação de política também continua sendo responsabilidade de cada plataforma receptora: o label chega, mas quem decide o que fazer com ele (mascarar, bloquear, só exibir) é a ferramenta do outro lado, não o Unity Catalog.

A documentação oficial também não detalha limite de tamanho de valor de label, latência de propagação entre uma mudança de tag no Unity Catalog e ela aparecer na resposta REST, nem lista quais outros catálogos, além do Unity Catalog, já emitem esse campo hoje.

**Minha ressalva:** sendo Beta e dependendo de uma feature relativamente nova da especificação Iceberg (1.12.0), eu trataria isso como uma aposta de interoperabilidade de médio prazo, não como substituto imediato de qualquer pipeline de sincronização de metadado que já funcione hoje entre suas ferramentas. Vale testar o fluxo de leitura num ambiente que não seja produção antes de desligar qualquer sincronização manual existente, porque o ecossistema de clientes que já sabe ler esse campo (PyIceberg incluso) ainda está se formando.

## Vale adotar?

Vale habilitar em Beta pra quem já opera múltiplas ferramentas de catálogo, governança ou agente de IA em cima do mesmo dado governado pelo Unity Catalog, e sente na pele o custo de manter sincronização manual de classificação entre elas. O ganho real não é técnico no sentido de performance, é organizacional: a tag vira um ativo que viaja com a tabela, em vez de um dado preso numa única ferramenta que outras equipes precisam redigitar. Pra quem só usa uma plataforma de catálogo hoje, o ganho é menor no curto prazo, mas vale acompanhar o padrão evoluir, porque interoperabilidade de metadado tende a importar mais à medida que mais agente de IA passa a consultar catálogo de fora do workspace de origem.

## Referências

- Databricks Blog, "Sharing catalog metadata across data platforms, engines, and agents": https://www.databricks.com/blog/sharing-catalog-metadata-across-data-platforms-engines-and-agents
- Databricks Docs (AWS), "Tag Exchange via Iceberg REST Catalog": https://docs.databricks.com/aws/en/external-access/tag-exchange
- Microsoft Learn, "Tag Exchange via Iceberg REST Catalog - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/external-access/tag-exchange
- Apache Iceberg, Pull Request #15750 (campo `labels` na resposta `LoadTable`): https://github.com/apache/iceberg/pull/15750
- Apache Iceberg Python (PyIceberg), Pull Request #4321 (suporte a leitura de catalog labels): https://github.com/apache/iceberg-python/pull/4321

#AzureDatabricks #UnityCatalog #ApacheIceberg #Governanca
