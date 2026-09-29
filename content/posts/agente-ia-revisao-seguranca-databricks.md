---
title: "Sete agentes especializados, não um só, é como esse time reduziu revisão de segurança de dias para minutos"
date: 2026-09-25T15:00:00-03:00
draft: true
tags: ["Databricks", "Agentes de IA", "Unity Catalog", "Segurança", "MLflow"]
summary: "Um engenheiro da Databricks construiu um sistema de revisão de segurança com sete agentes especializados (intake, risco, requisitos, revisão dedicada, validação, workflow e aprendizado) rodando sobre Unity Catalog, Foundation Models e Lakeflow Jobs, reduzindo pedido de rotina de dias para minutos sem tirar humano da decisão final."
ShowToc: false
---

Revisão de segurança costuma travar em duas pontas: pedido simples que devia ser rápido e não é, e pedido complexo que exige julgamento humano e não pode ser automatizado.

Foi esse o problema que Angel De Leon, engenheiro da Databricks, decidiu atacar construindo um sistema de revisão automatizada para lidar com a triagem e avaliação previsível, deixando o caso novo, de alto risco ou ambíguo para o revisor humano de verdade. Em vez de um agente genérico tentando cobrir tudo, a arquitetura usa sete agentes especializados: um de intake que conversa com quem solicita e coleta contexto, um de avaliação de risco que atribui um nível com evidência de apoio, um de requisitos que mapeia o pedido aos padrões aplicáveis, agentes de revisão dedicados para tipos específicos (como extensão de navegador ou avaliação de fornecedor), um de validação que monta checklist para pedido de risco mais alto, um de workflow que cuida de follow-up e escalonamento, e um de aprendizado que refina prompt e padrão com base no feedback do revisor humano.

A base técnica por trás dos sete agentes usa Unity Catalog como camada de dado governada, guardando padrão de segurança, pedido, evidência, decisão e saída do sistema com permissão e lineage unificados; Foundation Models hospedados no Databricks (Claude Haiku para classificação leve, Sonnet para revisão padrão, Opus para raciocínio complexo) cuidam da classificação, avaliação de risco e redação de requisito; Lakeflow Jobs orquestra o fluxo em notebook sobre compute serverless, movendo cada pedido entre etapas; e Databricks Apps sustenta tanto a interface conversacional de intake quanto um dashboard executivo de acompanhamento.

Pontos técnicos que valem registrar:
- O sistema só automatiza classes de pedido predefinidas, exige evidência concreta para decisão e escala pra humano sempre que a informação é incompleta ou contraditória
- O modelo usado varia por complexidade da tarefa: Haiku para classificação leve, Sonnet para revisão padrão, Opus para raciocínio mais complexo
- O tempo de ciclo de pedido de rotina caiu de dias para minutos, com dashboard alimentado por registro operacional, não por reconciliação manual
- O agente de aprendizado ajusta prompt e padrão com base em feedback real de revisor humano, fechando um loop de melhoria contínua

**Minhas considerações:** o detalhe que mais vale reter aqui não é a automação em si, é a decisão de dividir o problema em sete agentes estreitos em vez de um só genérico tentando cobrir intake, risco, requisito e validação ao mesmo tempo. Multiagente estreito tende a ser mais fácil de auditar e de corrigir isoladamente quando algo sai errado do que um agente monolítico fazendo de tudo, e isso importa ainda mais numa área como revisão de segurança, onde uma decisão errada tem custo real. A frase do próprio autor resume bem o limite que qualquer implementação parecida deveria respeitar: automação opera dentro de regras definidas por humano, e a decisão final continua sendo humana.

**Fonte:** https://www.databricks.com/blog/how-i-built-agent-based-security-reviews-databricks

#Databricks #AgentesIA #Seguranca
