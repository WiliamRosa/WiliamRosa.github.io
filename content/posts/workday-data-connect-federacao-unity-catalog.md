---
title: "Ler tabela do Workday direto do Unity Catalog, sem pipeline de ingestão no meio"
date: 2026-10-02T09:00:00-03:00
draft: false
tags: ["Databricks", "Unity Catalog", "Federação", "Opinião"]
summary: "Workday Data Connect catalog federation (Beta) registra tabela do Workday como foreign table no Unity Catalog, lida direto do cloud storage via autenticação OAuth com Integration System User, sem copiar dado nem construir pipeline de ingestão, mas só em modo de acesso padrão."
ShowToc: false
---

A Databricks lançou em Beta a federação de catálogo pro Workday Data Connect, deixando tabela de HR e financeiro do Workday aparecer direto dentro do Unity Catalog, sem exigir pipeline de ingestão pra copiar o dado antes.

O mecanismo é federação, não ingestão: a Databricks lê a tabela do Workday Data Connect direto do cloud storage onde ela já mora e registra como foreign table dentro do Unity Catalog, com acesso somente leitura. Pra autenticar, o Databricks se conecta como um Workday Integration System User (ISU) que você registra como principal, usando OAuth com chave privada em formato PEM, e dá pra restringir esse principal a um papel específico em vez de liberar acesso total por padrão. Isso é uma categoria diferente dos conectores Workday HCM e Workday Reports do Lakeflow Connect, que ingerem e copiam o dado pra dentro do Databricks, aqui o dado nunca sai do storage original do Workday.

Pontos técnicos da configuração:

- Workspace precisa estar habilitado pra Unity Catalog, e o recurso precisa ser ligado manualmente na página de Previews
- Compute precisa rodar Databricks Runtime 19.8 ou superior, em modo de acesso padrão, modo de acesso dedicado não é suportado
- Databricks precisa de acesso de rede ao endpoint `https://<workday-host>/api/catalog`, sem exigir allowlist de IP do lado do Workday
- Criar a conexão exige privilégio de metastore admin ou CREATE CONNECTION
- O próprio Workday chama esse produto de Workday Data Lake, a documentação de parceiro da Databricks é que usa o nome Workday Data Connect

**Minha ressalva:** a exigência de modo de acesso padrão, sem suporte a modo dedicado, é uma limitação real pra quem já isola carga de trabalho sensível de RH e financeiro em compute dedicado por política interna. Vale testar se essa combinação de federação com Unity Catalog preserva o controle fino de acesso que esse tipo de dado normalmente exige antes de assumir que já dá pra abrir mão do pipeline de ingestão tradicional pro Workday.

**Fonte:** https://docs.databricks.com/aws/en/query-federation/workday-data-connect

#Databricks #UnityCatalog #Federacao
