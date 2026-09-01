---
title: "Chega de copiar e colar ID do Key Vault entre Terraform e bundle — agora é só JSON"
date: 2026-05-02T09:15:00-03:00
draft: false
tags: ["Databricks", "Terraform", "Declarative Automation Bundles", "DevOps", "Opinião"]
summary: "Terraform provisiona a infraestrutura, os bundles gerenciam a camada Databricks — e a integração entre os dois deixou de depender de mensagem no Slack com o ID copiado manualmente."
ShowToc: false
---

❗ Quando Terraform provisiona a infraestrutura de nuvem e Declarative Automation Bundles gerenciam a camada Databricks, a integração entre os dois historicamente era... uma pessoa copiando um ID de um lugar e colando no outro, às vezes avisando no Slack quando algo mudava. Isso não é integração, é um ponto único de falha esperando acontecer.

A correção documentada é simples de descrever: o Terraform já sabe emitir saída como JSON, e os bundles já sabem ler um arquivo JSON de override no momento do deploy. Juntar essas duas capacidades que já existiam elimina o processo manual por completo — sem ferramenta nova, só conectando o que já estava disponível.

Por que vale adotar esse padrão mesmo em ambiente pequeno:
- Elimina o "alguém precisa lembrar de atualizar aquele ID manualmente" que sempre vira incidente em algum momento
- Não exige nenhuma ferramenta adicional — é reorganização de um fluxo que o Terraform e os bundles já suportavam separadamente
- Documenta a dependência entre infraestrutura e bundle como código, em vez de conhecimento tribal guardado na cabeça de uma pessoa só

❗ Minha ressalva: automatizar a passagem de ID entre Terraform e bundle resolve o sintoma de "cola manual", mas não resolve sozinho o problema de quem decide a ordem de execução — Terraform precisa rodar e terminar antes do bundle consumir o JSON, e essa dependência sequencial no pipeline de CI/CD merece ficar tão explícita quanto a própria integração de dados.

🔗 Fonte: https://www.sunnydata.ai/blog/declarative-automation-bundles-terraform-variable-overrides

#Databricks #Terraform #DevOps
