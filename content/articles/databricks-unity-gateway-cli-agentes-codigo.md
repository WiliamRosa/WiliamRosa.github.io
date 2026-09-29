---
title: "Um comando abre o Claude Code, outro abre o Codex: como a Databricks centralizou governança de agente de código sem tirar a liberdade do dev"
date: 2026-09-25T09:00:00-03:00
draft: false
tags: ["Databricks", "Azure Databricks", "Unity Gateway", "Agentes de IA", "Governança"]
summary: "Unity Gateway CLI deixa o admin publicar uma configuração central de modelo, ferramenta MCP, skill e política de gasto pra agente de código, enquanto o desenvolvedor abre qualquer agente aprovado, Claude Code, Codex ou Gemini, com um comando único que já sincroniza tudo automaticamente."
ShowToc: true
---

Modelo de fronteira muda de melhor opção a cada poucos dias, e isso cria um dilema estrutural pra qualquer empresa que queira dar acesso a agente de código pro time inteiro. Travar num único provedor economiza dor de cabeça de governança, mas te deixa preso à opção de seis meses atrás quando surge algo melhor. Deixar cada time escolher livremente resolve o problema de estagnação, mas espalha orçamento, política de segurança e log de auditoria por um monte de sistema desconectado, cada agente de código com sua própria conta, seu próprio limite de gasto, sua própria cópia de segredo de acesso.

O Unity Gateway CLI ataca esse dilema de um jeito específico: centraliza a decisão de quais modelo, ferramenta e política valem, numa configuração publicada uma vez pelo administrador, e devolve pro desenvolvedor a experiência mais simples possível, um comando que abre o agente aprovado já configurado, sem instalação nem setup manual repetido a cada máquina.

## O que o comando único resolve de verdade

Depois que o admin instala e configura o dispositivo, abrir um agente de código vira questão de um comando: `ug claude` abre o Claude Code, `ug codex` abre o Codex, `ug gemini` abre o Gemini, cada um já carregando a configuração publicada centralmente, sem o desenvolvedor precisar saber qual modelo está por trás nem replicar chave de acesso manualmente. Adicionar ferramenta ou skill segue o mesmo padrão de simplicidade, `ug mcp add` registra um servidor MCP novo, `ug skills add` adiciona uma skill compartilhada, e `ug usage` mostra consumo sem precisar abrir um painel separado.

A sacada estrutural aqui não é a interface de linha de comando em si, é o que ela evita: sem esse ponto central, cada time acaba resolvendo autenticação, ferramenta e limite de gasto do próprio jeito, e a empresa perde visibilidade agregada exatamente na hora que mais precisa dela, quando o gasto com agente de código começa a escalar.

## Como o admin publica e o desenvolvedor sincroniza

A configuração central cobre agente habilitado e modelo padrão, servidor MCP disponível, skill compartilhada, e recurso de gateway como Smart Routing e rastreamento. O admin publica isso via interface, um editor JSON, ou via API, com uma chamada `POST` no endpoint de configuração de agente de código do Unity Gateway. Um exemplo de configuração, adaptado da documentação oficial:

```json
{
  "default_agent": "CODING_AGENT_CLAUDE_CODE",
  "enabled_agents": [
    {
      "agent": "CODING_AGENT_CLAUDE_CODE",
      "config": {
        "models": {
          "model_services": ["system.ai.claude-sonnet-4-6"]
        },
        "default_models": {
          "default_model": "system.ai.claude-sonnet-4-6"
        }
      }
    }
  ],
  "mcp_servers": {
    "names": ["main.developer_tools.github"]
  },
  "skills": {
    "names": ["main.team_skills.code_review"]
  }
}
```

O desenvolvedor nunca edita esse arquivo diretamente. Quando o admin atualiza a configuração publicada, a mudança sincroniza sozinha no próximo lançamento do agente, ou de forma explícita rodando `ug configure`. Isso significa que trocar o modelo padrão da empresa inteira, por exemplo quando sai uma versão nova que vale mais a pena, é uma mudança de configuração central, não uma campanha de comunicação pedindo pra cada time atualizar manualmente.

## Smart Routing e o corte de custo documentado

