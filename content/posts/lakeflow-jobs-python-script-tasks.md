---
title: "Job do Databricks ganhou um jeito mais simples de rodar script Python solto, sem empacotar wheel"
date: 2026-09-10T12:00:00-03:00
draft: true
tags: ["Databricks", "Lakeflow Jobs", "Python", "Opinião"]
summary: "O Databricks MVP Bartosz Konieczny detalhou o suporte a script Python como tipo de tarefa no Lakeflow Jobs, uma opção mais leve que wheel ou notebook pra tarefa simples como sensor ou geração de parâmetro dinâmico."
ShowToc: false
---

Nem toda tarefa de job precisa virar um wheel empacotado. Às vezes um script Python solto já resolve.

O Databricks MVP Bartosz Konieczny detalhou a chegada do script Python como tipo de tarefa dentro do Lakeflow Jobs, ao lado das opções já existentes de wheel e notebook. O script roda no cluster associado ao job, acessando automaticamente as bibliotecas instaladas e a instância do SparkSession, e pode ficar no workspace, em armazenamento de objeto (S3, GCS, Azure Blob) ou em repositório Git.

Pontos técnicos que valem atenção:
- Script Python só aceita um array de string como parâmetro, diferente do parâmetro nomeado mais flexível disponível em tarefa wheel
- Bom candidato pra tarefa simples, como sensor que verifica se um arquivo está pronto (padrão "readiness marker") ou geração de parâmetro dinâmico pra job posterior
- Konieczny recomenda não usar script Python solto pra lógica de negócio de produção que precisa de lint, formatação e teste apropriados
- Publicado ao lado de menção ao Databricks Runtime 18.0 como base testada

**Minha ressalva:** essa opção resolve bem o caso de "preciso rodar um pedacinho de lógica antes do job de verdade", mas o próprio limite de parâmetro (só array de string, sem nomeado) é um sinal de que ela não foi pensada pra virar a tarefa principal do seu pipeline. Vale usar pra sensor e geração de parâmetro, como o próprio autor recomenda, e resistir à tentação de colocar regra de negócio ali só porque é mais rápido de escrever que empacotar um wheel.

**Fonte:** https://www.waitingforcode.com/databricks/python-script-tasks-databricks/read

#Databricks #LakeflowJobs #Python
