---
title: "Migrar para serverless sem fechar os olhos: o agente que propõe mudança e aceita ser rejeitado"
date: 2026-11-20T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Serverless", "Lakeflow Jobs", "Agentes de IA"]
ShowToc: true
summary: "Genie Migrate for Serverless, em Beta, assume o trabalho repetitivo de migrar notebook e job de compute clássico para serverless: mapeia biblioteca, configuração do Spark e padrão de código incompatível, propõe cada mudança como diff individual e aplica num clone reversível antes de tocar no job original."
---

Migrar workload de compute clássico para serverless é, na teoria, uma troca de configuração. Na prática, é uma sequência de tentativa e erro: uma biblioteca que existia no cluster clássico não existe no ambiente serverless, uma configuração do Spark que fazia sentido antes simplesmente não se aplica, um modo de acesso incompatível aparece só quando o job já está rodando. Cada migração individual consome tempo desproporcional ao tamanho real do problema, e é exatamente por isso que tanta frota de cluster clássico simplesmente não migra, mesmo quando todo mundo sabe que deveria.

Genie Migrate for Serverless ataca esse atrito de um jeito específico: em vez de documentação prometendo que "a migração é simples", um agente faz o levantamento, propõe cada mudança individualmente, e aplica tudo num clone que pode ser descartado sem consequência se algo sair errado.

## O problema que a migração manual expõe

O levantamento da documentação lista três fontes recorrentes de falha na migração manual: incompatibilidade de modo de acesso, configuração do Spark que não se aplica no ambiente serverless, e biblioteca instalada no cluster clássico que simplesmente não existe do outro lado. Cada migração individual leva tempo demais justamente porque esses problemas só aparecem na execução, não na configuração, então a prática comum acaba sendo tentar, falhar, ajustar, tentar de novo, repetidas vezes, por job.

## O mecanismo em três etapas

O desenho do agente segue três princípios declarados: nenhuma quebra de produção, controle total sobre cada mudança proposta, e reversão limpa caso algo saia errado. Na prática isso se traduz em três fases.

Primeiro, avaliação: o agente varre notebook e job, classifica cada um como pronto agora, precisando de ação de admin, ou não pronto ainda (workload cuja fonte de verdade vive fora do workspace, como job de Databricks Asset Bundles ou notebook em pasta Git, ainda não pode ser migrado por essa via).

Segundo, tradução: cada mudança proposta aparece como diff lado a lado, rotulado, e nada é escrito até você aceitar. O agente mapeia configuração de cluster clássico para seleção de compute serverless, resolve lista de biblioteca contra o runtime serverless, carrega adiante configuração do Spark que ainda se aplica e sinaliza as incertas para sua decisão em vez de simplesmente remover, e reescreve código incompatível com Spark Connect, também como diff.

Terceiro, aplicação reversível: a tradução validada é aplicada num clone do job, sem interferir no original em execução. Você roda o clone sob demanda e, se estiver satisfeito, promove o clone para substituir o original, mantendo mesmo ID de job, agendamento e permissão. Se não promover, o original continua intacto. Importante notar que a validação de hoje é estática (coerência, resolução de biblioteca, aplicação limpa de configuração); uma validação em sandbox isolado, comparando saída do migrado contra o baseline clássico, ainda está planejada e não é o comportamento atual.

{{< figure src="compute-agent-slash-command.png" alt="Painel do Genie Code com o comando /compute digitado, mostrando a opção de autocompletar para migrar workloads para compute serverless" caption="O ponto de entrada da migração interativa: digitar /compute no Genie Code dentro do notebook ou job que se quer avaliar para serverless." >}}

## Mão na massa: migração em massa pela CLI

Para quem precisa migrar muitos jobs de uma vez, em vez de um por um dentro do Genie Code, o grupo de comando `compute-migrations` da Databricks CLI expõe o mesmo agente por script, com um fluxo de estado explícito que vale entender antes de automatizar:

```bash
# Inicia uma migração para um job específico
# (exige Databricks CLI 1.24.0 ou superior e preview "Compute Agent" habilitado)
databricks compute-migrations create -o json --request-id "$(uuidgen)" --json '{
  "asset_type": "JOB",
  "asset_uri": "jobs/482910",
  "auto_approve": false,
  "run_validation": false
}'

# Acompanha o estado até chegar em TRANSLATION_READY
databricks compute-migrations get <migration-id> -o json

# Depois de revisar o diff manualmente, aprova a tradução
databricks compute-migrations approve-migration-translation <migration-id> --etag <etag>

# Acompanha até MIGRATION_REVIEW e aprova a execução final,
# o que efetivamente substitui o job original pelo clone migrado
databricks compute-migrations approve-migration-execution <migration-id> --etag <etag>
```

Cada rejeição exige um motivo específico (`reject-migration-translation <id> "motivo" --etag <etag>`), e o agente revisa o clone de novo a partir desse feedback. O uso de `--etag` em cada comando não é burocracia gratuita: ele impede aprovar uma versão do plano que já ficou obsoleta porque alguém (ou o próprio agente) mudou o estado da migração entre a sua última leitura e a sua decisão.

**Na prática:** o ponto que merece atenção redobrada aqui é que a execução de validação (`run_validation: true`) não é isolada. O clone roda contra a mesma tabela, volume, checkpoint e sistema externo que o job original usa. Se o job escreve em tabela de produção ou dispara notificação, a execução de validação faz isso também, de verdade. Reserve essa opção só para job onde uma execução extra é genuinamente inofensiva, porque essa configuração não pode ser alterada depois que a migração é criada.

## O que isso não resolve

O agente propõe e aplica mudança aceita, mas não verifica se o resultado está correto. Validação hoje é estrutural, não semântica: confirma que a configuração resolve e que a biblioteca existe, não que a saída de dado do job migrado é idêntica à do job clássico. Isso precisa ser verificado manualmente antes de confiar em produção, principalmente em workload que grava em tabela crítica.

Também há uma lista real de bloqueio: imagem customizada, variante de ML Runtime, Databricks Runtime anterior à versão 13, dependência via JAR ou Maven, código em Scala ou R, todos ficam parados por padrão e exigem decisão explícita de seguir mesmo assim, aceitando o risco de a funcionalidade não migrada falhar depois. Job com mais de dez tarefas migráveis não pode ser migrado, e pela CLI, apenas job é suportado (notebook isolado ainda não), e job cuja fonte é um repositório Git remoto falha na migração. Workload cuja fonte de verdade é um Asset Bundle precisa reconciliar manualmente a mudança aplicada pelo agente de volta ao bundle, senão o próximo deploy sobrescreve a migração.

## Vale a pena adotar?

Vale, especialmente para quem tem uma frota grande de job clássico parada por pura falta de tempo de revisar cada um manualmente. O ganho real não é a migração em si, Spark já documenta isso manualmente há anos, o ganho é transformar o trabalho de "descobrir o que vai quebrar" de investigação manual em revisão de diff já pronto. Ainda assim, trate a promoção do clone como um deploy de produção normal: revise, valide a saída de dado você mesmo, e só depois descarte o job clássico original.

## Referências

- Databricks Blog, "Introducing Genie Migrate for Serverless": https://www.databricks.com/blog/introducing-genie-migrate-serverless
- Microsoft Learn, "Migrate from classic compute to serverless compute - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/compute/serverless/migration
- Microsoft Learn, "Connect to serverless compute - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/compute/serverless/

#AzureDatabricks #Serverless #GenieCode #LakeflowJobs
