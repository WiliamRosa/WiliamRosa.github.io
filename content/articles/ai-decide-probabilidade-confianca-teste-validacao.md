---
title: "ai_decide devolve uma probabilidade, não uma certeza: como montar seu próprio teste antes de confiar nela"
date: 2026-11-06T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "AI Functions", "SQL", "Beta"]
ShowToc: true
summary: "ai_decide() nunca devolve só uma resposta, devolve uma distribuição de probabilidade e um grau de confiança sobre ela. Isso muda completamente como você deveria validar a função antes de colocar numa pipeline que roteia ticket, prioriza alerta ou decide prazo. Um roteiro para testar consistência antes de confiar, não depois."
---

É comum ver `ai_decide()` sendo tratado como uma função determinística qualquer: passa o dado, recebe a resposta, segue o pipeline. O problema é que a função nunca promete isso. Ela devolve uma probabilidade para cada hipótese avaliada, não uma certeza binária, e junto dela vem um número de confiança que diz o quanto aquele dado específico sustentava a avaliação. Ignorar essa distinção é o jeito mais rápido de descobrir, em produção, que a função "errou" num caso que ela, na verdade, já tinha sinalizado como incerto desde o início.

O ponto deste texto não é repetir o que já é sabido sobre quando usar ou não `ai_decide` no lugar de regra determinística. É mais específico: como ler o que a função realmente devolve, e como montar um teste próprio de consistência antes de confiar nela num fluxo que importa.

## O que a função devolve, de verdade

`ai_decide(state, questions [, options])` avalia uma ou mais perguntas contra o mesmo dado de entrada (`state`), e cada pergunta tem um tipo: `noul` estima a probabilidade de uma afirmação ser verdadeira, devolvendo um número entre 0 e 1; `choice` escolhe um rótulo entre critérios nomeados, devolvendo a escolha mais provável junto com a probabilidade de cada rótulo possível; `score` avalia contra uma escala ordenada, devolvendo a média ponderada por probabilidade dos índices da escala, que pode ser fracionária.

O detalhe que costuma passar batido é que, para pergunta do tipo `choice` e `score`, a resposta vem acompanhada de um campo `confidence`, um número de 0 a 1 que indica o quanto o dado de entrada sustentava aquela avaliação, não o quanto a função "acredita" na própria resposta de forma abstrata. Uma escolha com probabilidade de 0,95 para um rótulo e confiança de 0,9 é uma coisa; uma escolha com a mesma probabilidade de 0,95 mas confiança de 0,3 é outra completamente diferente, porque indica que o dado de entrada era ambíguo e a função, mesmo assim, teve que escolher algo.

## Confiança não é a mesma coisa que estar certo

Vale separar dois conceitos que a resposta da função expõe lado a lado, mas que significam coisas diferentes. A probabilidade (ou o `score`) é sobre a pergunta em si: qual rótulo, qual chance, qual posição na escala. A confiança é sobre a qualidade do dado de entrada para responder aquela pergunta específica. Uma pipeline que lê só a probabilidade e ignora a confiança está, na prática, tratando "a função respondeu algo" como equivalente a "a função tinha uma base sólida para responder".

Isso importa especialmente em pergunta do tipo `choice`, onde sempre existe um rótulo "mais provável" mesmo quando as probabilidades estão quase empatadas entre duas opções. Um ticket de suporte que o modelo distribui 52% para "time de cobrança" e 48% para "time técnico" vai, de qualquer forma, devolver "cobrança" como a escolha, mas a diferença entre as duas é tão pequena que tratar essa escolha como definitiva, sem olhar a distribuição completa de probabilidade, é jogar fora exatamente a informação que deveria disparar uma revisão humana.

## Mão na massa: um teste de consistência antes de confiar

Antes de colocar `ai_decide` numa pipeline que importa, vale rodar um teste simples de consistência: repetir a mesma pergunta contra o mesmo dado várias vezes e observar a variação na distribuição de probabilidade e na confiança. Um esboço de como estruturar esse teste em SQL, escrito aqui como exemplo didático e não como script oficial de nenhuma fonte:

```sql
-- Teste de consistência: roda a mesma avaliação N vezes
-- sobre o mesmo ticket e guarda escolha, confiança e probabilidade
-- de cada rodada para depois medir variação

CREATE OR REPLACE TEMPORARY VIEW teste_consistencia AS
SELECT
  rodada,
  ai_decide(
    ticket_texto,
    '{
      "time_responsavel": {
        "type": "choice",
        "instructions": "Qual time deveria assumir este ticket?",
        "criteria": {
          "cobranca": "Problemas de pagamento, fatura ou cobrança indevida",
          "tecnico": "Falha de funcionamento do produto",
          "logistica": "Atraso ou problema de entrega"
        }
      }
    }'
  ) AS resultado
FROM (SELECT explode(sequence(1, 20)) AS rodada),
     (SELECT texto AS ticket_texto FROM main.suporte.tickets_exemplo WHERE id = 4821);

-- Flags linhas onde a escolha variou entre rodadas,
-- ou onde a confiança ficou consistentemente baixa
SELECT
  resultado:response.answers.time_responsavel.choice::string AS escolha,
  resultado:response.answers.time_responsavel.confidence::double AS confianca,
  count(*) AS ocorrencias
FROM teste_consistencia
GROUP BY escolha, confianca
ORDER BY ocorrencias DESC;
```

Se vinte rodadas sobre o mesmo ticket produzem a mesma escolha, com confiança estável, a função está se comportando de forma previsível para aquele tipo de caso. Se a escolha varia entre rodadas, ou a confiança oscila bastante, isso é sinal de que o critério definido nas `instructions` precisa de mais detalhe, ou de que aquele tipo de ticket genuinamente exige revisão humana em vez de decisão automática.

## Requisitos e o que muda com o tempo

Vale conferir o estado atual da função antes de assumir que ela se comporta como documentação antiga descreveria: `ai_decide` ainda está em Beta, exige Databricks Runtime 15.4 LTS ou superior, com a versão 18.2 recomendada para melhor desempenho, não está disponível em Azure Databricks SQL Classic, e sua disponibilidade depende da região do workspace. Há também uma mudança futura já anunciada na documentação: funções de IA vão passar a exigir Databricks Runtime 17.3 LTS ou superior, então quem está num runtime mais antigo vai precisar planejar essa atualização.

O modelo por trás da função, hoje licenciado sob Apache 2.0, pode mudar no futuro se a Databricks encontrar um modelo com melhor desempenho em seus benchmarks internos, e a documentação é explícita sobre isso. **Na prática:** esse é o detalhe que mais deveria pesar na decisão de onde usar a função. Qualquer teste de consistência que você rodar hoje vale para o modelo de hoje; se o modelo por trás muda silenciosamente numa atualização futura, seu teste de consistência pode precisar ser refeito, porque o novo modelo pode distribuir a confiança de forma diferente para os mesmos casos.

## O que isso não resolve

Testar consistência ajuda a decidir se um critério está bem definido, mas não resolve o problema de auditoria: quando um ticket é roteado automaticamente para o time errado, o rastro que fica é uma distribuição de probabilidade, não uma explicação em linguagem de negócio de por que aquele critério pesou mais que outro. Para fluxo que exige trilha de auditoria legível por humano, como decisão em contexto regulado, isso ainda é uma lacuna real, e nenhuma camada de teste de consistência substitui ter um critério determinístico documentado para esses casos específicos.

A troca de modelo por trás da função, mesmo sendo uma decisão razoável do ponto de vista de qualidade, também significa que resultado histórico não é garantia de resultado futuro. Se o seu processo depende de comparar a decisão de hoje com a de seis meses atrás, vale guardar não só a resposta da função, mas o `metadata.version` que ela devolve, para saber se uma mudança de comportamento ao longo do tempo é ruído ou é, de fato, o modelo por trás tendo mudado.

## Vale a pena usar?

Vale, mas não como caixa preta. **Minha leitura final:** `ai_decide` é uma ferramenta de decisão probabilística bem desenhada para o que promete, só que o próprio formato da resposta já avisa que ela não deveria ser tratada como veredito final sem revisão. Guardar a confiança junto com a decisão, testar consistência antes de confiar num critério novo, e monitorar se o comportamento muda ao longo do tempo é o mínimo de disciplina que separa usar essa função bem de usar ela só porque está disponível.

## Referências

- Microsoft Learn, "ai_decide function - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/sql/language-manual/functions/ai_decide
- Databricks Blog, "Introducing AI_DECIDE: Make Fast Decisions on Your Governed Data": https://www.databricks.com/blog/introducing-aidecide-make-fast-decisions-your-governed-data

#AzureDatabricks #AIFunctions #SQL #Beta
