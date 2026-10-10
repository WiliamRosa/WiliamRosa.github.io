---
title: "Como a Concurrence governa IA clínica numa escala de 1,2 trilhão de tokens por ano com Unity Gateway"
date: 2026-09-24T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Unity Gateway", "Lakebase", "Saúde"]
summary: "A Concurrence consolidou documentação ambiente e resumo de plano de cuidado sobre Lakebase, Unity Catalog e Unity Gateway, processando hoje cerca de 100,8 bilhões de tokens de entrada e 11,2 milhões de chamadas de LLM por mês, taxa anualizada de 1,2 trilhão de tokens, crescimento de cinco vezes desde o fim de 2025."
ShowToc: false
---

Agente de IA em cenário clínico, documentação ambiente durante consulta, resumo de plano de cuidado, lida com informação que não pode simplesmente ser sobrescrita quando muda. A Concurrence, que constrói esse tipo de agente para fluxo voltado a paciente e a profissional de saúde, resolveu esse problema de um jeito específico: cada novo dado clínico entra como evento imutável, nunca sobrescrevendo o registro anterior, e o estado atual do paciente é derivado dessa história completa, preservando proveniência.

Sustentar esse padrão em produção, numa escala que já passa de 100 bilhões de tokens de entrada por mês, exigiu consolidar peças que normalmente vivem espalhadas: Lakebase guarda estado operacional de agente e de conversa, Unity Catalog governa dado e ativo de IA, e Unity Gateway concentra acesso e segurança de modelo num único ponto de controle.

Detalhes técnicos do caso:

- Volume atual: cerca de 100,8 bilhões de tokens de entrada e 11,2 milhões de chamadas de LLM a cada 30 dias, taxa anualizada de aproximadamente 1,2 trilhão de tokens de entrada
- Esse volume cresceu cerca de cinco vezes desde o fim de 2025
- Dado clínico novo é registrado como evento imutável, não como atualização que sobrescreve o estado anterior, o estado atual do paciente é derivado dessa história de eventos
- O monitoramento de uso (modelo em uso, consumo de token, taxa de cache, gasto por pessoa e por time) vem direto de system table do Databricks, sem ferramenta externa de observabilidade paralela

**Minha ressalva:** escala grande de token por si só não prova que a arquitetura está correta, prova que ela aguenta carga. O ponto que realmente importa no caso é a escolha de modelar dado clínico como log de evento imutável em vez de registro mutável, porque isso é decisão de design que precisa ser tomada antes do sistema crescer, não depois. Quem está desenhando agente clínico sobre Lakebase deveria prestar atenção nessa escolha de modelagem antes de se impressionar com o número de tokens por mês.

**Fonte:** https://www.databricks.com/blog/how-concurrence-governs-clinical-ai-trillion-token-scale-unity-gateway

#AzureDatabricks #UnityGateway #Lakebase #Saude
