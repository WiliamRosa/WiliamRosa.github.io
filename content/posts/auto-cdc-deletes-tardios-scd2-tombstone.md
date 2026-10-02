---
title: "O que acontece quando um delete chega depois que o tombstone do AUTO CDC já expirou"
date: 2026-09-30T08:00:00-03:00
draft: false
tags: ["Databricks", "Lakeflow", "AUTO CDC", "Data Engineering"]
summary: "O Databricks MVP Gary Nakanelua testou deletes tardios contra tabelas AUTO CDC do tipo SCD 1 e 2 com diferentes janelas de retenção de tombstone, e mostrou o que sobrevive e o que muda quando o delete chega fora da janela."
ShowToc: false
---

A documentação da Databricks diz que uma linha deletada fica marcada como tombstone por dois dias, mas não diz o que acontece depois que esse prazo passa.

O Databricks MVP Gary Nakanelua pegou essa lacuna, levantada num thread da comunidade Databricks sobre o que ocorre quando um delete chega depois da janela de retenção, por exemplo durante um backfill de dados antigos, e testou na prática. Ele montou um pipeline Lakeflow com quatro tabelas AUTO CDC, cobrindo slowly changing dimension (SCD) Tipo 1 e Tipo 2, com janelas de retenção de 60 segundos e de dois dias, e então disparou eventos de delete tardios contra cada uma.

O resultado central: um delete tardio no AUTO CDC não ressuscita um cliente já apagado, mas numa tabela SCD Tipo 2 ele altera o histórico que já estava registrado embaixo dele, o que exige cuidado em qualquer consulta "as-of" que dependa daquele histórico. Nenhum update falhou durante o teste, e um delete tardio mais antigo que a última atualização registrada do cliente foi simplesmente ignorado, em todas as tabelas testadas.

Pontos técnicos do experimento:

- Em nenhuma das quatro tabelas um delete tardio trouxe de volta um cliente já apagado
- Nas tabelas SCD Tipo 2, um update tardio se encaixou antes do delete na linha do tempo, alterando o histórico já consolidado
- Um delete de backfill deixou uma linha sem data de início registrada
- Um delete tardio mais antigo que a última atualização do cliente foi ignorado em todas as tabelas, sem gerar erro
- O pipeline inteiro roda no Databricks Free Edition em menos de 10 minutos, com notebook publicado para reprodução

**Minha leitura:** a parte que mais chama atenção não é o delete em si, é o efeito colateral silencioso no histórico SCD Tipo 2. Se sua equipe faz backfill de dados antigos contra uma tabela AUTO CDC em produção, vale testar antes se alguma consulta "as-of" existente assume que aquele histórico é imutável, porque esse teste mostra que não é.

**Fonte:** https://www.linkedin.com/in/gnakan/#auto-cdc-late-arriving-deletes-scd2-tombstone

#Databricks #Lakeflow #DataEngineering
