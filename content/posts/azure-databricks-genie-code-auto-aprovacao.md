---
title: "Genie Code ganhou modo de auto-aprovação — com um classificador de IA decidindo por você"
date: 2026-06-05T09:15:00-03:00
draft: false
tags: ["Azure Databricks", "Genie Code", "Agentes de IA", "Segurança", "Opinião"]
summary: "Auto-aprovação tira o prompt de confirmação a cada ação do Genie Code — mas quem decide o que é 'arriscado' é um classificador de IA, não uma barreira de segurança."
ShowToc: false
---

O Genie Code agora tem um modo de auto-aprovação: ações de ferramenta (rodar código, editar notebook) deixam de pedir confirmação a cada passo. Um classificador de IA revisa cada ação e bloqueia as consideradas arriscadas.

A documentação oficial já vem com o aviso mais importante embutido: auto-aprovação é feature de produtividade, não barreira de segurança. A recomendação da própria Databricks é manter desligado ao trabalhar com dado de produção ou recurso compartilhado.

Por que vale prestar atenção nesse detalhe:
- Ganho de produtividade é real — parar de confirmar toda ação pequena economiza tempo de quem já confia no agente pra tarefas repetitivas
- "Classificador de IA bloqueia ação arriscada" é probabilístico, não determinístico — não existe garantia formal de que toda ação perigosa será pega
- A própria Databricks reconhece isso explicitamente, o que é honesto, mas não muda o risco de quem ativa sem ler a letra miúda

**Minha ressalva:** qualquer feature que a documentação já avisa "isso não é barreira de segurança" deveria vir com um toggle de workspace, não só de usuário individual — decisão de segurança dessa magnitude não deveria ficar só na mão de quem está com pressa às 17h de sexta-feira.

**Fonte:** https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/june

#AzureDatabricks #GenieCode #SegurançaDeIA