Smart Routing casa automaticamente o custo do modelo com a complexidade real da tarefa, em vez de rotear toda chamada pro modelo mais caro por padrão. O benchmark interno de codificação citado pela Databricks reportou 35% de redução de custo usando esse roteamento, e política de orçamento pode recomendar modelo mais barato como padrão automaticamente quando o gasto se aproxima de um limite configurado, uma proteção estrutural contra fatura surpresa no fim do mês.

**Na prática:** vale desconfiar de qualquer centralização que promete flexibilidade sem custo nenhum. Concentrar a decisão de modelo e ferramenta num único ponto de configuração resolve fragmentação, mas move a responsabilidade de manter isso atualizado pro admin, que agora precisa acompanhar ativamente qual modelo vale a pena permitir como padrão. Se essa atualização não acontecer com a mesma frequência que modelo novo aparece, a promessa de "sempre na melhor opção" vira, na prática, "preso na melhor opção de quando o admin lembrou de mexer na configuração".

## Rastreamento: de "onde foi meu token" pra tabela de lakehouse

Toda chamada de agente de código gera rastro que o Unity Gateway captura em tabela unificada do lakehouse, permitindo identificar token desperdiçado e falha de ferramenta de forma consultável, não só como log solto espalhado por cada provedor. O próprio time de engenharia da Databricks usou esse rastreamento combinado com Genie One pra encontrar desperdício estimado em 1,2 milhão de dólares por ano em token e hora de engenharia perdidos. Em escala de cliente real, um caso citado envolveu 61 bilhões de token de entrada em cerca de 360 mil requisição, com atribuição de custo centralizada permitindo saber exatamente qual time ou processo gerou qual parte do gasto.

## Mão na massa: instalando e publicando uma configuração

A instalação do CLI, feita uma vez por dispositivo, geralmente pelo próprio admin ou por um script de provisionamento:

```bash
uv tool install git+https://github.com/databricks/unity-gateway
ug --version
```

Depois de instalado e autenticado, o desenvolvedor só abre o agente aprovado:

```bash
ug claude
ug codex
```

E o admin, do lado da governança, publica ou atualiza a configuração central via API, sem exigir que nenhum desenvolvedor reinstale nada:

```bash
curl -X POST "https://<workspace-host>/api/ai-gateway/v2/coding-agent-configs" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d @coding-agent-config.json
```

## O que isso não resolve sozinho

O CLI não elimina a necessidade de alguém decidir ativamente qual modelo e qual ferramenta valem a pena permitir, ele só move essa decisão pra um lugar central em vez de deixar fragmentada. A sincronização no dispositivo do desenvolvedor depende de rodar `ug configure` ou de relançar o agente, não é instantânea em tempo real caso o admin publique uma mudança urgente. E Smart Routing só corta custo de verdade se a categorização de complexidade de tarefa fizer sentido pro seu workload real, um roteamento mal calibrado, mandando tarefa pesada pra modelo barato, criaria retrabalho que anularia o próprio ganho de custo que a feature promete.

## Vale a pena centralizar assim?

Pra empresa que já sente o sintoma clássico de agente de código espalhado, conta pessoal de cada dev, limite de gasto invisível até a fatura chegar, política de segurança inconsistente entre time, o Unity Gateway CLI ataca o problema certo, trocando fragmentação por um ponto único de configuração sem sacrificar a experiência do desenvolvedor no dia a dia. O ganho de 35% em roteamento e a economia de 1,2 milhão de dólares por ano documentada internamente são números concretos o suficiente pra justificar o teste, mas o resultado real depende de manter a configuração central ativamente curada, não é um ganho que se sustenta sozinho depois de configurado uma vez.

## Referências

- Databricks Blog, "Deploy and manage coding agents at scale with the Unity Gateway CLI": https://www.databricks.com/blog/deploy-and-manage-coding-agents-scale-unity-gateway-cli
- Databricks Docs, "Coding agent quickstart": https://docs.databricks.com/aws/en/ai-gateway/coding-agent-quickstart
- Databricks Docs, "Configure and govern coding agents": https://docs.databricks.com/aws/en/ai-gateway/coding-agent-configure-govern
- Unity Gateway, repositório oficial: https://github.com/databricks/unity-gateway

#Databricks #AzureDatabricks #UnityGateway #Governanca
