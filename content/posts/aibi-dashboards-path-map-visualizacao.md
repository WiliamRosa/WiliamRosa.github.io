---
title: "Path map chega aos dashboards AI/BI pra desenhar trajeto, não só ponto no mapa"
date: 2026-09-09T09:30:00-03:00
draft: true
tags: ["Databricks", "AI/BI Dashboards", "Data Visualization", "Azure Databricks"]
summary: "O Databricks MVP Geir E. Alstad destacou o path map, novo tipo de visualização nos dashboards AI/BI que desenha linha no mapa a partir de uma coluna de geometria no resultado da consulta, em vez de só marcar ponto isolado."
ShowToc: false
---

Mostrar rota de entrega ou trajeto de veículo num dashboard sempre esbarrava na mesma limitação: mapa com ponto marcado não é a mesma coisa que mapa com o caminho percorrido desenhado.

O Databricks MVP Geir E. Alstad notou a chegada do path map como um novo tipo de visualização nos dashboards AI/BI. Diferente dos tipos de mapa existentes, que plotam ponto (latitude e longitude isolados) ou área preenchida, o path map lê uma coluna de geometria do resultado da consulta e desenha linha conectando essa sequência de coordenadas direto sobre o mapa. Isso encaixa bem em qualquer caso onde o que importa é o caminho, não a posição num instante só.

A lógica de uso é parecida com os outros tipos de gráfico dos dashboards AI/BI: a consulta SQL já precisa devolver a geometria pronta (uma linha, por exemplo, resultado de agregação de pontos GPS ao longo do tempo ou de uma junção com dado de roteamento), e o dashboard só cuida da parte de desenhar isso sobre o mapa base, com o mesmo motor de renderização que já atende os outros tipos de visualização geográfica da plataforma.

Pontos técnicos que valem atenção:
- Novo tipo de visualização dentro dos dashboards AI/BI, ao lado dos mapas de ponto e de área já existentes
- Consome coluna de geometria já calculada no resultado da consulta, não faz roteamento sozinho
- Útil pra caso de uso como rota de entrega, trajeto de veículo ou linha de transporte
- Integra com o resto da stack de dashboard AI/BI, incluindo filtro e drill-down já existentes

**Minhas considerações:** é um tipo de visualização de nicho, a maioria dos dashboards de negócio nunca vai precisar de path map, mas pra quem trabalha com logística, transporte ou qualquer coisa que envolva movimento no espaço, é a diferença entre montar essa visualização com gambiarra de biblioteca externa ou ter isso nativo na plataforma.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/dashboards/manage/visualizations/types#path-map

#Databricks #AIBIDashboards #DataVisualization
