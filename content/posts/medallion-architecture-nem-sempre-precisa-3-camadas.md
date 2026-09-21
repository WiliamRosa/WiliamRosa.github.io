---
title: "Nem todo pipeline precisa das três camadas do Medallion"
date: 2026-09-18T07:00:00-03:00
draft: false
tags: ["Databricks", "Arquitetura de Dados", "Medallion", "Lakehouse"]
summary: "Bartosz Konieczny questiona quando vale a pena simplificar a arquitetura Medallion pra duas camadas, e lista seis cenários concretos em que as três camadas (bronze, silver e gold) continuam valendo o esforço."
ShowToc: false
---

Bronze, silver e gold viraram quase um dogma, mas nem todo pipeline precisa das três camadas.

O Databricks MVP Bartosz Konieczny questionou uma assunção comum de quem trabalha com Azure Databricks: será que todo pipeline realmente precisa da estrutura completa da arquitetura Medallion? Ele parte de um caso concreto, o de arquivo que chega num Volume e vira direto uma tabela final já bem estruturada, vindo de uma ferramenta terceira. Nesse cenário, forçar as três camadas cria uma camada gold que acaba sendo cópia exata da silver, sem nenhum enriquecimento real, e qualquer mudança de schema precisa ser replicada em três lugares em vez de um.

A alternativa que ele propõe pra esse caso específico é tratar o próprio Volume como bronze e a tabela de saída como gold, eliminando a camada intermediária. Isso não é uma recomendação geral contra o Medallion, e sim um convite a questionar a estrutura quando ela não agrega valor real.

Cenários em que ele reforça que as três camadas continuam valendo a pena:
- Carga incremental, onde a silver serve como estado intermediário já limpo
- Retenção curta do dado bruto, onde a bronze guarda o mínimo necessário antes de expirar
- Lógica de busca de dado complexa, onde ter a bronze facilita reprocessar sem repetir a extração inteira
- Requisito de auditoria, que exige poder consultar o dado tanto na bronze quanto na silver e na gold
- Mudança frequente na camada gold, evitando recalcular camadas mais estáveis abaixo dela
- Slowly Changing Dimensions, que exigem uma apresentação desnormalizada só possível na gold

**Minhas considerações:** é um contraponto saudável a um padrão que às vezes vira dogma sem questionamento. A documentação trata o Medallion como boa prática padrão, com razão na maioria dos casos, mas o exemplo do arquivo que já chega pronto pra virar tabela final mostra bem quando a camada extra só adiciona manutenção sem benefício. A lista de quando manter as três camadas acaba sendo mais útil do que a provocação inicial.

**Fonte:** https://www.waitingforcode.com/databricks/medallion-layers-do-you-need-them-all/read

#Databricks #ArquiteturaDeDados #Lakehouse
