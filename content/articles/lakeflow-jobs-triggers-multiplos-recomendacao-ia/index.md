---
title: "Seu job no Lakeflow pode ter até cinco triggers agora: vale a pena ou é só mais botão para configurar?"
date: 2026-11-14T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Lakeflow Jobs", "Orquestração", "Beta"]
ShowToc: true
summary: "Lakeflow Jobs ganhou suporte Beta a múltiplos triggers no mesmo job, recomendação de trigger via IA baseada em linhagem e histórico de execução, e um trigger de atualização de tabela com controle fino de tempo entre disparos. O que cada peça resolve de verdade e onde a complexidade extra pode voltar a te morder."
---

A forma mais comum de disparar um job de dados ainda é o cron: roda às 2h da manhã, torcendo para que os dados upstream já tenham chegado. Quando chegam atrasados, o job roda em cima de dado incompleto. Quando chegam cedo, o job fica horas esperando sem necessidade. É uma solução que funciona até o dia em que não funciona, e a correção mais comum, apertar o intervalo do cron, só reduz a chance do problema, não elimina ela.

O Lakeflow Jobs vinha resolvendo isso aos poucos com trigger de atualização de tabela e trigger de chegada de arquivo. O que mudou recentemente foi juntar várias dessas peças: um job agora pode ter mais de um trigger ativo ao mesmo tempo, e o próprio Azure Databricks pode sugerir qual trigger configurar, com base na linhagem de dado que o job já usa.

## O catálogo de triggers disponível hoje

Vale situar o que já existe antes de falar do que é novo. Um job no Lakeflow pode disparar por agendamento baseado em tempo, por atualização de tabela de origem no Unity Catalog, por chegada de arquivo novo num local de armazenamento monitorado, pela criação ou atualização de um modelo no Unity Catalog (em Beta), pela conclusão de um ou mais jobs upstream com resultado específico (também em Beta), de forma contínua, disparando uma nova execução sempre que a anterior termina, ou manualmente, sem trigger automático nenhum. Scheduled, table update, file arrival, model update, job completion, continuous, manual: sete formas diferentes de decidir quando um job deve rodar, cada uma resolvendo um cenário de dependência distinto.

## O que é novo: mais de um trigger no mesmo job

A novidade concreta é suporte Beta a múltiplos triggers simultâneos num mesmo job, até cinco durante o período Beta, de tipos iguais ou diferentes. O caso de uso mais direto é redundância: usar um trigger de atualização de tabela para rodar assim que o dado estiver pronto, e um trigger agendado como plano B, caso a atualização da tabela não aconteça dentro do esperado. Outro caso é cobertura: múltiplos triggers de chegada de arquivo monitorando locais de armazenamento diferentes que alimentam o mesmo job.

Cada trigger pode ser pausado e retomado de forma independente dos outros. A única combinação proibida é misturar trigger contínuo com qualquer outro, porque um job contínuo já está, por definição, sempre rodando. Na API de Jobs 2.1 ou superior, isso é configurado através de um array `triggers` em `JobSettings`, e um detalhe de comportamento que vale anotar: atualizar esse campo substitui o array inteiro, não faz merge incremental com o que já existia.

## Recomendação de trigger via IA

A segunda peça nova é mais sutil: quando um job não tem trigger nenhum configurado, a seção de triggers pode sugerir até dois, com base no conteúdo do job e das tarefas, nas tabelas upstream identificadas por linhagem, e no histórico recente de execução. Se o job lê de uma tabela específica do Unity Catalog, a recomendação natural é um trigger de atualização daquela tabela.

Essa recomendação só aparece sob condições específicas: os recursos assistivos de IA do Azure Databricks precisam estar habilitados no workspace (e não dá para desligar só a recomendação de trigger isoladamente), você precisa ter permissão CAN MANAGE ou IS OWNER no job, o job não pode estar implantado via Databricks Asset Bundles, e precisa haver evidência suficiente no código ou na linhagem do job para sustentar a sugestão. Cada recomendação vem com explicação curta, e três ações possíveis: aplicar direto, refinar a sugestão dentro do Genie Code, ou descartar (descarte fica só no navegador onde você descartou, não é global).

