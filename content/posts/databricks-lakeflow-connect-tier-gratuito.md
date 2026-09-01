---
title: "100 DBUs de ingestão grátis por dia, todo dia, pra sempre, o que a Databricks está apostando com isso"
date: 2026-05-02T09:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow Connect", "Ingestão de Dados", "Opinião"]
summary: "O novo tier gratuito permanente do Lakeflow Connect cobre cerca de 100 milhões de registros por dia, por workspace, sem prazo de validade. Isso muda o cálculo de quem hoje paga por linha ingerida."
ShowToc: false
---

O Databricks MVP Hubert Dudek destacou um lançamento que passou meio despercebido: a Databricks lançou um tier gratuito **permanente** pro Lakeflow Connect, 100 DBUs por dia, por workspace, sem data de expiração, o equivalente a cerca de 100 milhões de registros por dia, de graça.

Pra times de porte médio, isso frequentemente cobre a carga de ingestão inteira. E vem com o pacote completo: conectores nativos, governança via Unity Catalog, linhagem de dado já embutida desde o primeiro registro ingerido, não é uma versão capada da ferramenta, é a ferramenta completa com um limite generoso de uso diário.

Por que essa jogada é mais estratégica do que parece:
- Ingestão cobrada por linha/registro sempre foi um modelo estranho pra quem já paga pela plataforma como um todo
- Um tier gratuito permanente (não um trial de 30 dias) remove a fricção de decisão pra quem está avaliando migrar de uma ferramenta de ingestão paga à parte
- Times que hoje pagam por linha ingerida numa ferramenta terceira ganham um motivo concreto pra recalcular a conta

**Minha ressalva:** "grátis pra sempre" em produto de nuvem quase sempre tem uma leitura estratégica por trás, normalmente é a porta de entrada pra consumo de outras partes da plataforma (compute, armazenamento, Unity AI Gateway) que não são gratuitas. Vale entender o tier gratuito como aquisição de cliente, não como filantropia, e projetar o custo total assim que o volume ultrapassar os 100 DBUs diários.

**Fonte:** https://www.sunnydata.ai/blog/lakeflow-connect-free-tier-etl-cost-savings

#Databricks #LakeflowConnect #EngenhariaDeDados
