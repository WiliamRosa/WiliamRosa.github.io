---
title: "Quem pode usar serverless no seu workspace virou uma decisão explícita, não implícita"
date: 2026-08-26T10:00:00-03:00
draft: false
tags: ["Databricks", "Serverless", "Governança", "Opinião"]
summary: "Serverless Compute Access Control chegou à disponibilidade geral: admin de workspace agora governa acesso a compute interativo e automatizado por usuário ou grupo, via UI ou API."
ShowToc: false
---

Até pouco tempo, se o workspace tinha serverless habilitado, todo mundo tinha acesso, sem meio-termo.

O Databricks MVP Soufiane Darraz apontou a chegada do Serverless Compute Access Control à disponibilidade geral: agora existem dois objetos de compute nativos, Default Interactive Compute (pra notebook e Databricks Connect) e Default Automated Compute (pra job e pipeline), e um admin de workspace controla o acesso a cada um separadamente.

O mecanismo é direto: por padrão, todo usuário do workspace mantém o direito de uso em ambos os tipos de compute, então nada quebra pra workload existente no dia em que isso for adotado. A partir daí, o admin remove grupo ou usuário específico de um dos dois objetos pra restringir acesso, seja pela UI, seja pela Access Control API, dependendo se a preferência é gerenciar isso manualmente ou via automação.

Pontos técnicos que valem registrar:
- Dois objetos de compute distintos: interativo (notebook, Databricks Connect) e automatizado (job, pipeline declarativa)
- Acesso é aditivo por padrão, ninguém perde permissão automaticamente na migração
- Restrição acontece por remoção explícita de grupo ou usuário, não por allowlist desde o início
- Gerenciável tanto pela interface quanto pela API de controle de acesso

**Minha ressalva:** "por padrão todo mundo mantém acesso" é a escolha certa pra não quebrar produção no dia da adoção, mas também significa que a governança só existe de fato depois que alguém ativamente decide restringir. Se sua empresa habilitou serverless há tempos sem pensar em quem deveria ou não ter acesso, essa funcionalidade só ajuda se alguém realmente for lá auditar os grupos hoje, ela não impõe disciplina sozinha.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/compute/serverless/access-control

#Databricks #Serverless #Governança
