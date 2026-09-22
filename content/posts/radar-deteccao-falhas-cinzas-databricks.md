---
title: "RADAR: como a Databricks detecta falha parcial antes que o cliente reclame"
date: 2026-09-20T09:00:00-03:00
draft: false
tags: ["Databricks", "Observability", "AI"]
summary: "A Databricks publicou o RADAR, um sistema interno de quatro estágios pra achar 'falha cinza', apagão parcial que passa batido pelo dashboard verde, usando um modelo de detecção de anomalia não supervisionado e um dashboard Genie pra investigar a causa raiz; internamente reduziu o tempo de descoberta de incidente em 95%."
ShowToc: false
---

Um apagão parcial pode ficar escondido atrás de um dashboard inteiro verde até o cliente reclamar.

A Databricks detalhou o RADAR (Reliability Anomaly Detection, Alerting, and Root-cause analysis), o sistema que usa internamente pra pegar "falha cinza": quando uma fatia de usuário sente erro, mas a métrica agregada de saúde do serviço continua parecendo normal. É o tipo de problema que historicamente só aparecia depois de horas de receita perdida e reclamação de cliente, porque alerta tradicional costuma ser calibrado pra desvio grande e óbvio, não pra fatia pequena e concentrada de tráfego.

O sistema é dividido em quatro estágios que se alimentam em sequência. O primeiro grava contagem de erro e usuário afetado por código de erro e região, não só um número agregado por serviço. O segundo aplica um modelo de detecção de anomalia não supervisionado chamado SPOT (Streaming Peak Over Threshold), que pede só um parâmetro de risco em vez de exigir calibrar threshold manual pra cada métrica nova. O terceiro enriquece, filtra e deduplica antes de rotear o alerta pro time certo. O quarto entrega um dashboard AI/BI com Genie pra investigar a causa raiz sem precisar montar consulta do zero.

Pontos técnicos que valem atenção:
- SPOT é agnóstico de métrica, o mesmo pipeline detecta anomalia em taxa de erro, latência ou qualquer série temporal com contagem por segmento
- A calibração é feita por um único parâmetro de risco, não por threshold fixo específico de cada métrica
- O estágio de alerta existe justamente pra evitar o excesso de ruído que faz time ignorar alerta automático
- Todo o sistema é implantável via Declarative Automation Bundles
- O resultado interno reportado foi 95% de redução no tempo de descoberta de incidente, com mais de 90% de precisão

**Minha ressalva:** é um número forte, mas é a própria Databricks medindo o próprio sistema contra o próprio incidente. Vale tratar RADAR como um padrão de arquitetura replicável, SPOT mais um pipeline de alerta enriquecido mais um dashboard de causa raiz, em vez de esperar um produto pronto pra instalar; ainda não há sinal de que isso vai virar feature exposta pro cliente tão cedo.

**Fonte:** https://www.databricks.com/blog/radar-catch-gray-failures-anomaly-detection

#Databricks #Observability #SRE
