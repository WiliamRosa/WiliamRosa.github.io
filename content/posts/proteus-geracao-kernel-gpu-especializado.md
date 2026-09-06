---
title: "A Databricks construiu um agente que escreve e valida kernel de GPU sozinho"
date: 2026-09-05T09:00:00-03:00
draft: true
tags: ["Databricks", "GPU", "Inferência", "Opinião"]
summary: "O Proteus propõe, valida e faz benchmark de kernel de GPU especializado por formato de operação, com um estudo de caso no Gated DeltaNet do Qwen 3.5 122B atingindo de 1,8x a 5,2x de speedup sobre a melhor implementação do vLLM."
ShowToc: false
---

Kernel de GPU genérico serve qualquer modelo, mas não é ótimo pra nenhum, e a Databricks resolveu isso deixando um agente escrever o kernel especializado sozinho.

A Databricks detalhou o Proteus, um sistema que propõe kernel de GPU candidato, valida contra uma implementação de referência controlada, faz benchmark e itera até chegar numa versão especializada pro formato exato de operação em jogo. A motivação é que o formato de uma operação varia tanto pelo tamanho do modelo quanto por fator dinâmico do pedido em produção, e servir tudo isso com um kernel genérico deixa desempenho na mesa.

O ponto que a equipe mais destacou não foi a velocidade de busca por kernels novos, foi a robustez do validador. Pra evitar que o próprio sistema aprenda a otimizar o benchmark em vez do desempenho real, o checador usa múltiplos métodos de cronometragem, limpa estado compilado residual entre execuções, roda contra conjunto de teste nunca visto e sinaliza automaticamente qualquer speedup fisicamente impossível. Do lado do prompt, uma camada de conhecimento guarda só contexto de alta confiança, do tipo situação específica pareada com ação, recuperado por filtragem hierárquica, pra não gastar token com informação genérica ou desatualizada.

Pontos técnicos que valem atenção:
- O sistema propõe kernel candidato, valida contra referência controlada, faz benchmark e itera
- Validador rigoroso evita otimizar o benchmark em vez do desempenho real, com timing múltiplo, limpeza de estado compilado e teste em dado nunca visto
- Camada de conhecimento retém só contexto de alta confiança, evitando prompt inchado com informação genérica
- Estudo de caso: kernel de packed decode do Gated DeltaNet no Qwen 3.5 122B (NVIDIA B200) saiu de baseline de 0,025ms pra versões específicas por formato, com ganho de 1,5x a 1,6x por formato individual
- Resultado agregado: speedup de 1,8x a 5,2x sobre a melhor implementação equivalente do vLLM

**Minha ressalva:** o próprio material reconhece que o maior risco desse tipo de sistema é o gerador de kernel aprender a passar no benchmark em vez de entregar ganho real, e é por isso que boa parte do esforço foi construir o verificador, não o gerador. Vale lembrar também que o speedup de 1,8x a 5,2x foi medido num par específico, modelo Qwen 3.5 122B rodando em B200, o número não necessariamente se repete pra outra combinação de modelo e hardware.

**Fonte:** https://www.databricks.com/blog/achieving-extreme-efficiency-through-specialized-gpu-kernel-generation

#Databricks #GPU #InferenciaIA
