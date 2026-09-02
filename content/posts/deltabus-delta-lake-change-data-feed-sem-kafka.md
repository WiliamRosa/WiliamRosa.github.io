---
title: "DeltaBus: o padrão que usa Delta Lake e Change Data Feed em vez de Kafka"
date: 2026-08-19T09:00:00-03:00
draft: false
tags: ["Databricks", "Delta Lake", "Arquitetura", "Opinião"]
summary: "Em vez de mais um cluster Kafka pra manter, o padrão DeltaBus usa tabela Delta e Change Data Feed como barramento de eventos. O Databricks MVP Dr. Alan L. Dennis destacou o argumento por trás dessa escolha de arquitetura."
ShowToc: false
---

O Databricks MVP Dr. Alan L. Dennis compartilhou um argumento de arquitetura que vale a pena levar a sério antes de assinar mais um contrato de cluster Kafka: se você já roda Databricks, talvez você já tenha um barramento de mensagens funcional, só não estava olhando pra ele desse jeito.

A ideia por trás do padrão DeltaBus é substituir Kafka como camada de eventos por tabela Delta combinada com Change Data Feed. Em vez de publicar evento num tópico e consumir via broker dedicado, uma aplicação escreve numa tabela Delta comum, e consumidores leem as mudanças incrementalmente via Change Data Feed, que já expõe insert, update e delete linha a linha com a sequência correta. O ganho não é performance bruta, é eliminar uma peça inteira de infraestrutura, o cluster Kafka, sua operação, seu patch de segurança e seu time dedicado, quando o volume e a latência exigida não justificam mensageria dedicada.

Onde esse padrão faz sentido, e onde não faz:
- Funciona bem quando o consumidor já é um pipeline Databricks, porque elimina a ponte entre dois sistemas de armazenamento diferentes
- Change Data Feed já resolve ordenação e captura de delete, os dois pontos que mais dão trabalho em implementação caseira de fila sobre tabela
- Não substitui Kafka em cenário que exige latência de milissegundos ou milhões de mensagens por segundo, ali a arquitetura orientada a broker ainda ganha

**Minha ressalva:** trocar Kafka por Delta Lake resolve o problema de operação de infraestrutura, mas introduz um acoplamento novo, o consumidor passa a depender do formato e do ritmo de commit do Delta Lake em vez de um protocolo de mensageria desenhado pra isso. Antes de migrar um sistema de produção inteiro pra esse padrão, vale simular o pior caso de latência de leitura do Change Data Feed sob carga, porque commit em lote não tem a mesma garantia de entrega quase instantânea que um broker dedicado oferece.

**Fonte:** https://www.covasant.com/blogs/you-already-have-a-message-bus-why-we-stopped-using-kafka

#Databricks #DeltaLake #Arquitetura
