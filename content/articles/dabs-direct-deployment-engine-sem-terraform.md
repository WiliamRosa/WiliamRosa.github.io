---
title: "Seu bundle do Databricks parou de gerar Terraform por baixo: o que muda com o Direct Deployment Engine"
date: 2026-08-26T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "DABs", "CI/CD", "Databricks CLI"]
ShowToc: true
summary: "Databricks Asset Bundles trocou o motor de deploy baseado em provider Terraform por um motor direto, que chama a API REST via Go SDK. Deploy até 40% mais rápido, plano reexecutável e mais tipo de recurso suportado, mas também um comportamento diferente para campo removido da configuração e uma migração automática que já está acontecendo silenciosamente em pipeline de CI/CD que ninguém revisou ainda."
---

Quem já tentou rodar `databricks bundle deploy` atrás de um proxy corporativo, ou numa rede com firewall restritivo para registry externo, conhece a dor específica: o provider Terraform do Databricks precisa ser baixado de um registry, e qualquer bloqueio nessa cadeia transforma um deploy simples em uma sessão de depuração de rede. Esse não era o único problema do motor baseado em Terraform, mas era o mais visível para quem opera em ambiente corporativo fechado.

A resposta da Databricks foi trocar o motor por baixo dos panos: Databricks Asset Bundles agora tem um motor de deploy direto, que fala com a API REST do Databricks através do Go SDK, sem gerar configuração Terraform intermediária nenhuma. A troca não é cosmética, ela muda comportamento real em pontos específicos que vale conhecer antes do seu pipeline de CI/CD ser migrado sem aviso.

## O que motivou a troca

A lista de ganho declarada é concreta: deploy até 40% mais rápido, validação e planejamento mais detalhados (um `bundle plan -o json` relata, por campo, o que motivou cada ação específica), planos reexecutáveis (`bundle deploy --plan plan.json` executa um plano calculado antes, garantindo que só ação já aprovada chega em produção, e pulando o recálculo do plano para ganhar velocidade), configuração mais simples (sem o problema de firewall, proxy ou registry de provider customizado), suporte a mais tipo de recurso (catálogo, external location, endpoint de busca vetorial, Genie Agent, entre outros), e a opção de implantar em pasta imutável e somente leitura para proteção contra adulteração.

## O mecanismo, sem o jargão do Terraform

A diferença central de desenho é onde o estado da implantação vive. O motor Terraform mantém um único estado misturando configuração local e estado remoto. O motor direto separa isso: o arquivo de estado guarda só a configuração local, nunca o estado remoto misturado.

Isso tem uma consequência direta no cálculo de diferença entre o que você quer implantar e o que já está implantado, que passa a acontecer em duas etapas independentes: primeiro, a configuração local do bundle é comparada contra a configuração que foi usada na última implantação (sem envolver o estado remoto nessa etapa); segundo, o estado remoto atual é comparado contra essa mesma configuração da última implantação. O resultado prático de separar essas duas comparações é que mudança no `databricks.yml` nunca é ignorada, sempre dispara atualização, e campo que a implementação do motor direto ainda não trata explicitamente não gera erro de inconsistência, o recurso é implantado mesmo assim, o que pode gerar drift silencioso até o próximo plano ou deploy reconciliar.

## Mão na massa: ativando e usando o motor direto

A partir da CLI do Databricks 1.3.0, bundle novo já nasce usando o motor direto por padrão. Para fixar isso explicitamente, ou migrar um bundle existente, duas formas equivalentes:

```yaml
# databricks.yml
bundle:
  engine: direct
```

```bash
# Alternativa via variável de ambiente, útil em pipeline de CI/CD
# onde você não quer alterar o arquivo de configuração versionado
DATABRICKS_BUNDLE_ENGINE=direct databricks bundle deploy -t producao
```

Para quem já tem bundle rodando no motor Terraform e precisa migrar o estado, o comando dedicado converte o arquivo de estado do Terraform (`terraform.tfstate`) para o formato do motor direto (`resources.json`):

