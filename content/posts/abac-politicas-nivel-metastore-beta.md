---
title: "Uma política ABAC agora cobre todos os catálogos do metastore de uma vez"
date: 2026-09-18T08:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "ABAC", "Governança de Dados"]
summary: "O Azure Databricks lançou em Beta o suporte a políticas ABAC no nível do metastore, permitindo que uma única política de row filter, column mask, GRANT ou DENY cubra todos os catálogos automaticamente, inclusive os criados depois, mas com uma lacuna real em disaster recovery."
ShowToc: false
---

Em vez de replicar a mesma política catálogo por catálogo, agora dá pra anexá-la direto na raiz do metastore.

O Azure Databricks lançou em Beta o suporte a políticas ABAC (attribute-based access control) no nível do metastore, a raiz da hierarquia do Unity Catalog. Uma política anexada ali passa a valer automaticamente pra todo catálogo, esquema e objeto compatível dentro daquele metastore, incluindo catálogo criado depois que a política já existia, sem precisar de nenhuma ação extra de quem administra o catálogo novo.

Os quatro tipos de política ABAC (row filter, column mask, GRANT e DENY) são suportados nesse escopo, usando os mesmos campos, condições e comportamento de avaliação de qualquer outra política ABAC, mudando só o alcance. Como o metastore em si não pode receber tag diretamente, política baseada em tag continua exigindo que a tag governada seja aplicada em cada catálogo ou objeto de nível mais baixo que precisa ser coberto.

Pontos técnicos que valem atenção:
- Criar, alterar ou apagar política de metastore exige o papel de metastore admin; listar ou visualizar exige READ METADATA ou metastore admin
- Criar a política via SQL exige compute rodando Databricks Runtime 19 ou superior
- Limite de 10 mil políticas de row filter/column mask e 10 mil de GRANT/DENY por metastore, com cota de 100 políticas anexadas diretamente no metastore em cada categoria
- GRANT e DENY no nível de metastore não conseguem mirar objeto fora da hierarquia de catálogo, como external location, storage credential, share, recipient, provider e connection
- `SHOW EFFECTIVE POLICIES` numa consulta em catálogo específico já mostra a política herdada do metastore, o que ajuda a auditar o que está realmente em vigor

**Minha ressalva:** o ponto que mais chama atenção nessa versão Beta é a lacuna em disaster recovery, política de nível metastore não é replicada pela recuperação gerenciada do Unity Catalog quando o ambiente falha para uma região secundária. Isso significa que um objeto protegido hoje por uma política de metastore pode ficar exposto sem aviso depois de uma recuperação de desastre, e vale documentar esse risco explicitamente em qualquer plano de DR que já dependa (ou vá passar a depender) de ABAC nesse escopo.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/abac/metastore-policies

#Databricks #UnityCatalog #Governanca
