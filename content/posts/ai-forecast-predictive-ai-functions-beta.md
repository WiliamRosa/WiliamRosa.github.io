---
title: "Previsão de série temporal como modelo de fundação: a aposta do ai_forecast dentro do SQL do Databricks"
date: 2026-10-14T10:30:00-03:00
draft: false
tags: ["Azure Databricks", "SQL", "Machine Learning", "AI Functions"]
summary: "As Predictive AI Functions, em Beta, trazem um ai_forecast renovado baseado em modelo de fundação para série temporal, mais quatro funções SQL novas de análise de driver, anomalia e predição, sem exigir que o usuário treine ou gerencie modelo."
ShowToc: false
---

A Databricks colocou previsão de série temporal, análise de driver, detecção de anomalia e predição direto dentro de uma função SQL, sem pedir pra ninguém treinar modelo.

As Predictive AI Functions, em Beta, são um conjunto de funções nativas do SQL do Azure Databricks pensadas pra analista de negócio e analista SQL rodarem tarefa de ML sem depender de um time de ciência de dados pra cada pergunta. A peça central é o ai_forecast renovado, baseado num modelo de fundação para série temporal: em vez de treinar um modelo novo pra cada métrica, ele foi pré-treinado sobre um conjunto grande e variado de séries temporais, do mesmo jeito que um modelo de linguagem é pré-treinado sobre texto, e aprendeu a reconhecer padrão de sazonalidade e tendência sem ajuste fino. A versão nova adiciona tratamento nativo de feriado (variação de demanda em datas como Natal ou férias escolares) e suporte a covariáveis externas, como mudança de preço ou investimento em marketing, que ajudam o modelo a explicar variação que a série sozinha não explicaria.

Ao lado do ai_forecast, chegam quatro funções novas: ai_top_drivers identifica quais segmentos mais contribuíram pra uma mudança numa métrica; ai_detect_anomalies aponta linha fora do padrão numa série temporal, ajustando um modelo automaticamente aos dados; e ai_predict_value e ai_predict_class resolvem regressão e classificação direto do SQL, sem pipeline de treino separado. Todas rodam sobre tabela com centenas de milhões de linhas segundo a Databricks, podem ser combinadas com qualquer outra consulta ou pipeline, e aparecem tanto em dashboard AI/BI quanto no Genie, que já expõe ai_top_drivers em linguagem natural, com as outras quatro funções previstas pra chegar em seguida.

Detalhes que valem registrar:

- ai_forecast ganhou tratamento de feriado e suporte a covariáveis externas, além da base de modelo de fundação pré-treinado.
- ai_top_drivers, ai_detect_anomalies, ai_predict_value e ai_predict_class cobrem driver analysis, anomalia, regressão e classificação, todos chamáveis via SQL comum.
- A Databricks diz ter validado o ai_forecast contra o fev-bench, comparando com função de previsão de um data warehouse concorrente e com a versão anterior do próprio ai_forecast, usando taxa de vitória em erro quantílico escalado como métrica, mas os números exatos de taxa de vitória aparecem só numa imagem de gráfico no post, sem tabela de dados no texto.
- ai_top_drivers já está disponível dentro do Genie; as outras quatro funções estão listadas como "em breve" pro Genie.

**Minha ressalva:** o discurso de "previsão sem exigir expertise avançada de ML" esconde uma parte real do trabalho, escolher a covariável certa, entender se a sazonalidade detectada faz sentido pro seu negócio e decidir o horizonte de previsão continua exigindo julgamento humano, só que agora escondido atrás de uma função SQL que parece trivial de chamar. E o fato de a Databricks divulgar ganho de acurácia só como imagem de gráfico, sem número na própria página, é o tipo de omissão que eu esperaria de material de venda, não de documentação técnica, mesmo tratando-se de recurso em Beta.

**Fonte:** https://www.databricks.com/blog/unlock-powerful-insights-and-forecasts-predictive-ai-functions

#AzureDatabricks #MachineLearning #SQL
