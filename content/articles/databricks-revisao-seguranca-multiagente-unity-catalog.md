---
title: "Revisão de segurança não precisa escolher entre rápido e criterioso: o padrão de sete agentes que a Databricks documentou"
date: 2026-09-25T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Agentes de IA", "Segurança", "Unity Catalog"]
summary: "A Databricks documentou como construiu um fluxo de revisão de segurança com sete agentes de responsabilidade estreita, orquestrados sobre Unity Catalog, Lakeflow Jobs e Databricks Apps, escalando caso de risco baixo automaticamente e escalonando pra revisor humano com evidência estruturada quando o risco é alto ou ambíguo."
ShowToc: true
---

Todo time de segurança que já cresceu o suficiente esbarra na mesma fila injusta: pedido rotineiro, de padrão já aprovado mil vezes, competindo pelo mesmo revisor especialista que também precisa avaliar o caso genuinamente novo e de risco real. Automatizar o rotineiro parece óbvio até você tentar, porque a linha entre "isso aqui é só burocracia" e "isso aqui precisa de julgamento humano" não é sempre clara na entrada da fila, só fica clara depois que alguém já investigou um pouco.

A Databricks documentou como resolveu isso internamente, não com um único agente genérico tentando decidir tudo sozinho, mas com sete agentes de responsabilidade estreita trabalhando em conjunto, cada um bom numa coisa só, orquestrados sobre a mesma base de governança que já protege o resto do dado da empresa.

## O problema que automação de regra fixa não resolve

Antes desse desenho, boa parte da automação de revisão de segurança em empresa grande é baseada em regra fixa, formulário com pergunta de sim ou não, roteando pra fila certa. Isso funciona bem pro caso mais óbvio, mas quebra rápido quando a pergunta certa depende de contexto que o formulário nunca capturou direito, tipo arquitetura da integração, tipo de dado envolvido, ou histórico de decisão parecida já tomada antes. O resultado prático é que revisor humano acaba gastando tempo em caso que já deveria estar resolvido, só porque o sistema de triagem não conseguiu captar nuance suficiente pra confiar na decisão automática.

## Sete agentes, cada um com responsabilidade estreita

O desenho documentado divide o problema em sete papéis específicos: um agente de intake conversa com quem está pedindo a revisão e coleta contexto estruturado; um agente de avaliação de risco atribui um nível de risco com evidência de apoio, sempre errando pro lado conservador quando em dúvida; um agente de requisitos mapeia o pedido pra padrão de segurança existente e gera requisito específico pra aquela arquitetura; agentes especializados tratam caso de nicho, como extensão de navegador ou avaliação de fornecedor externo; um agente de validação monta checklist item a item pra pedido de risco mais alto; um agente de fluxo cuida de follow-up, esclarecimento e escalonamento; e um agente de aprendizado analisa o feedback do revisor humano pra melhorar prompt e padrão ao longo do tempo.

Cada agente roda sobre um modelo dimensionado pro tamanho do problema, um modelo leve tipo Haiku pra classificação simples, um modelo intermediário tipo Sonnet pro raciocínio principal, e um modelo mais pesado tipo Opus só pra análise genuinamente complexa. Unity Catalog guarda padrão, pedido, evidência e decisão de forma governada, Lakeflow Jobs orquestra o fluxo em notebook sobre computação serverless, e Databricks Apps entrega tanto a interface conversacional de intake quanto um dashboard executivo de acompanhamento.

## O princípio que sustenta tudo: escalonamento conservador

O detalhe de design mais importante não é a divisão em sete agentes em si, é a regra que rege toda decisão automática: quando a evidência está faltando ou contraditória, o sistema não chuta. Ele assume o nível de risco mais conservador, pede esclarecimento específico, ou entrega o caso direto pro revisor humano. Só categoria de pedido pré-definida e bem entendida chega a completar via automação sem intervenção, e toda decisão precisa referenciar artefato concreto, documento de arquitetura, classificação de dado, confirmação de controle, em vez de aceitar afirmação solta de quem está pedindo.

Um exemplo prático dado na documentação: uma integração interna rotineira usando um padrão de single sign-on já aprovado gera requisito específico e verificável, tipo autenticar via provedor de identidade aprovado desabilitando credencial local, restringir escopo de acesso ao mínimo necessário com documentação, mandar log pra pipeline central, e confirmar classificação de dado antes de introduzir dado sensível. Quem pediu confirma cada item e anexa evidência; caso de risco baixo ou médio completa via automação, caso de risco alto ou ambíguo vai pro revisor humano já com resumo estruturado e evidência anexada, em vez de uma fila vazia esperando alguém investigar do zero.

**Minha leitura:** o que separa esse desenho de uma automação ingênua é justamente recusar decidir quando falta evidência, em vez de forçar uma resposta. É tentador, na hora de desenhar esse tipo de fluxo, otimizar pra maximizar quanto por cento vira automático. Esse desenho parece otimizar pro oposto, maximizar quanto revisor humano confia no que chega até ele, o que é a métrica que realmente importa quando o assunto é segurança.

