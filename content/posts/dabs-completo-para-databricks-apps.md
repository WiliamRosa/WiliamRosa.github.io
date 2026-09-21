---
title: "Databricks Asset Bundles viraram o jeito completo de publicar um Databricks App inteiro"
date: 2026-09-17T09:00:00-03:00
draft: false
tags: ["Databricks", "Databricks Asset Bundles", "Databricks Apps", "Lakebase"]
summary: "Uma série de atualizações nos Databricks Asset Bundles neste verão tornou o deploy de um Databricks App completo, incluindo banco Lakebase, índice de busca e segredos, uma operação de um único arquivo databricks.yml e um só comando de bundle."
ShowToc: false
---

Um único arquivo databricks.yml agora empacota o app, o banco Lakebase, o índice de busca e os segredos, e um só bundle sobe tudo de uma vez.

O Databricks MVP Domonkos Pal detalhou como uma série de atualizações nos Databricks Asset Bundles ao longo deste verão europeu tornou o deploy de um Databricks App uma experiência de um clique só. Antes, publicar um app exigia rodar comando extra de CLI e clicar em vários lugares da interface pra provisionar cada peça, banco de dados, índice de busca, escopo de segredo, separadamente.

O recurso de app dentro do bundle amadureceu: configuração inline, compute_size, escopos de OBO (on-behalf-of), telemetria enviada pro Unity Catalog e a opção lifecycle.started, que já inicia o app assim que o deploy termina. A peça central da mudança são os bindings, que substituem credencial manual por declaração no próprio bundle: postgres, secret, serving_endpoint, genie_space, uc_securable e mais cinco tipos, cada um concedendo ao service principal do app exatamente uma permissão e chegando como variável de ambiente pronta pra usar. Tudo ao redor do app também virou recurso do bundle, banco Lakebase com autoscaling de verdade (não só provisionamento estático), índice de vector search, Genie Agents, experimento de MLflow com rastreamento no Unity Catalog, warehouse e dashboard.

Detalhes técnicos que valem registrar:

- O engine de deploy "direct" já é o padrão pra bundle novo, sem passar por Terraform
- Hooks: prebuild roda o build do frontend, postdeploy cuida das concessões de permissão depois que tudo já existe
- Guardrails: validate --strict, um recurso só por arquivo `<chave>.<tipo>.yml`, faixa de versão fixa da CLI, e bundle deployment bind pra adotar recurso que já existia antes do bundle
- Segredo (o valor em si) deve continuar fora do bundle, mas a declaração do escopo dentro do bundle já basta pra liberar o app numa única execução
- Resultado prático: ambiente de dev, staging e produção passam a diferir só pelas variáveis de target, não pelo código do app, o que abre espaço pra revisar permissão como parte do código-fonte

**Minha ressalva:** empacotar app, banco, índice e segredo no mesmo arquivo é ótimo pra velocidade, mas também aumenta o raio de estrago de um bundle mal configurado, um erro de binding agora pode vazar acesso a Lakebase e a um serving endpoint de uma vez só, não apenas a um recurso isolado. Quem já tem bundle rodando com Terraform também precisa migrar pro engine direct em algum momento, já que o suporte a Terraform está no caminho da deprecação.

**Fonte:** https://www.linkedin.com/in/paldom/#dabs-completo-databricks-apps

#Databricks #DatabricksAssetBundles #DatabricksApps
