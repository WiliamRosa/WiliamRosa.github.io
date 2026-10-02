---
title: "Sua fila de quarentena do DLT não sabe quando o registro já foi corrigido"
date: 2026-10-01T08:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow Declarative Pipelines", "Data Quality", "DLT"]
summary: "O Databricks MVP Gary Nakanelua testou três desenhos de fila de quarentena centralizada para expectation failures do DLT, e descobriu que apenas uma condição extra impede que um registro corrigido continue listado como pendente."
ShowToc: false
---

Corrigir um registro ruim e ver ele continuar aparecendo na fila de quarentena é o tipo de bug silencioso que só aparece quando alguém finalmente confere a fila de verdade.

O Databricks MVP Gary Nakanelua pegou uma pergunta recorrente num thread da comunidade Databricks: em vez de criar uma tabela "invalid" separada para cada tabela Silver, existe um jeito de centralizar todas as falhas de expectation do DLT numa única view governada? A única resposta no thread sugeria marcar as linhas ruins na Silver e devolver a correção de um steward por um segundo fluxo de append. Ele testou essa ideia na prática.

A descoberta central: um registro corrigido volta ao sistema por um update comum, sem exigir refresh completo, mas isso por si só não limpa a fila de quarentena. Ele implementou os três desenhos sugeridos no thread num único pipeline Lakeflow no Databricks Free Edition, usando um milhão de pedidos fictícios da Stark Industries com 50 mil marcados como ruins de propósito. Os três desenhos capturaram corretamente todos os pedidos ruins. O problema apareceu depois: ao enviar 500 correções de volta, todos os três desenhos aceitaram a atualização normalmente, mas a fila de quarentena continuou listando os 500 registros como pendentes.

Pontos técnicos do experimento:

- Os três desenhos sugeridos no thread capturaram 100% dos 50 mil pedidos marcados como ruins
- As 500 correções enviadas de volta foram aceitas como update comum em todos os desenhos, sem exigir refresh completo da pipeline
- Mesmo assim, a fila de quarentena continuou listando os 500 registros corrigidos como pendentes nos três desenhos
- A correção foi uma única condição extra: só listar um pedido na fila de quarentena enquanto não existir uma cópia boa dele
- O pipeline roda inteiro no Databricks Free Edition, com notebook publicado para reprodução

**Minhas considerações:** a analogia da cozinha profissional é exata, o prato corrigido sai, mas a comanda antiga continua pendurada no rail até alguém tirar ela manualmente. Se sua equipe mantém uma fila de quarentena centralizada de expectation failures, vale conferir se ela realmente reflete o estado atual dos dados ou só acumula tudo que já passou por ali um dia.

**Fonte:** https://www.linkedin.com/in/gnakan/#dlt-quarantine-queue-nao-sabe-que-foi-corrigida

#Databricks #Lakeflow #DataQuality