## Mão na massa: esqueleto de um orquestrador multi-agente

O padrão de orquestrador multi-agente documentado pela Databricks pra esse tipo de caso segue uma estrutura replicável: cada subagente é declarado numa lista, com um tipo (Genie Agent, outro Databricks App, ou endpoint de model serving) e uma descrição que o próprio orquestrador usa pra decidir o roteamento. Adaptando esse padrão pro cenário de revisão de segurança:

```python
SUBAGENTS = [
    {
        "name": "risk_assessment",
        "type": "app",
        "endpoint": "security-risk-assessment-agent",
        "description": (
            "Avalia o nivel de risco de um pedido de revisao de seguranca, "
            "com evidencia de apoio. Use para classificar risco antes de "
            "decidir se o caso pode ser automatizado."
        ),
    },
    {
        "name": "requirements_mapper",
        "type": "app",
        "endpoint": "security-requirements-agent",
        "description": (
            "Mapeia um pedido para padrao de seguranca existente e gera "
            "requisito especifico para a arquitetura descrita."
        ),
    },
    {
        "name": "genie_audit_log",
        "type": "genie",
        "space_id": "<ID-DO-GENIE-SPACE-DE-AUDITORIA>",
        "description": (
            "Consulta historico de decisao de seguranca ja tomada, "
            "guardado em tabela governada do Unity Catalog."
        ),
    },
]

orchestrator = Agent(
    name="SecurityReviewOrchestrator",
    instructions=(
        "Voce coordena uma revisao de seguranca. Priorize sempre o "
        "caminho conservador: se a evidencia estiver incompleta ou "
        "contraditoria, escale para revisor humano em vez de decidir "
        "sozinho. Use risk_assessment antes de qualquer outra etapa."
    ),
    model="databricks-claude-sonnet-4-5",
    tools=subagent_tools,
)
```

O deploy segue o mesmo caminho de qualquer app de agente no Azure Databricks: declarar os recursos necessários, tipo o Genie Space (com permissão `CAN_RUN`) e o serving endpoint (com `CAN_QUERY`), em `databricks.yml`, rodar `databricks bundle validate` e `databricks bundle deploy`, e então `databricks bundle run` pra efetivamente subir o app. Um detalhe que a documentação da Microsoft destaca à parte: quando um subagente é outro Databricks App (o caso do agente de avaliação de risco e do agente de requisitos aqui), a permissão `CAN_USE` sobre esse app alvo não pode ser declarada como recurso do bundle, ela precisa ser concedida manualmente depois do deploy, via `databricks apps update-permissions`, usando o client ID (UUID) do service principal do orquestrador, não o nome de exibição, porque usar o nome de exibição falha silenciosamente sem conceder a permissão.

## O que esse desenho não resolve sozinho

O sistema só automatiza categoria de pedido já bem entendida e pré-definida, um tipo de caso genuinamente novo, sem padrão de segurança mapeado ainda, cai automaticamente na mão do revisor humano, o que é o comportamento certo, mas significa que o trabalho de mapear padrão novo continua sendo tarefa manual de especialista, o sistema não inventa padrão de segurança sozinho. O agente de aprendizado analisa feedback de revisor pra sugerir ajuste de prompt e padrão, mas a documentação não descreve isso como um loop totalmente automático, alguém com critério ainda precisa aceitar ou rejeitar cada sugestão antes dela virar comportamento novo do sistema. E o artigo original não divulga número absoluto de redução de tempo de ciclo ou de carga de revisor, só descreve a existência do dashboard executivo que acompanha isso, então quem for replicar o padrão deveria medir o próprio antes e depois, não assumir um ganho específico de antemão.

## Vale a pena adotar esse padrão?

O ganho real aqui não é eliminar revisor humano, é redistribuir onde o julgamento humano se concentra, tirando ele do caso óbvio e repetitivo e devolvendo pro caso que de fato precisa de critério. Isso exige investimento inicial real, mapear padrão de segurança existente pra formato que um agente consiga verificar item por item, e aceitar que caso ambíguo sempre vai continuar exigindo pessoa, não é um problema que a automação resolve com mais poder de modelo. Pra equipe de segurança que já sente esse gargalo, o desenho vale como referência de arquitetura, mas o trabalho de fundo, escrever requisito verificável por padrão de segurança, continua sendo o que decide se a automação vai ser confiável ou só rápida.

## Referências

- Databricks Blog, "How I built agent-based security reviews on Databricks": https://www.databricks.com/blog/how-i-built-agent-based-security-reviews-databricks
- Databricks Docs, "Build a multi-agent system on Databricks Apps": https://docs.databricks.com/aws/en/agents/agent-framework/multi-agent-apps
- Microsoft Learn, "Build a multi-agent system on Databricks Apps - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/agents/custom-agents/multi-agent-apps

#Databricks #AzureDatabricks #Agentes #Seguranca
