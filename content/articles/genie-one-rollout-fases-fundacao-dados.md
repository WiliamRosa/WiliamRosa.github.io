---
title: "O rollout do Genie One que funciona começa nos dados, não na comunicação interna"
date: 2026-09-29T09:00:00-03:00
draft: false
tags: ["Databricks", "Genie One", "Azure Databricks", "Governança"]
summary: "A maioria dos guias de adoção de IA generativa fala de comunicação, treinamento e gestão de mudança. O que realmente decide se um rollout de Genie One dá certo é uma sequência técnica bem mais concreta, que começa em Domains, Metric Views e Pages, muito antes de qualquer usuário piloto entrar na tela."
ShowToc: true
---

Todo projeto de adoção de assistente de dado tem o mesmo roteiro de kickoff: comunicado interno, treinamento de usuário, campanha de "vem experimentar a nova ferramenta". E toda empresa que já tentou isso sem preparar o dado primeiro teve a mesma decepção: o assistente responde bonito na demonstração e erra feio na primeira pergunta de negócio real, porque não havia contexto governado nenhum por trás da resposta.

A Databricks publicou um playbook de rollout do Genie One organizado em fases, e a parte que interessa não é a seção de comunicação (isso qualquer manual de gestão de mudança já cobre), é a sequência técnica específica que precisa estar pronta antes de qualquer usuário final ver a tela de chat.

## A ordem importa: dado primeiro, gente depois

O erro mais comum em rollout de assistente de dado é inverter a ordem: abrir acesso pra usuário amplo e só depois tentar curar o contexto que o assistente usa pra responder. Isso garante uma primeira impressão ruim, porque as primeiras perguntas reais vão bater em lacuna de contexto que ninguém viu vir.

A sequência que faz sentido tecnicamente é o oposto: primeiro modelar um núcleo pequeno e correto de contexto de negócio, testar isso com um grupo fechado, e só então expandir acesso e integração. Cada fase tem entregável técnico específico, não é etapa de cronograma genérico.

## Fase 0: a fundação que ninguém vê, mas que decide tudo depois

Antes de qualquer usuário piloto logar, quatro peças de Unity Catalog semantics precisam existir:

**Domains**, que agrupam ativo de dado por propósito de negócio, não pela estrutura do time que constrói cada peça. É a camada de organização que faz o Discover fazer sentido pra quem não é do time de dados.

**Metric Views**, cobrindo de 10 a 20 números que realmente importam pro negócio, não o catálogo inteiro de métrica possível. É melhor ter poucas métricas certificadas e corretas do que uma cobertura ampla e inconsistente.

**Pages**, com definição de conceito crítico, termo ambíguo ou sigla interna que o time de negócio usa no dia a dia. Cada Page vira uma fonte que o Genie One prioriza e cita quando responde.

Junto com isso, dois pré-requisitos de plataforma: provisionar o usuário piloto no nível de conta usando o entitlement de Consumer access (que dá acesso ao Genie One sem exigir licença completa de workspace, útil justamente pra manter o piloto pequeno e barato antes de decidir expandir), e habilitar tanto os Ontology Snippets (o contexto inferido automaticamente que complementa Domains, Metric Views e Pages) quanto o Unity Gateway, que passa a intermediar e governar as chamadas de modelo por trás do assistente.

Vale notar que Consumer access e a licença completa de workspace não são a mesma permissão nem dão o mesmo alcance: quem só tem Consumer access consegue perguntar ao Genie One e ver resposta, mas não cria Genie Agent nem edita Domain, Metric View ou Page. Isso é intencional nessa fase, o piloto deve validar se a resposta é boa, não virar canal de gente configurando contexto sem a curadoria combinada.

## Mão na massa: instrução de workspace como parte da fundação

Uma peça que costuma ficar de fora do escopo de "fundação de dado" mas que também é técnica, não é comunicação: instrução de workspace aplicada a toda conversa do Genie One. Ela existe como um arquivo Markdown dentro do próprio workspace:

```
/Workspace/.genie_workspace_instructions.md
```

