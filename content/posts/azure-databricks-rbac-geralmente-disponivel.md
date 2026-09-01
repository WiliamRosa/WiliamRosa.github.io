---
title: "RBAC chegou ao Azure Databricks — e muda a lógica de permissão acumulada"
date: 2026-08-20T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "RBAC", "Governança", "Segurança", "Opinião"]
summary: "Com RBAC em GA, um usuário passa a assumir um papel específico em vez de carregar todas as permissões que já acumulou — uma mudança de modelo mental, não só uma feature nova."
ShowToc: false
---

❗ RBAC (role-based access control) atingiu disponibilidade geral no Azure Databricks. A mudança de modelo é mais importante do que a sigla sugere: em vez de operar sempre com a soma de todas as permissões que um usuário acumulou ao longo do tempo, ele passa a poder **assumir um papel específico**, e só as permissões daquele papel valem durante a sessão.

Isso ataca um problema clássico de governança que cresce silenciosamente: usuário antigo numa empresa grande, que trocou de time três vezes, geralmente carrega permissão de todos os times por onde passou — porque revogar acesso é sempre a etapa que ninguém prioriza.

Por que isso muda a prática, não só a teoria:
- Auditoria fica mais simples: "que papel essa pessoa estava usando quando fez X" é uma pergunta melhor que "quais das 40 permissões acumuladas ela usou"
- Reduz superfície de erro: assumir o papel errado de propósito é mais difícil que só "ter permissão sobrando sem perceber"
- Abre caminho pra automação de acesso temporário — assumir um papel por tempo limitado, sem processo manual de revogação depois

❗ Minha ressalva: RBAC bem feito depende de papéis bem desenhados. Se a empresa só recriar a bagunça de permissões acumuladas dentro de "papéis" genéricos demais, a mudança de modelo não entrega o benefício — o problema de governança simplesmente muda de nome.

🔗 Fonte: https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/august

#AzureDatabricks #RBAC #Governança
