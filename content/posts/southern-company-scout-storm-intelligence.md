---
title: "SCOUT: como a Southern Company junta previsão, resposta e pós-tempestade num único lakehouse"
date: 2026-09-03T09:00:00-03:00
draft: true
tags: ["Databricks", "Delta Lake", "Unity Catalog", "Caso de uso"]
summary: "SCOUT é o terceiro aplicativo da Southern Company sobre Databricks pra operação de tempestade, cobrindo o momento em tempo real entre a previsão (SPEAR) e a análise pós-evento (RAMP), com dado de outage, clima, terreno e equipe numa única camada."
ShowToc: false
---

Uma concessionária de energia levou anos pra parar de operar tempestade com três sistemas que não se falavam entre si.

A Databricks publicou o terceiro capítulo de uma série sobre como a Southern Company reconstruiu sua operação de resposta a tempestade em cima do lakehouse. Depois do SPEAR, pra previsão antes do evento, e do RAMP, pra análise depois que a poeira baixa, chega o SCOUT, o aplicativo que cobre o intervalo mais crítico: enquanto a tempestade está acontecendo e a equipe de campo precisa decidir onde mandar gente agora.

O que sustenta isso por baixo não é só um dashboard bonito. Delta Lake guarda o dado de forma resiliente, warehouses serverless do lakehouse atualizam a consulta em produção a cada minuto, e o Unity Catalog controla quem acessa o quê via service principal, sem depender de cópia solta de planilha circulando entre equipes durante o incidente.

Pontos técnicos que valem atenção:
- Ingestão unificada de outage, base de cliente, GIS, clima, terreno e dado operacional numa única camada, em vez de cada sistema isolado
- Atualização de consulta a cada minuto durante o evento, via warehouse serverless do lakehouse
- Diferencial de terreno: o sistema distingue local que exige equipe de escalada (área residencial densa) de área montanhosa que limita acesso de veículo, pra otimizar despacho de equipe
- Genie Code e notebook colaborativo usados no desenvolvimento das pipelines de analytics
- 1.139 funcionários usando a ferramenta entre as unidades da Southern Company, com pico de mais de 250 usuários simultâneos numa tempestade real em junho

**Minhas considerações:** o que chama atenção aqui não é a tecnologia em si, Delta Lake e Unity Catalog já são conhecidos, é o desenho de três aplicativos separados cobrindo três momentos do mesmo ciclo de vida do incidente, em vez de tentar forçar um sistema genérico a fazer tudo. Isso é um argumento prático a favor de modelar pipeline de dado em torno do momento de decisão do usuário final, não em torno da conveniência de manter uma arquitetura só.

**Fonte:** https://www.databricks.com/blog/southern-companys-scout-completing-storm-intelligence-story

#Databricks #DeltaLake #CasoDeUso
