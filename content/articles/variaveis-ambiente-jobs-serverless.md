---
title: "Credencial direto no notebook virou coisa do passado: como funcionam as variáveis de ambiente em job serverless"
date: 2026-10-29T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Lakeflow Jobs", "Serverless", "Segurança"]
ShowToc: true
summary: "Variáveis de ambiente pra job serverless, em Beta, resolvem um problema que toda equipe de dado já tropeçou: configuração e credencial espalhada dentro do código do notebook. O mecanismo é mais rígido do que parece à primeira vista, sem herança entre entradas, sem leitura por UDF, e com precedência de valor bem definida entre arquivo e variável inline."
---

Todo mundo que já manteve notebook de produção conhece o padrão ruim: uma variável no topo do notebook definindo se é ambiente de teste ou produção, trocada manualmente antes de rodar, ou pior, um token de API colado direto no código porque "é só pra essa execução". Isso funciona até alguém esquecer de trocar a variável, ou até o notebook com o token vazar pra um repositório.

Variáveis de ambiente pra job serverless, ainda em Beta na Lakeflow Jobs, atacam esse problema resolvendo a separação entre configuração e código. A ideia central não é nova (toda plataforma de execução madura tem algo parecido), o que vale a pena entender é como o Azure Databricks desenhou o escopo e a precedência desse mecanismo especificamente.

## O mecanismo: entrada nomeada no job, seleção explícita por task

Variável de ambiente é definida no nível do job, não da task, mas cada task escolhe exatamente uma entrada pra usar. Uma entrada tem uma chave única e contém variável inline, caminho pra arquivo `.env`, ou os dois. Uma task que não declara `environment_variables_key` simplesmente não recebe variável nenhuma.

O detalhe que mais separa esse desenho de uma implementação ingênua: entradas nunca se combinam, e uma entrada não herda de outra. Se duas tasks do mesmo job precisam de nove das dez variáveis em comum e uma diferente, a opção é duplicar a entrada quase inteira duas vezes, não compor uma entrada base com uma extensão. É uma escolha deliberada de simplicidade sobre conveniência, provavelmente pra evitar o tipo de bug sutil que herança em cascata de configuração costuma gerar.

**Minha leitura:** essa ausência de herança pode parecer uma limitação chata à primeira vista, mas na prática evita uma classe inteira de bug difícil de rastrear, "essa task está usando valor que eu não declarei explicitamente nela, de onde ele veio". Em troca de um pouco de repetição na configuração, você ganha previsibilidade total sobre o que cada task efetivamente recebe.

## Mão na massa: configurando via Jobs API

A configuração via API deixa claro o vínculo entre task e entrada. Um job com duas tasks, cada uma com seu próprio conjunto de variáveis:

```json
{
  "name": "pipeline-com-variaveis-de-ambiente",
  "tasks": [
    {
      "task_key": "processar_pedidos",
      "notebook_task": {
        "notebook_path": "/Workspace/Shared/processar-pedidos"
      },
      "environment_key": "default",
      "environment_variables_key": "producao"
    },
    {
      "task_key": "gerar_resumo",
      "spark_jar_task": {
        "main_class_name": "com.empresa.resumo.Main"
      },
      "environment_key": "ambiente_resumo",
      "environment_variables_key": "vars_resumo"
    }
  ],
  "environments": [
    { "environment_key": "default", "spec": { "environment_version": "5", "dependencies": [] } },
    { "environment_key": "ambiente_resumo", "spec": { "environment_version": "5" } }
  ],
  "environment_variables": [
    {
      "environment_variables_key": "producao",
      "spec": {
        "variables": {
          "APP_ENV": "production",
          "REGION": "us-west-2",
          "SERVICE_TOKEN": "{{secrets/producao/token-servico}}"
        },
        "files": ["/Volumes/empresa/default/prod/execucao.env"]
      }
    },
    {
      "environment_variables_key": "vars_resumo",
      "spec": {
        "variables": { "APP_ENV": "production", "LOG_LEVEL": "INFO" }
      }
    }
  ]
}
```

Reparar no campo `SERVICE_TOKEN`: ele usa a sintaxe `{{secrets/<escopo>/<nome>}}` pra referenciar um secret já existente, em vez de colar o valor direto na configuração do job. O valor só é resolvido quando a task começa a rodar, usando a identidade "Run as" do job, e a configuração do job guarda só a referência, nunca o valor resolvido.

## O arquivo .env tem formato próprio, e ele é rígido de propósito

Pra variável carregada de arquivo, o formato aceito é simples na superfície mas não interpreta nada além do básico: uma variável por linha no formato `CHAVE=VALOR`, sem espaço antes do `=`, sem interpretação de aspas, sem escape, sem substituição de variável como `${OUTRA_VARIAVEL}`. Se você escrever `APP_ENV="production"` com aspas, a aspas vira parte literal do valor.

```text
# Arquivo execucao.env
APP_ENV=production
REGIAO=us-west-2
SAUDACAO=olá mundo
VALOR_OPCIONAL=
```

Quando a mesma variável aparece em mais de um lugar, a regra de precedência é direta: dentro de um arquivo, a última definição vale; entre arquivos, o arquivo listado depois sobrepõe o anterior; e variável inline sempre sobrepõe o que vier de qualquer arquivo. Essa ordem de precedência importa na prática porque é comum ter um arquivo `.env` compartilhado entre vários jobs e só uma ou duas variáveis inline específicas daquele job sobrescrevendo o padrão.

## O que isso não resolve

A lista de limitação é curta, mas cada item importa pra quem planeja adotar isso em escala. Função definida pelo usuário (UDF) não consegue ler variável de ambiente nenhuma, porque UDF roda dentro da lógica de execução do Spark, não no processo da task, então configuração que precisa chegar até uma UDF ainda depende do mecanismo antigo de passar parâmetro explícito. Só secret de nível de workspace é suportado por enquanto, secret do Unity Catalog ainda está "a caminho" sem data confirmada. E o limite de dez entradas de variável de ambiente por job, vinte variáveis inline por entrada, significa que um job com dependência de configuração muito granular pode esbarrar nesses tetos antes do esperado.

**Minha ressalva:** a documentação é honesta sobre um ponto que merece atenção redobrada, a redação de segredo em log é "melhor esforço", não garantia. Se o código da aplicação imprimir o valor do secret ou escrever ele em log, o valor pode aparecer em texto puro no log de execução do compute, mesmo que a saída do notebook mostre `[REDACTED]`. Isso significa que trocar credencial hardcoded por variável de ambiente resolve o problema de credencial no código-fonte, mas não resolve sozinho o problema de credencial vazando em log, se o código da aplicação não tomar esse cuidado à parte.

## Vale adotar?

Sim, especialmente pra quem hoje mantém múltiplas cópias de notebook só pra trocar uma configuração de ambiente, ou pra quem já foi pego de surpresa por um token esquecido dentro de célula de notebook. A ausência de herança entre entradas vai parecer repetitivo no começo, mas é um preço pequeno pela certeza de que cada task roda exatamente com a configuração que você declarou pra ela, nem mais nem menos.

## Referências

- Microsoft Learn, "Configure environment variables for serverless jobs - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/jobs/environment-variables
- Databricks Docs (AWS), "Environment variables": https://docs.databricks.com/aws/en/jobs/environment-variables
- Microsoft Learn, "Secret management - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/security/secrets/

#AzureDatabricks #LakeflowJobs #Serverless #Seguranca
