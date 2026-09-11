---
title: "Segredo externo no Unity Catalog: agora dá pra apontar direto pro Azure Key Vault"
date: 2026-09-10T09:30:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Segurança", "Azure Databricks"]
summary: "External secrets (Beta) conecta um schema do Unity Catalog direto ao Azure Key Vault: o segredo aparece como objeto governável e somente leitura, e o valor é lido sob demanda, sem duplicar cópia dentro do Databricks."
ShowToc: false
---

Segredo que já vive no Key Vault da empresa não precisa mais ser reimportado pra dentro do Unity Catalog pra virar governável.

O Databricks MVP Hubert Dudek notou que o Azure Databricks lançou em beta o external secrets no Unity Catalog, um jeito de conectar um schema inteiro ao Azure Key Vault. Isso é diferente do UC secrets nativo (já GA desde agosto, quando segredo passou a viver como ativo de catálogo com namespace de três níveis). Ali, o valor fica armazenado dentro do próprio Unity Catalog. Aqui, o Databricks não guarda cópia nenhuma: cada leitura busca o valor direto no Key Vault, e o objeto que aparece no catálogo é só uma referência somente leitura com as permissões do Unity Catalog por cima.

Na prática isso resolve um atrito comum em empresa que já centraliza segredo de aplicação inteira no Azure Key Vault e não quer manter dois lugares de verdade. Em vez de replicar chave de API, connection string ou certificado pro Databricks e depois se preocupar em manter os dois sincronizados, o time de segurança continua rotacionando segredo só no Key Vault, e quem usa Databricks enxerga esse mesmo segredo como um securable normal, com grant, revoke e auditoria de acesso pela trilha do Unity Catalog.

Pontos técnicos que valem atenção:
- Conexão é feita no nível de schema, não segredo por segredo
- Objeto aparece no Unity Catalog como securable somente leitura
- Valor é buscado sob demanda no Azure Key Vault, sem cache persistente dentro do Databricks
- Governança de acesso continua sendo via privilégio do Unity Catalog, não via IAM do Key Vault
- Complementa, não substitui, o UC secrets nativo já em disponibilidade geral

**Minha ressalva:** ter dois modelos de segredo coexistindo, o nativo e o externo, é o tipo de decisão que parece simples no anúncio e vira dúvida real de arquitetura seis meses depois, quando alguém precisa migrar um pra outro ou explicar pra auditoria por que metade dos segredos vive num lugar e metade em outro. Vale definir logo qual é o padrão do time antes de espalhar os dois em produção.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/security/secrets/external-secrets

#Databricks #UnityCatalog #AzureDatabricks
