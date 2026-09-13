---
title: "Automatic Identity Management chegou pra AWS e GCP, e Okta entrou em preview"
date: 2026-09-14T16:00:00-03:00
draft: true
tags: ["Databricks", "Unity Catalog", "Segurança", "Opinião"]
summary: "O AIM (Automatic Identity Management) via Entra ID já era GA no Azure Databricks e agora chega GA também em AWS e GCP, com Okta entrando em preview público; junto vieram políticas de ingress baseadas em contexto pra controlar acesso de agente de IA a Genie, dashboard e Databricks Apps."
ShowToc: false
---

O Databricks MVP Juan Diaz chamou atenção pra uma expansão de identidade que importa justamente porque governança de agente de IA depende de saber, com precisão, quem ou o quê está pedindo acesso.

O AIM sincroniza usuário, grupo e associação de grupo direto do provedor de identidade pra dentro do Databricks, eliminando a necessidade de manter provisionamento via SCIM em paralelo. O recurso já era GA via Entra ID especificamente no Azure Databricks; agora a mesma capacidade GA chega também pra AWS e GCP, e o Okta entra como provedor suportado em preview público. Isso importa mais do que parece numa organização multi-cloud, porque até aqui o time de identidade precisava manter estratégia diferente de sincronização dependendo de qual nuvem hospedava qual workspace.

Junto dessa expansão vieram as políticas de ingress baseadas em contexto, que controlam acesso de agente de IA a recursos como Genie, dashboard e Databricks Apps não só pela identidade de quem está por trás do agente, mas pelo contexto da requisição em si. É uma peça que fecha lacuna real de segurança à medida que mais agente autônomo passa a interagir com dado corporativo sem uma pessoa clicando em cada etapa.

Pontos técnicos:

- AIM via Entra ID: GA em AWS e GCP, complementando GA que já existia no Azure Databricks
- Okta como provedor de identidade para AIM: preview público
- Sincronização automática de usuário, grupo e associação de grupo do provedor de identidade, dispensando SCIM
- Sincronização de grupo aninhado funciona com Entra ID; Okta não suporta grupo aninhado
- Políticas de ingress baseadas em contexto controlam acesso de agente de IA a Genie, dashboard e Databricks Apps

**Minha ressalva:** a diferença de suporte a grupo aninhado entre Entra ID e Okta é o tipo de detalhe que só aparece depois que a migração já começou, então quem usa Okta e depende de hierarquia de grupo complexa precisa mapear isso antes de trocar o modelo de provisionamento, não depois. Vale também lembrar que Okta ainda está em preview, não GA, então mudança de comportamento até a estabilização é esperada.

Fonte: https://www.databricks.com/blog/automatic-identity-management-entra-id-now-generally-available-azure-databricks

#Databricks #Segurança #AzureDatabricks