O conteúdo desse arquivo (limite de 20.000 caracteres) é lido automaticamente pelo chat, sem configuração adicional, e pode registrar convenção de dado da empresa, terminologia preferida, ou regra de como o assistente deve se comportar diante de determinado tipo de pergunta. Um exemplo de conteúdo razoável pra essa fase inicial:

```markdown
# Instruções de workspace, Genie One

- Valores monetários sempre em BRL, salvo pedido explícito de outra moeda.
- "Receita" sem qualificação se refere a receita líquida, não bruta.
- Ano fiscal começa em fevereiro, não em janeiro.
- Ao citar Metric View, sempre linkar a definição da Page correspondente quando existir.
```

Isso não substitui Pages nem Metric Views, mas fecha um tipo de ambiguidade que nenhuma das duas resolve sozinha: convenção operacional que se aplica à conversa inteira, não a um conceito específico.

**Minha leitura:** essa fase 0 é exatamente o tipo de trabalho que fica invisível quando dá certo e catastrófico quando é pulado. Ninguém vai elogiar publicamente o time que passou duas semanas modelando dez Metric Views antes de abrir o piloto, mas todo mundo vai notar quando o assistente responde errado na primeira demonstração pro board.

## Fase de expansão: identidade, integração, escala

Só depois da fundação validada com o piloto é que faz sentido a segunda onda: habilitar gestão automática de identidade (pra sincronizar usuário e grupo de forma automática em vez de provisionamento manual pessoa por pessoa), abrir a integração com aplicativo móvel iOS/Android, e conectar o Genie One a superfície onde o usuário de negócio já trabalha, Slack, Teams, Excel, Google Sheets. Nessa fase, também entram decisão de permissão por grupo (não usuário individual), column masking aplicado onde já existe dado sensível catalogado, e log de auditoria ativado desde o primeiro dia de acesso amplo.

## O que isso não resolve

O playbook é honesto sobre uma limitação: ele não ensina como escrever a semântica em si, quais tabelas de fato pertencem a qual Domain, como redigir a definição certa de uma Page ambígua, isso continua sendo trabalho de curadoria humana que nenhuma sequência de fase substitui. Também não há benchmark de acurácia esperado nem orientação de quando um Genie Agent está "pronto o suficiente" pra sair do piloto, essa decisão fica com quem opera. E o rollout bem-sequenciado resolve o problema de primeira impressão, mas não resolve manutenção contínua: cada Metric View e Page nova que entra depois do piloto precisa da mesma disciplina de curadoria que a fundação recebeu, ou a qualidade da resposta volta a variar dependendo de qual parte do negócio pergunta.

## Vale seguir essa sequência à risca?

Não como receita rígida, mas como princípio, sim. O ponto central é simples de enunciar e fácil de ignorar sob pressão de prazo: nenhuma quantidade de comunicação interna ou treinamento de usuário compensa contexto de negócio mal modelado. **Na prática:** se o cronograma de rollout tem mais linha de item sobre comunicação do que sobre Domains, Metric Views e Pages, provavelmente a ordem das prioridades está invertida.

## Referências

- Databricks Docs, "Domains and subdomains": https://docs.databricks.com/aws/en/uc-semantics/domains
- Microsoft Learn, "Domains and subdomains - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/uc-semantics/domains
- Databricks Docs, "Unity Catalog metric views": https://docs.databricks.com/aws/en/uc-semantics/metric-views/
- Microsoft Learn, "Unity Catalog metric views - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/uc-semantics/metric-views/
- Databricks Docs, "Pages": https://docs.databricks.com/aws/en/uc-semantics/pages
- Microsoft Learn, "Pages - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/uc-semantics/pages
- Microsoft Learn, "Chat in Genie One - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/genie-one/chat
- Microsoft Learn, "Genie Ontology - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/genie/genie-ontology
- Databricks Blog, "How to roll out Genie One: A step-by-step enterprise playbook": https://www.databricks.com/blog/how-roll-out-genie-one-step-step-enterprise-playbook

#Databricks #GenieOne #AzureDatabricks #Governanca
