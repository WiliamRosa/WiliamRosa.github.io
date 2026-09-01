---
title: "Segredos saem do nível de workspace e viram ativo governado no Unity Catalog"
date: 2026-08-12T09:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Segurança", "Governança", "Opinião"]
summary: "Segredos agora podem viver no nível de catálogo, com um namespace de três níveis e uma permissão nova (REFERENCE SECRET) pensada especificamente para serviços como Lakeflow Connections."
ShowToc: false
---

O Databricks MVP Hubert Dudek detalhou uma mudança na forma como segredos são armazenados no Databricks: agora dá pra guardá-los no Unity Catalog, usando a convenção de namespace de três níveis, em vez de ficarem presos ao nível de workspace como sempre foi.

O que chama atenção não é só "onde" o segredo mora, é a granularidade de permissão nova que vem junto. Além do já conhecido READ SECRET, existe agora REFERENCE SECRET — pensado especificamente para cenários em que o segredo precisa ser usado por outros serviços do Databricks, como Lakeflow Connections, sem que isso implique acesso programático direto ao valor do segredo. Ler o segredo dentro de um notebook continua sendo feito da forma de sempre, via `dbutils.secrets.get`.

Por que essa distinção de permissão é o ponto mais importante da mudança:
- READ SECRET e REFERENCE SECRET resolvem problemas diferentes: um dá acesso ao valor bruto, o outro só permite que um serviço *use* o segredo sem expô-lo
- Isso fecha uma lacuna real de governança: antes, dar acesso pra um conector usar uma credencial praticamente exigia dar acesso de leitura ao segredo também
- Segredo virar objeto do Unity Catalog significa herdar o mesmo modelo de permissão e auditoria que já existe pro resto dos dados — não é mais uma ilha de governança à parte

**Minha ressalva:** mover segredo de workspace pra catálogo é uma migração de superfície de risco, não só uma mudança de local de armazenamento — quem administra hoje via escopo de workspace precisa mapear cuidadosamente qual segredo vira REFERENCE SECRET versus READ SECRET antes de migrar, porque errar essa distinção pode tanto quebrar uma integração legítima quanto abrir acesso mais amplo do que pretendido.

**Fonte:** https://www.linkedin.com/in/hubertdudek/

#Databricks #UnityCatalog #Segurança
