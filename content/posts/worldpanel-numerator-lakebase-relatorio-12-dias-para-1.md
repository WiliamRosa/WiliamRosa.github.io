---
title: "Worldpanel by Numerator cortou um relatório de 12 dias para 1 trocando a camada de consulta por Lakebase"
date: 2026-08-06T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "Lakebase", "Caso de Cliente"]
summary: "A Worldpanel by Numerator construiu o Item Picker sobre Lakebase para dar a times inteiros acesso direto a cerca de 18 bilhões de registros de transação por painel, sem depender de um grupo pequeno de especialistas, e cortou um relatório global de 12 dias para 1."
ShowToc: false
---

A Worldpanel by Numerator processa painel de consumo com uma escala que deixa qualquer camada de consulta tradicional sofrendo: só no painel do Reino Unido, a empresa trabalha com cerca de 18 bilhões de registros de transação e por volta de 8 mil atributos. Antes, explorar esse volume de dado dependia de um grupo pequeno de especialistas técnicos, o que empurrava relatório simples para um ciclo de dias.

A solução foi construir o Item Picker, uma ferramenta interna de exploração de dado em escala sobre o Lakebase e o restante da plataforma Azure Databricks. A ideia central não é só servir dado mais rápido, é mudar quem consegue pedir esse dado sem abrir chamado para um especialista.

Pontos que chamam atenção no caso:

- Um relatório global que levava 12 dias passou a ser entregue em 1, uma redução de 11 dias no ciclo
- A meta declarada da empresa é continuar reduzindo até chegar perto de relatório no mesmo dia em que o período analisado termina
- O ganho não é só velocidade de consulta, é self-service: equipe inteira acessa e filtra o dado em escala sem fila de especialista
- A escala de referência (18 bilhões de registros, 8 mil atributos, por painel) é o tipo de volume que historicamente forçava pré-agregação pesada antes de qualquer exploração ad hoc

**Minha leitura:** o número mais interessante aqui não é a redução de 11 dias, é o motivo dela. Toda vez que um relatório depende de um grupo pequeno de pessoas que entendem o sistema de consulta, esse grupo vira o gargalo real, não o hardware. Resolver isso com Lakebase funcionando como camada transacional rápida por trás de uma ferramenta de self-service é uma aposta em democratizar acesso ao dado operacional, não só em acelerar query. Fica a pergunta de quanto desse ganho veio da tecnologia e quanto veio de simplesmente ter investido tempo de produto em desenhar uma interface que um analista não especialista consegue usar sem ajuda.

**Fonte:** https://www.databricks.com/customers/numerator/lakebase

#AzureDatabricks #Lakebase #CasoDeCliente
