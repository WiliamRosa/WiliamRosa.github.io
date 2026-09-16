---
title: "Resposta do Genie no Slack agora vem com o gráfico de verdade, não só o texto"
date: 2026-09-15T09:30:00-03:00
draft: false
tags: ["Databricks", "Genie", "Slack", "Azure Databricks"]
summary: "Em public preview, quando a resposta do Genie inclui um gráfico, a visualização passa a aparecer como imagem direto na resposta do Slack, exigindo reinstalar o app do Genie no Slack pra quem já tinha instalado antes."
ShowToc: false
---

Perguntar pro Genie no Slack e receber só uma tabela de texto onde deveria caber um gráfico sempre deixou a resposta pela metade.

O Azure Databricks passou a renderizar visualização de resposta do Genie diretamente como imagem dentro da conversa do Slack, em public preview. Antes, quando a resposta do Genie incluía gráfico, o conteúdo visual ficava limitado ao que dava pra representar em texto simples dentro da thread; agora o gráfico aparece de fato como imagem, junto da resposta.

Quem já tinha instalado o app do Genie pra Slack antes desse lançamento precisa reinstalar o app pra habilitar esse comportamento, já que a integração antiga não ativa a mudança sozinha.

Pontos técnicos:
- Gráfico de resposta do Genie aparece como imagem na thread do Slack, não só como texto
- Recurso está em public preview
- Instalação anterior do app do Genie pra Slack precisa ser refeita pra habilitar a visualização

**Minha ressalva:** é um ajuste pequeno, mas resolve um atrito real de quem usa Genie via Slack como canal principal de consulta a dado, em vez de abrir o workspace toda vez que precisa ver um número. O ponto de atenção é operacional, não técnico: como a mudança exige reinstalação manual do app, times que não acompanham release note de perto vão continuar recebendo resposta sem gráfico até alguém notar e atualizar.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/genie-one/genie-slack

#Databricks #Genie #Slack