```bash
# Converte o estado existente antes do primeiro deploy
# com o motor direto, evitando recriar recurso já existente
databricks bundle deployment migrate -t producao

# Depois da migração, um plano detalhado confirma
# que nada será recriado sem necessidade
databricks bundle plan -t producao -o json
```

Vale revisar a saída desse `bundle plan` com atenção antes do primeiro deploy pós migração, justamente porque o cálculo de diferença muda de lógica entre os dois motores, e um campo que o Terraform tratava de um jeito pode ser interpretado de forma diferente pelo motor direto na primeira execução.

## Diferenças de comportamento que pegam desavisado

Duas mudanças de comportamento merecem destaque especial porque não são óbvias à primeira vista. A primeira: remover um campo do `databricks.yml` no motor Terraform deixa o valor remoto como estava, porque o Terraform só gerencia campo explicitamente presente na configuração; no motor direto, remover um campo reverte o valor para o padrão do recurso na próxima implantação, porque a comparação é contra a configuração anterior, e campo ausente conta como mudança. Quem confiava no comportamento antigo para "congelar" um valor configurado uma vez e depois remover do arquivo precisa agora manter esse valor explícito permanentemente.

A segunda: resolução de substituição de recurso (`${resources.jobs.meu_job.id}`) também muda de lógica, resolvendo primeiro contra campo presente na configuração local, e só recorrendo ao estado remoto para campo ausente localmente. Normalmente isso é transparente, mas em configuração que depende de campo computado remotamente sem estar espelhado localmente, o resultado da substituição pode vir de um lugar diferente do que vinha antes.

**Minha leitura:** o detalhe que mais deveria preocupar quem opera pipeline de CI/CD em escala é que essa migração, a partir da CLI 1.14, acontece automaticamente no deploy, sem que ninguém precise pedir. Isso é conveniente para quem só quer que funcione, e arriscado para quem tem pipeline crítico que nunca testou explicitamente o comportamento do motor direto contra sua configuração real. Migração automática silenciosa é o tipo de mudança que vale testar deliberadamente num ambiente de homologação antes dela acontecer sem aviso em produção.

## O que isso não resolve

A lista de recurso que só existe no motor direto (política de cluster, catálogo, external location, secret, feature view, pool de instância, execução de job, conjunto de materialização, endpoint de busca vetorial, serviço MCP, serviço de provedor de modelo, serviço de modelo, agenda de snapshot do Postgres, entre outros) é, ao mesmo tempo, o argumento mais forte a favor da migração e um lembrete de que o motor Terraform já está perdendo paridade de recurso, não só perdendo popularidade. Ficar no motor Terraform por mais tempo do que necessário significa ficar de fora desses recursos.

Vale notar também que o próprio motor Terraform já foi removido nas versões mais recentes da CLI: a partir da versão 1.20.0, a CLI ainda consegue migrar automaticamente bundle com estado Terraform, mas se essa automigração falhar, o deploy é simplesmente abortado, sem fallback. Quem não pode migrar agora, por alguma dependência de recurso ainda não suportado no motor direto, precisa fixar explicitamente a versão da CLI em 1.19 para continuar usando Terraform, e isso é uma decisão com prazo de validade, não uma solução permanente.

## Vale a pena migrar agora?

Vale planejar a migração com antecedência, não vale deixar ela acontecer sozinha na próxima atualização da CLI. **Na prática:** rode `bundle plan -o json` contra seu bundle real antes de qualquer deploy pós migração, revise especificamente campo que você já removeu da configuração em algum momento esperando que o valor remoto permanecesse, e teste a migração num ambiente que não seja produção primeiro. O ganho de velocidade e de cobertura de recurso é real, mas é um ganho que vale colher de forma deliberada, não como efeito colateral de uma atualização de CLI que ninguém revisou com calma.

## Referências

- Microsoft Learn, "Migrate to the direct deployment engine - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/dev-tools/bundles/direct

#AzureDatabricks #DABs #CICD #DatabricksCLI
