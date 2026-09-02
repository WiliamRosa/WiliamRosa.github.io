---
title: "Lakebase Postgres decide sozinho quando trocar de tamanho de máquina, usando HyperLogLog"
date: 2026-09-01T10:00:00-03:00
draft: true
tags: ["Databricks", "Lakebase", "Postgres", "Arquitetura"]
summary: "A Databricks detalhou como o Lakebase Postgres faz autoscaling automático de VM sem derrubar conexão, combinando uso de CPU, uso de memória e uma estimativa de working set feita com uma variante de HyperLogLog sensível a tempo."
ShowToc: false
---

Redimensionar a máquina de um banco de dados em produção sem derrubar conexão ainda soa como proeza, mesmo em 2026.

A Databricks detalhou o mecanismo de autoscaling automático de VM do Lakebase Postgres. Como o Lakebase separa armazenamento de computação, o nó de computação pode ser iniciado, parado, movido ou redimensionado de forma independente do dado gravado em disco, o que abre espaço pra trocar de tamanho de máquina sem perder o estado.

A decisão de quando escalar olha três sinais ao mesmo tempo e usa o maior deles como gatilho, sempre respeitando limite configurado pelo usuário. O sinal mais interessante tecnicamente é a estimativa de working set, calculada com uma variante de HyperLogLog que guarda timestamp em vez de bit dentro de cada registrador, permitindo estimar o tamanho do conjunto de dados ativo numa janela de tempo, ao invés de só uma contagem acumulada.

Pontos técnicos que valem atenção:
- Sinal de CPU, média de 1 minuto, mantém abaixo de 90%, checado a cada 5 segundos
- Sinal de memória, mantém uso abaixo de 75% da RAM alocada, verificado a cada 100 milissegundos
- Sinal de working set, recalculado a cada 20 segundos, com janela de estimativa de até 60 minutos
- Em produção, o sistema já executa mais de 32 mil eventos de escalonamento por mês

**Minhas considerações:** a variante de HyperLogLog sensível a tempo é o tipo de detalhe de engenharia que vale guardar como referência, mesmo fora do contexto Lakebase, pra qualquer sistema que precise estimar cardinalidade recente sob carga variável. Isso complementa o que já foi coberto aqui antes sobre arquitetura do Lakebase, agora com o pedaço específico de como ele decide escalar.

**Fonte:** https://www.databricks.com/blog/autoscaling-lakebase-postgres

#Databricks #Lakebase #Arquitetura
