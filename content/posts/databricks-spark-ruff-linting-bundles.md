---
title: "O próprio Apache Spark adotou o Ruff — e isso muda como eu penso em lint pra Databricks"
date: 2026-07-02T09:15:00-03:00
draft: true
tags: ["Databricks", "Apache Spark", "Declarative Automation Bundles", "Opinião"]
summary: "A comunidade Spark passou a usar Ruff pra lint e formatação a partir da versão 4.2. O Databricks MVP Bartosz Konieczny explica como incorporar isso aos Declarative Automation Bundles sem travar deploys em sandbox."
ShowToc: false
---

A comunidade do Apache Spark adotou o Ruff, a partir da versão 4.2.0, tanto para lint quanto para formatação de código — dois comandos, `check` e `format`, com integração direta no pipeline de CI/CD do próprio projeto. O Databricks MVP Bartosz Konieczny detalhou como aplicar essa mesma ferramenta em projetos Databricks, especificamente dentro de Declarative Automation Bundles.

O ponto que mais chama atenção não é a ferramenta em si — Ruff já é conhecida — é a recomendação de onde colocar cada verificação no ciclo de deploy: lint não deveria bloquear deploy em ambiente de sandbox, e sim ficar reservado para CI/CD em branch principal ou de release. Um hook de pre-commit local complementa isso, pegando problema antes mesmo do código sair da máquina do desenvolvedor.

Por que isso é mais relevante do que "só mais um linter":
- Com agente de código gerando cada vez mais código Databricks, quem revisa precisa de regras consistentes pra conseguir avaliar o que está sendo gerado
- Separar lint de sandbox e lint de CI/CD reconhece que velocidade de iteração e rigor de qualidade têm momentos diferentes no ciclo de deploy
- Ruff cobrindo tanto lint (Pyflakes, pycodestyle, bugbear, segurança, performance) quanto formatação num único binário reduz a lista de ferramentas que um projeto precisa manter

**Minha ressalva:** a recomendação de "não copiar configuração de lint de outro projeto sem avaliar" é fácil de concordar em teoria e fácil de ignorar na prática — a maioria dos times realmente copia a config de lint de algum repositório de referência e nunca revisita. Vale tratar esse "construa seu próprio contrato de qualidade" como trabalho de verdade, com tempo alocado, não como um checkbox que se marca uma vez e esquece.

**Fonte:** https://www.waitingforcode.com/databricks/ruff-declarative-automation-bundles/read

#Databricks #ApacheSpark #DevOps
