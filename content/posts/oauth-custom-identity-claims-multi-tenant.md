---
title: "Um service principal só, mil clientes diferentes, cada um vendo só a própria linha"
date: 2026-10-20T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Unity Catalog", "Seguranca", "Multi-tenant"]
summary: "Custom identity claim injeta um identificador assinado no token OAuth de um service principal, lido via current_oauth_custom_identity_claim() dentro de view dinâmica ou política ABAC, deixando uma aplicação multi-tenant servir usuário final sem criar conta individual no Azure Databricks pra cada um."
ShowToc: false
---

Toda aplicação multi-tenant que consulta Azure Databricks através de um único service principal esbarra no mesmo problema: como garantir que o cliente A nunca veja a linha do cliente B, sem precisar criar e gerenciar uma identidade individual dentro do workspace pra cada usuário final da aplicação.

O mecanismo novo resolve isso injetando um identificador personalizado, assinado, dentro do próprio token OAuth que a aplicação já usa pra autenticar o service principal. Esse identificador passa pro motor SQL no momento da autenticação e fica disponível via a função `current_oauth_custom_identity_claim()`, que uma view dinâmica ou uma política ABAC usa pra filtrar linha automaticamente, sem a aplicação precisar reescrever a consulta.

O ponto de atenção mais importante é o comportamento com claim ausente: a função retorna `NULL` quando o token não carrega identificador nenhum, e qualquer filtro escrito incorretamente (tipo usar `COALESCE` ou o operador de igualdade nula `<=>`) pode acabar devolvendo linha de todo cliente nesse cenário, em vez de nenhuma. A documentação é explícita que o filtro correto precisa ser uma comparação direta (`coluna = current_oauth_custom_identity_claim()`), porque comparação contra `NULL` com `=` nunca retorna verdadeiro.

Pontos técnicos do mecanismo:

- Requer Databricks Runtime 19.7 ou superior e funciona via driver JDBC, SQL Statement Execution API e API de conversa do Genie Agents, mas não no editor SQL da própria interface do workspace
- Claim tem limite de 1.000 caracteres, aceita texto multi-linha, mas não aceita caractere acentuado nem emoji
- Dá pra usar política ABAC em vez de view dinâmica quando outro usuário, como o autor de um Genie Agent testando a lógica, ainda precisa consultar a tabela inteira sem o filtro
- Padrão recomendado pra identidade real de usuário final é guardar só um ID no claim e fazer join contra uma tabela de mapeamento separada, assim trocar o acesso de alguém é só atualizar uma linha, sem mudar como a aplicação gera token
- Cada conversa do Genie Agent pertence ao service principal, não ao usuário final, então a aplicação ainda precisa rastrear por conta própria qual usuário iniciou qual conversa antes de deixar alguém continuar ela

**Minha ressalva:** o aviso mais sério da documentação é que o Azure Databricks não criptografa nem interpreta o claim, qualquer um que tenha o token em mãos consegue decodificar e ler o valor. Isso é razoável pra um identificador de tenant tipo nome de cliente, mas desqualifica esse mecanismo pra carregar qualquer coisa remotamente sensível. E o detalhe do filtro que silenciosamente vaza dado quando o claim vem nulo é exatamente o tipo de bug que passa despercebido em revisão de código até aparecer em produção, vale escrever teste automatizado específico pra esse caso antes de confiar esse padrão com dado de cliente real.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/dev-tools/auth/oauth-custom-identity-claims

#AzureDatabricks #UnityCatalog #Seguranca
