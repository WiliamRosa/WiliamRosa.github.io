---
title: "O juiz barato do MLflow empatou no caso fácil e perdeu terreno no caso sutil"
date: 2026-11-02T10:00:00-03:00
draft: true
tags: ["MLflow", "Databricks", "Avaliacao de IA", "Azure Databricks"]
summary: "O Databricks MVP Shekhar Shukla testou o Jev, juiz pequeno que o MLflow 3.17 passou a oferecer pronto para avaliação, contra rótulo humano, e viu 30 de 30 de acerto no caso fácil mas 64 de 72 contra 72 de 72 de um modelo maior no caso difícil."
ShowToc: false
---

Um juiz de IA barato empatou com humano em caso fácil, mas perdeu terreno exatamente onde mais importa.

O Databricks MVP Shekhar Shukla testou o Jev, modelo pequeno da TypeSafe AI que o MLflow 3.17 passou a oferecer como juiz pronto pra avaliação, num benchmark comparando o veredito do modelo contra rótulo humano. Em um conjunto de casos fáceis, o Jev bateu 30 de 30 contra o rótulo humano, com latência mediana de 369 milissegundos e custo de cerca de 0,0247 dólar por mil julgamentos.

O ponto central do teste não é a vitória no caso fácil, é o que acontece quando a dificuldade sobe. Num segundo conjunto com erro técnico mais sutil, o modelo maior acertou 72 de 72 contra 64 de 72 do Jev, diferença que só aparece quando o erro exige entender contexto técnico mais profundo, não só comparar superfície de texto. Isso aponta pra um padrão prático de uso em cascata: Jev como triagem rápida e barata, escalando pro modelo maior só quando o caso exige julgamento mais fino.

Pontos técnicos que valem atenção:
- 30/30 de acerto contra rótulo humano no conjunto fácil, 369ms de latência mediana, cerca de 0,0247 dólar por mil julgamentos
- No conjunto difícil, Jev ficou em 64/72 contra 72/72 do modelo maior, justamente em erro técnico mais sutil
- O MLflow 3.17 já expõe o Jev como juiz pronto em mlflow.genai.evaluate(), sem precisar configurar modelo externo
- O teste reforça o Jev como triagem de primeira camada, não substituto do juiz mais caro em todo cenário

**Minhas considerações:** esse é o tipo de benchmark que falta em muito anúncio de modelo pequeno como juiz, a comparação não para no caso fácil onde qualquer modelo acerta. Vale replicar esse teste no seu próprio dataset de avaliação antes de trocar o juiz caro pelo barato em produção, a curva de degradação não é uniforme entre domínio.

**Fonte:** https://www.linkedin.com/feed/update/urn:li:activity:7523015150769975297/

#MLflow #Databricks #AvaliacaoDeIA
