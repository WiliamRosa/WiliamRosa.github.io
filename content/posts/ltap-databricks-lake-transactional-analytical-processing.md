---
title: "LTAP não é um Lakebase com nome novo, é o Databricks tentando apagar o pipeline entre transação e análise"
date: 2026-09-28T10:00:00-03:00
draft: true
tags: ["Databricks", "Lakebase", "LTAP", "Arquitetura de Dados"]
summary: "O Databricks MVP Awadelrahman Ahmed explica LTAP (Lake Transactional/Analytical Processing) como uma extensão do padrão HTAP aplicada à camada de armazenamento do lakehouse: Postgres continua fazendo transação e o motor do lakehouse continua fazendo análise, só que sem CDC no meio, porque os dois leem o mesmo dado na mesma storage."
ShowToc: false
---

A pergunta mais comum sobre LTAP é também a mais reveladora: "isso não é só o Lakebase com outro nome?"

O Databricks MVP Awadelrahman Ahmed passou por essa mesma dúvida antes de chegar numa explicação que separa bem as duas coisas: Lakebase é o produto, LTAP (Lake Transactional/Analytical Processing) é o padrão arquitetural mais amplo que a Databricks está descrevendo em cima dele. E a frase que resume o achado dele é direta: LTAP não elimina a diferença entre carga transacional e analítica, elimina o pipeline que hoje existe entre as duas.

Para entender o porquê, vale voltar no tempo até o motivo de existir a separação OLTP/OLAP hoje. Historicamente, não foi a transação que saiu do banco operacional, foi a análise: bancos operacionais nunca aguentaram bem carga analítica pesada ao lado da carga transacional, então esse dado analítico foi copiado para um sistema separado, e aí nasceu o pipeline de ETL que carrega cada cópia até hoje. HTAP (Hybrid Transactional/Analytical Processing) tentou resolver isso trazendo os dois mundos de volta pra um único sistema, mas sem virar um padrão único de implementação, alguns fazem isso com motor especializado sobre storage compartilhada, outros de formas diferentes. LTAP entra como a versão desse mesmo objetivo aplicada à lógica do lakehouse: Postgres continua sendo o motor especializado pra transação de baixa latência, o motor do lakehouse continua sendo o especializado pra análise, ML e IA, só que os dois compartilham a mesma camada de storage aberta no lago em vez de ficarem sincronizados por réplica ou job de CDC.

Pontos técnicos que valem registrar:
- HTAP já existia como conceito antes do LTAP, o ganho aqui não é a ideia de unificar workloads, é onde essa unificação acontece
- No LTAP, dado escrito no Lakebase chega ao lago já num formato que a camada analítica lê direto, sem job de CDC fazendo a ponte
- Os motores continuam separados e escaláveis de forma independente, o que muda é a fundação de storage compartilhada entre eles
- O padrão segue a mesma lógica de expansão que já levou Delta Lake a virar Unity Catalog e depois Lakebase: cada etapa trouxe mais um tipo de carga de trabalho pro mesmo lago, dessa vez é a vez da transação

**Minhas considerações:** o nome novo tende a gerar ceticismo automático, principalmente vindo de quem já viu "rebrand" de conceito de arquitetura de dados virar anúncio de keynote antes. Mas o ponto técnico que o Awadelrahman isola, remover o pipeline entre transação e análise, não a diferença entre elas, é uma distinção que vale entender antes de descartar LTAP como só mais uma sigla. Se a promessa se sustentar em produção, o ganho real está em menos latência de dado fresco chegando na análise, não em unificar dois motores que continuam fazendo o que sempre fizeram de melhor.

**Fonte:** https://awadrahman.medium.com/from-oltp-and-olap-to-ltap-what-databricks-is-actually-changing-98d24de98942

#Databricks #Lakebase #ArquiteturaDeDados
