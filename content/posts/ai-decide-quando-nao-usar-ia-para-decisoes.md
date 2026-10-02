---
title: "ai_decide é rápido o suficiente para qualquer loop, mas isso não significa que deveria estar em todos"
date: 2026-10-02T12:00:00-03:00
draft: false
tags: ["Databricks", "AI Functions", "Model Serving", "Arquitetura"]
summary: "O Databricks MVP Sudhir Gajre analisou o ai_decide, a nova AI Function de decisão da Databricks compatível com a API da TypeSafe AI, e apontou dois antipadrões: substituir regra determinística por decisão probabilística, e colocar IA em todo loop em tempo real só porque a latência permite."
ShowToc: false
---

Inferência rápida o suficiente para tempo real não significa que colocar um modelo ali seja a decisão certa.

O Databricks MVP Sudhir Gajre leu o anúncio do `ai_decide`, nova AI Function da Databricks ainda em Beta, acionável via SQL ou REST API e diretamente compatível com a API da TypeSafe AI, o que facilita migrar uma integração já feita com Jev para dentro do Databricks sem reescrever o contrato de API. O exemplo do jogo da cobrinha usado no anúncio mostra bem que o `ai_decide` é rápido o suficiente para inferência em tempo real, mas foi exatamente essa velocidade que o fez pensar em dois antipadrões.

O primeiro antipadrão é substituir regra explícita por decisão probabilística: se o critério de decisão pode ser expresso como if/else ou CASE claro, detecção de colisão, limiar numérico, regra de elegibilidade, código tradicional costuma ser mais rápido, mais barato, mais previsível e muito mais fácil de testar do que chamar um modelo. O segundo é colocar IA dentro de todo loop em tempo real só porque a latência baixa permite: antes de instrumentar isso, vale perguntar se existe algo genuinamente semântico para decodificar ali. Se não existe, o modelo adiciona custo e incerteza operacional sem adicionar inteligência real.

Pontos técnicos da análise:

- `ai_decide` é acionável via SQL ou REST API, e está em Beta
- Compatibilidade direta com a API da TypeSafe AI facilita migrar integrações já feitas com Jev
- Onde `ai_decide` se justifica: classificar texto, pontuar uma resposta, rotear uma requisição, ou decidir algo onde a regra escrita à mão fica frágil com o tempo
- Antipadrão 1: trocar regra determinística, se/então ou CASE, por decisão probabilística sem necessidade
- Antipadrão 2: colocar chamada de modelo em todo loop em tempo real só porque a latência permite, mesmo sem nada semântico para decodificar

**Minha leitura:** o ponto mais valioso aqui não é sobre o `ai_decide` em si, é o princípio por trás da crítica: ao desenhar sistema agêntico, torne determinístico tudo que puder ser determinístico, e reserve IA para a fronteira real de incerteza semântica. É um contraponto saudável ao entusiasmo de colocar modelo em qualquer lugar só porque ficou rápido e barato o suficiente para isso.

**Fonte:** https://www.linkedin.com/in/sudhir-gajre/#ai-decide-quando-nao-usar

#Databricks #AIFunctions #ModelServing
