---
title: "Um dashboard publicado, segurança diferente para cada pessoa que abre ele"
date: 2026-09-10T09:00:00-03:00
draft: true
tags: ["Databricks", "AI/BI", "Unity Catalog", "Segurança", "Opinião"]
summary: "A Databricks detalhou um padrão para aplicar segurança em nível de linha em AI/BI Dashboards incorporados, usando um token assinado por visualizador, uma tabela de direitos de acesso central e as proteções nativas do Unity Catalog."
ShowToc: false
---

Um único dashboard publicado, mas cada visualizador externo só enxerga a fatia de dado que pode ver, sem precisar de uma cópia por cliente.

A Databricks publicou um padrão para embutir AI/BI Dashboards em produtos e portais de terceiros aplicando segurança em nível de linha por visualizador. O mecanismo combina três peças: um parâmetro assinado que representa o escopo de quem está vendo o dashboard (definido do lado do servidor, não manipulável pelo visualizador), uma tabela de direitos de acesso que funciona como fonte única de verdade mapeando escopo para região de dado e regra de mascaramento, e as proteções nativas do Unity Catalog (row filter e column mask) garantindo que a mesma regra valha tanto no dashboard incorporado quanto numa consulta SQL direta.

Pontos técnicos que valem atenção:
- Um service principal de backend gera o token com dois campos: identificador do visualizador externo (para auditoria) e o valor de escopo em si, com tamanho combinado limitado a cerca de 1 KB
- A tabela de direitos de acesso é consultada via join com as tabelas base, usando o valor assinado como chave
- Para usuário interno, o escopo vem de grupo do provedor de identidade, não de lista manual de usuário
- Mascaramento de coluna também varia por tipo de visualizador, parceiro externo enxerga menos coluna que time interno
- Token sem autorização é recusado antes mesmo de chegar ao dado, um "default-deny" aplicado na emissão, não na consulta

**Minhas considerações:** o ponto mais importante aqui não é a criptografia do token, é onde mora a fonte da verdade: colocar a regra de acesso numa tabela consultável via join, em vez de espalhar lógica de permissão em código de aplicação, é o que permite auditar e alterar a regra sem tocar no dashboard. Vale a pena revisitar esse padrão antes de qualquer projeto de embutir dashboard pra cliente externo, porque errar a modelagem da tabela de direitos custa caro depois que já tem parceiro em produção.

**Fonte:** https://www.databricks.com/blog/beyond-embedding-how-secure-aibi-dashboards-every-viewer

#Databricks #AIBI #UnityCatalog
