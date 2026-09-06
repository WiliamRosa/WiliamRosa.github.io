---
title: "Governança no Databricks deixou de ser só controle de acesso, virou também gerar significado"
date: 2026-09-04T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Governança", "Opinião"]
summary: "A Databricks defende que tratar governança só como segurança deixa passar a parte que mais encarece IA: dar significado e contexto ao dado, unindo cinco pilares de governança numa lente só via Unity Catalog."
ShowToc: false
---

Tratar governança só como controle de acesso deixa a IA mais cara, porque falta significado nos dados pra qualquer modelo mais barato entender sozinho.

A Databricks publicou um argumento de que governança de dado, quando tratada só como controle de acesso e compliance, ignora a parte que mais custa caro pra IA: dar significado, contexto e confiança aos dados que o agente vai consumir. Sem isso, a organização acaba compensando a falta de clareza semântica pagando por modelo de fronteira mais caro, em vez de resolver o problema na origem.

A proposta une cinco pilares, governança de dado, governança de conhecimento e ML, letramento de dado, gestão de dado e ontologia, sob uma única lente no Unity Catalog. A partir daí entram os chamados build agents: agentes automatizados que leem instrução direto do metadado curado no catálogo e escrevem resultado de volta, cobrindo geração de ETL, teste, anonimização e deploy num loop contínuo. Dado ou agente sem descrição explícita no catálogo é bloqueado por padrão, não é uma exceção tratada depois. Do outro lado, dado e agente de IA passam pelos mesmos portões de ciclo de vida, medidos por um scorecard único de certificação que avalia governança, qualidade, semântica e propriedade.

Pontos técnicos que valem atenção:
- Cinco pilares de governança, dado, conhecimento/ML, letramento, gestão e ontologia, unificados numa lente só via Unity Catalog
- Build agents leem instrução do metadado curado no catálogo e escrevem resultado de volta: ETL, teste, anonimização e deploy viram um loop contínuo
- Enforcement fail-closed: dado ou agente sem descrição explícita no catálogo é bloqueado por padrão
- Scorecard único de certificação de IA mede governança, qualidade, semântica e propriedade pros dois lados, dado e agente
- Cada agente tem um Data Product Owner nomeado, e definição de métrica compartilhada é aplicada em tempo de execução pelo catálogo, não só documentada

**Minha ressalva:** a promessa de usar modelo mais barato porque o significado já mora no metadado é sedutora, mas depende de alguém manter esse metadado curado e atualizado de verdade, o que é trabalho manual constante. Sem isso, o enforcement fail-closed vira só mais atrito, e o time acaba preenchendo descrição de catálogo às pressas só pra destravar o agente, o oposto de dado com significado real.

**Fonte:** https://www.databricks.com/blog/governance-beyond-security-knowledge-context-ontology-lakehouse

#Databricks #UnityCatalog #Governança