## Mão na massa: controlando a cadência de um trigger de atualização de tabela

O trigger de atualização de tabela ganhou dois controles de tempo que resolvem um problema prático: tabela que atualiza várias vezes por hora dispararia o job repetidamente sem necessidade, e tabela escrita em lote ao longo de alguns minutos poderia disparar o job antes da escrita terminar. **Minimum time between triggers** limita a frequência de disparo, **wait after last change** espera a escrita realmente terminar antes de rodar.

{{< figure src="schedules-and-triggers.png" alt="Menu de Schedules and Triggers na interface do Lakeflow Jobs, mostrando as opções para configurar um trigger de atualização de tabela" caption="O ponto de configuração de um trigger na interface: selecionar o tipo, a tabela de origem e os controles de tempo entre disparos." >}}

Para quem configura isso via API em vez da interface, uma representação ilustrativa de como ficaria um array `triggers` combinando redundância (atualização de tabela com plano B agendado), escrita aqui a partir da documentação de referência e não copiada de nenhum exemplo de terceiro:

```json
{
  "triggers": [
    {
      "table_update": {
        "table_names": ["main.vendas.pedidos_atualizados"],
        "condition": "ANY_UPDATED",
        "min_time_between_triggers_seconds": 3600,
        "wait_after_last_change_seconds": 300
      }
    },
    {
      "periodic": {
        "interval": 1,
        "unit": "HOURS"
      }
    }
  ]
}
```

Nesse desenho, o trigger de atualização dispara assim que a tabela `pedidos_atualizados` muda, respeitando no máximo um disparo por hora e esperando cinco minutos depois da última escrita antes de rodar. O trigger agendado por hora funciona como rede de segurança, caso a atualização da tabela simplesmente não aconteça dentro de uma janela razoável.

**Minha leitura:** a redundância entre triggers resolve um problema real, mas troca ele por outro, menor: depurar por que um job rodou deixa de ser trivial quando existem cinco triggers ativos ao mesmo tempo. A interface mostra qual trigger disparou cada execução, o que ajuda, mas vale o cuidado de documentar, fora da própria configuração do job, por que cada trigger redundante existe, porque depois de alguns meses fica fácil esquecer qual era o motivo original de ter dois triggers cobrindo o mesmo cenário.

## O que isso não resolve

O limite de 12.000 triggers ativos por workspace, somando todos os jobs e tipos, parece alto até uma organização grande com centenas de pipeline perceber que múltiplos triggers por job multiplicam esse consumo rapidamente. A recomendação de trigger via IA, por sua vez, não funciona para job implantado via Databricks Asset Bundles, que é justamente o padrão mais comum de implantação madura, então quem já automatizou o deploy de job perde esse recurso específico até que o suporte seja ampliado. E a recomendação depende de evidência suficiente no código e na linhagem: job com lógica pouco convencional ou sem histórico de execução recente simplesmente não recebe sugestão nenhuma, silenciosamente.

## Vale a pena configurar?

Vale, com moderação. Trigger de atualização de tabela, sozinho, já resolve a maior parte do problema de guesswork de cron para quem tem dependência clara entre tabelas. Múltiplos triggers valem a pena como rede de segurança explícita, não como hábito padrão em todo job, porque cada trigger adicional é mais uma peça para entender quando algo não dispara como esperado. A recomendação via IA é um bom ponto de partida para quem está configurando um job do zero, mas vale revisar a sugestão com o mesmo cuidado que se revisaria uma sugestão de um colega: ela pode estar certa na maioria das vezes e ainda assim errar justamente no seu caso específico.

## Referências

- Microsoft Learn, "Automate jobs with schedules and triggers - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/jobs/triggers
- Databricks Blog, "Announcing Table Update Triggers for Lakeflow Jobs": https://www.databricks.com/blog/announcing-table-update-triggers-lakeflow-jobs

#AzureDatabricks #LakeflowJobs #Orquestracao #Beta
