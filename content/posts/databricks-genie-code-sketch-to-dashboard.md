---
title: "Genie Code agora transforma um rabisco em rascunho de papel numa dashboard de verdade"
date: 2026-08-19T09:00:00-03:00
draft: true
tags: ["Databricks", "Genie Code", "AI/BI", "Opinião"]
summary: "Fazer upload de uma foto de um esboço desenhado à mão e pedir pro Genie Code construir a dashboard: menos um passo de tradução entre a ideia de negócio e o que acaba sendo construído."
ShowToc: false
---

O Genie Code ganhou a capacidade de receber uma foto de um esboço desenhado à mão e construir a dashboard a partir dela: ele procura nos dados financeiros e outros ativos do workspace aos quais você tem acesso, monta os datasets, cria as visualizações, e resolve problemas ao longo do caminho. No final, resume o que criou, mostra quais datasets usou, e sugere próximos passos como publicar, adicionar filtros ou fazer ajustes.

O que esse recurso realmente ataca não é "desenhar é mais fácil que descrever em texto", é a distância entre como um stakeholder de negócio pensa visualmente sobre uma dashboard (num guardanapo, num quadro branco, numa reunião) e o que precisa virar consulta SQL, dataset e gráfico configurado.

Por que isso é mais interessante do que parece:
- Reduz o vai-e-volta entre quem pede a dashboard e quem constrói, o esboço já é uma especificação, ainda que informal
- Genie Code precisa entender contexto suficiente do workspace pra mapear "essa caixinha no desenho" pra "essa métrica real nos dados"
- É um caso de uso onde erro de interpretação é fácil de perceber visualmente, comparar o esboço com o resultado é um ótimo mecanismo de verificação embutido

**Minha ressalva:** rabisco à mão é ambíguo por natureza, dois analistas desenhando a mesma ideia produzem esboços diferentes, e o Genie Code precisa preencher essas lacunas com suposição. Vale tratar o resultado como um primeiro rascunho pra revisão, não como a dashboard final, a IA generativa é boa em preencher intenção implícita, mas nem sempre acerta qual métrica exata alguém tinha em mente ao desenhar uma caixinha.

**Fonte:** https://docs.databricks.com/aws/en/dashboards/manage/dashboard-agent

#Databricks #GenieCode #AIBI
