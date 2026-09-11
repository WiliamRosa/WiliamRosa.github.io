---
title: "Trace antigo do MLflow agora sai sozinho do banco caro e vai pra object storage barato"
date: 2026-09-11T08:30:00-03:00
draft: false
tags: ["Databricks", "MLflow", "Observabilidade", "Azure Databricks"]
summary: "O Databricks MVP Juan Diaz destacou o Trace Retention & Auto Archival do MLflow 3.13: uma rotina em segundo plano move trace mais antigo que a janela de retenção do backend SQL pra object storage, sem perder leitura via UI nem API."
ShowToc: false
---

Trace de agente de IA em produção acumula rápido, e deixar tudo pra sempre no mesmo backend SQL que atende consulta interativa cedo ou tarde vira gargalo de performance.

O Databricks MVP Juan Diaz destacou o Trace Retention & Auto Archival, lançado no MLflow 3.13, que ataca esse problema com uma rotina automática rodando em segundo plano. Span de trace mais velho que a janela de retenção configurada sai do backend SQL, otimizado pra consulta rápida, e vai pra um object storage mais barato, como S3. O ponto importante é que essa mudança de local é transparente: quem consulta o trace pela interface ou pela API continua enxergando o histórico completo, sem precisar saber se aquele trace específico está quente no SQL ou frio no object storage.

A configuração é feita por política, não por comando manual repetido: um YAML no servidor define se o arquivamento está ligado, pra onde vai (um bucket S3, por exemplo), qual a janela de retenção e de quanto em quanto tempo a rotina roda. A partir daí, quem administra o workspace ou é dono do experimento pode apertar essa retenção pela própria interface ou linha de comando, sem precisar mexer na configuração central do servidor, e cada trace passa a mostrar um selo indicando quando ele será arquivado.

Pontos técnicos que valem atenção:
- Rotina em segundo plano move trace vencido do backend SQL pro object storage automaticamente
- Leitura via UI e API continua funcionando igual, independente de onde o trace está fisicamente
- Política resolve em cascata: servidor, depois workspace, depois experimento
- Configuração via YAML no servidor (trace_archival, location, retention, interval_seconds)
- Interface mostra selo de "Archive after" em cada trace com a data efetiva de corte

**Minhas considerações:** é o tipo de feature que não aparece em nenhum anúncio chamativo mas resolve um problema real de quem já roda agente em produção há alguns meses e começou a sentir o backend de trace pesando. Vale configurar a política de retenção antes que o volume vire problema, não depois que a consulta de trace já está lenta.

**Fonte:** https://mlflow.org/releases/3.13.0/

#Databricks #MLflow #Observabilidade
