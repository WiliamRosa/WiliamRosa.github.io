---
title: "As Serverless Micro Apps que faltavam no Databricks Apps chegaram, e vieram acompanhadas"
date: 2026-09-25T11:00:00-03:00
draft: false
tags: ["Databricks", "Databricks Apps", "Genie", "Governança", "Arquitetura"]
summary: "Databricks Apps ganhou em Beta App Spaces (ambiente governado sem sandbox separada), Serverless Micro Apps (escala a zero quando ociosa) e Genie App Builder (criar app em linguagem natural), fechando justamente a lacuna de custo ocioso que ainda restava na plataforma."
ShowToc: false
---

Uma lacuna de custo que ficou marcada aqui há quase um mês acabou de ser fechada, e trouxe duas outras novidades junto.

O Databricks MVP Domonkos Pal testou de perto o pacote de novidades que a Databricks liberou em Beta para Databricks Apps, batizado por ele de "governed agentic app-building": App Spaces, Serverless Micro Apps e Genie App Builder. Complementando o que já vimos aqui sobre a escolha entre Databricks Apps e Model Serving para hospedar agente, na época destacando que Databricks Apps cobrava por hora mesmo ocioso enquanto Model Serving escalava a zero, esse é exatamente o ponto que as Serverless Micro Apps resolvem agora.

App Spaces funciona como um ambiente governado sem exigir workspace de sandbox separado para cada grupo de desenvolvedores: um admin define as regras uma vez, quem autoriza usuário, quais recursos compartilhados o app pode acessar, como SQL warehouse e Genie space, e como o custo é taggeado por orçamento, e todo app criado dentro daquele espaço herda essas regras automaticamente. Serverless Micro Apps resolve o problema oposto ao de Model Serving: a maioria dos apps corporativos não precisa ficar ligada o tempo todo, mas até agora a instância ficava sempre ativa mesmo sem tráfego; agora ela escala a zero quando ociosa e volta a uma instância assim que chega uma nova requisição, herdando os mesmos benefícios de App Spaces. Já o Genie App Builder deixa criar um app inteiro descrevendo em linguagem natural o que ele deve fazer, dentro da própria UI do Databricks, sem sair do workspace: no teste do Domonkos, clonar um app existente envolveu a ferramenta montar um plano, configurar SQL warehouse e Genie space sozinha, escrever os arquivos de query SQL, rodar validação e mostrar uma prévia funcionando.

Pontos técnicos que valem registrar:
- App Spaces centraliza quem gerencia o espaço, autorização de usuário e app, recursos compartilhados e billing taggeado por orçamento, tudo em um lugar
- Serverless Micro Apps escala a zero quando ociosa e volta a uma instância na próxima requisição, herdando as mesmas regras do App Space
- Genie App Builder gera plano, conecta SQL warehouse e Genie space, escreve consultas e mostra prévia ao vivo a partir de um pedido em linguagem natural
- As três features chegaram juntas em Beta, reforçando que o desenvolvimento de app inteiro, do sandbox ao deploy, deve ficar dentro do próprio workspace

**Minhas considerações:** o timing chama atenção porque a lacuna do custo ocioso em Databricks Apps não era teórica, era uma limitação concreta que já discutimos aqui como um dos critérios de decisão entre Apps e Model Serving. Ver a Databricks endereçar isso tão rápido é bom sinal de que a plataforma está ouvindo esse tipo de reclamação recorrente, mas o Genie App Builder ainda merece ceticismo saudável até escalar: gerar um plano bonito clonando um app existente é bem diferente de sustentar app complexo de produção só com prompt, sem alguém revisando cada arquivo gerado.

**Fonte:** https://www.linkedin.com/in/paldom/

#Databricks #DatabricksApps #Genie
