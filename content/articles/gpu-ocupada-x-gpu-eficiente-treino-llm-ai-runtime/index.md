---
title: "GPU ocupada não é GPU eficiente: o que um treino de LLM revela sobre a métrica que todo mundo olha errado"
date: 2026-10-15T09:00:00-03:00
draft: true
tags: ["Azure Databricks", "AI Runtime", "GPU", "Fine-tuning"]
ShowToc: true
summary: "Um pipeline de pós-treinamento no Azure Databricks AI Runtime mostra por que 98% de utilização de GPU pode esconder desperdício real: trocando kernel genérico por kernel fundido e padding por sequência empacotada, o mesmo job de fine-tuning caiu de quase 8 horas pra pouco mais de 1, sem mudar uma linha de hardware."
---

Toda equipe que já otimizou treino de modelo já viu esse número no dashboard: 98% de utilização de GPU. Parece ótimo, parece o teto do que dá pra extrair do hardware. Só que esse número mede uma coisa muito mais simples do que parece: ele diz se a GPU estava ocupada, não se ela estava fazendo trabalho útil. Uma GPU pode estar 98% do tempo executando uma sequência enorme de operações pequenas e redundantes, e o dashboard não distingue isso de 98% do tempo executando o kernel certo. Foi exatamente esse buraco que apareceu num job de fine-tuning de um modelo da família Qwen rodando no Azure Databricks AI Runtime, e o jeito de fechar esse buraco virou um estudo de caso interessante sobre onde o tempo de treino realmente vai.

## O sintoma: utilização alta, throughput baixo

O setup inicial já parecia saudável à primeira vista: fine-tuning supervisionado (SFT) de um modelo Qwen de porte considerável, usando FSDP2 (Fully Sharded Data Parallel, versão 2) pra distribuir os parâmetros do modelo entre GPUs, mais checkpoint de ativação pra economizar memória. A utilização de GPU reportada ficava em 98%, um número que normalmente faria qualquer engenheiro de ML respirar aliviado e seguir pra outra tarefa.

O problema é que a métrica de utilização, do jeito que a maioria das ferramentas de monitoramento reporta, só olha se existe algum kernel rodando na GPU naquele instante de amostragem. Ela não sabe (e não tem como saber, sem um profiler de verdade) se aquele kernel é grande e eficiente ou pequeno e repetido milhares de vezes. Throughput medido em tokens por segundo contou a história real: o baseline processava uma quantidade de tokens por segundo bem abaixo do que a capacidade teórica das GPUs sugeria, e o job inteiro levava quase 8 horas pra completar.

**Minha leitura:** esse descompasso entre "GPU ocupada" e "GPU produtiva" é um dos erros de diagnóstico mais comuns que vejo em time de dado que começa a treinar modelo próprio. A reação natural quando o treino está lento é pedir mais GPU, ou uma GPU mais potente. Só que se o gargalo é um padrão de execução ruim (muita operação pequena, muito padding desperdiçado), jogar mais hardware em cima só faz a mesma ineficiência rodar em paralelo, sem resolver a causa.

## Onde o tempo realmente estava indo: profiler, não dashboard

A virada de chave veio de trocar a métrica de utilização por um profiler de verdade, que mede tempo de CPU (o processo Python orquestrando o treino) separado de tempo de GPU (os kernels CUDA de fato executando), e conta quantas vezes cada tipo de operação é chamado.

O baseline mostrou um padrão revelador: um número gigantesco de chamadas de operação, a maioria delas pequenas, elementwise (soma, multiplicação, normalização, uma de cada vez), ao lado de um número bem menor de operações de GPU propriamente ditas. Isso é a assinatura clássica de um modelo cuja arquitetura tem uma camada "exótica", no caso uma camada de rede delta com porta (gated delta network), que não tem um kernel fundido pronto no ecossistema padrão de treino, e por isso cai de volta pra implementação ingênua: uma sequência longa de operações pequenas do PyTorch, cada uma delas lançada separadamente, cada lançamento com overhead de CPU.

## O que resolveu a primeira parte: trocar operação pequena por kernel fundido

A solução pra esse primeiro gargalo foi instalar implementações de kernel especializadas, construídas especificamente pra esse tipo de camada: uma biblioteca de atenção linear fundida (flash-linear-attention) e uma de convolução causal 1D (causal-conv1d). Em vez de uma cadeia de dezenas de operações pequenas, a GPU passa a executar um ou poucos kernels grandes que já fazem o trabalho equivalente internamente, em CUDA otimizado.

O resultado disso isolado já foi expressivo: o tempo total do job caiu de quase 8 horas pra pouco mais de 2, uma redução de cerca de 3,7 vezes, só trocando a implementação da camada problemática, sem tocar em mais nada do resto do pipeline.

Vale registrar duas decisões técnicas que ficaram de fora: CUDA Graphs (que captura uma sequência de operações pra reexecutar com menos overhead de lançamento) foi descartado porque conflita com o jeito como FSDP2 reparte parâmetros dinamicamente entre GPUs; e `torch.compile`, a ferramenta de compilação just-in-time do PyTorch, não trouxe ganho relevante nesse caso específico.

## O segundo gargalo: padding desperdiçando compute

Depois de resolver o problema do kernel, ainda sobrava desperdício, esse de natureza bem diferente: desperdício de forma, não de implementação.

Treino de linguagem em lote normalmente empacota exemplos de tamanhos diferentes numa matriz 2D de tamanho fixo, preenchendo o espaço vazio com token de padding. Se um lote tem um exemplo de 8.000 tokens e outro de 500, o exemplo curto ocupa uma linha inteira do tamanho do mais longo, com a maior parte dela sendo padding que não carrega informação nenhuma, mas que ainda consome ciclo de GPU pra ser processado (e depois ignorado via máscara de atenção).

A correção foi trocar lotes 2D com padding por sequências empacotadas (packed sequences) em formato 1D: em vez de várias linhas de tamanho fixo com espaço vazio, uma única sequência longa e contígua, concatenando os exemplos reais um atrás do outro. A parte delicada aqui é garantir que cada exemplo só preste atenção em si mesmo, não no exemplo vizinho dentro da mesma sequência concatenada, o que exige calcular corretamente os `position_ids` (os índices de posição) pra cada sub-segmento, resetando a contagem a cada novo exemplo dentro do pacote.

```python
# Esboço conceitual de como montar position_ids para sequências empacotadas,
# escrito a partir do mecanismo descrito, não copiado de nenhuma fonte.
# Cada "boundary" marca onde um exemplo termina e o próximo começa
# dentro da sequência empacotada (1D), para resetar a posição relativa.

def build_packed_position_ids(example_lengths: list[int]) -> list[int]:
    position_ids = []
    for length in example_lengths:
        # cada exemplo dentro do pacote reinicia sua própria contagem de posição
        position_ids.extend(range(length))
    return position_ids

# exemplo_lengths = [820, 1450, 390] (três exemplos concatenados num único pacote)
# position_ids resultante: [0..819, 0..1449, 0..389]
# a máscara de atenção, à parte, garante que o token na posição 50
# do segundo exemplo nunca atenda ao primeiro exemplo do pacote.
```

O ganho dessa segunda mudança foi de cerca de 1,6 vez em cima do que já tinha sido conquistado com os kernels fundidos, reduzindo o número total de lotes processados em torno de 36%, além de eliminar parte do overhead de compilação just-in-time que aparecia quando cada lote tinha uma forma (shape) ligeiramente diferente. Empilhando as duas otimizações, o job foi de quase 8 horas pra pouco mais de 1 hora, um ganho combinado de aproximadamente 6 vezes.

{{< figure src="packed-batching-vs-padding.png" alt="Diagrama comparando lote 2D com padding desperdiçado contra sequência 1D empacotada sem espaço vazio" caption="Lote tradicional com padding (acima) desperdiça ciclo de GPU em token vazio; sequência empacotada em 1D (abaixo) concatena exemplos reais sem espaço morto, mantendo o isolamento de atenção via position_ids reiniciado por segmento." >}}

## O que isso não resolve

Vale ser honesto sobre o alcance dessa otimização. Ela ataca dois gargalos específicos (camada sem kernel fundido, e padding desperdiçado), que são comuns mas não universais. Um modelo cuja arquitetura já usa só camadas padrão, com kernel fundido maduro no ecossistema (atenção padrão, MLP convencional), provavelmente já não sofre do primeiro problema. E um dataset cujos exemplos já têm tamanho bem uniforme entre si sofre menos do segundo, porque há menos padding pra eliminar em primeiro lugar.

Outro ponto que fica de fora: o ganho de kernel especializado depende de a versão instalada ser realmente compatível com a versão do CUDA e do PyTorch do ambiente. Quando ela não é, bibliotecas desse tipo tendem a cair de volta pra uma implementação mais lenta silenciosamente, sem erro explícito, o que transforma um ganho de performance esperado numa pista falsa difícil de depurar sem comparar número de chamada de kernel antes e depois.

**Minha ressalva:** a lição mais generalizável aqui não é "use flash-linear-attention e causal-conv1d", porque isso só vale pra arquitetura com esse tipo específico de camada. A lição real é metodológica: nunca aceite "utilização de GPU" como prova de eficiência sem abrir um profiler e contar quantas chamadas de operação pequena estão competindo por tempo de CPU contra um número bem menor de kernels de GPU de fato relevantes. Esse diagnóstico simples (contagem de chamada, não só percentual de ocupação) é reaproveitável em qualquer pipeline de treino, independente de qual camada ou arquitetura está causando o gargalo.

## Vale adotar esse tipo de diagnóstico?

Sim, e a parte mais barata de adotar é a mentalidade, não a ferramenta. Antes de pedir mais GPU ou uma GPU mais cara pra um treino lento, vale rodar um profiler padrão (o do próprio PyTorch já serve) por alguns passos de treino e perguntar duas coisas: quantas chamadas de operação pequena estão competindo com o tempo de GPU disponível, e quanto do lote processado é token real versus token de padding. Essas duas perguntas, sozinhas, já apontam pra boa parte dos ganhos que esse caso descreve, antes de qualquer decisão de infraestrutura mais cara.

No Azure Databricks AI Runtime especificamente, o ambiente já traz CUDA e Flash Attention atualizados por padrão, e expõe métrica de utilização, temperatura e saúde da GPU direto na interface de monitoramento do job, o que facilita abrir esse tipo de investigação sem montar instrumentação própria do zero. Construir a imagem de container com os kernels especializados pré-instalados, em vez de instalar na hora da inicialização do job, também reduz o tempo de start up de cada execução subsequente, algo que vale considerar pra quem itera esse tipo de pipeline com frequência.

## Referências

- Databricks Blog, "Reducing Qwen training time by 6x on AI Runtime": https://www.databricks.com/blog/reducing-qwen-training-time-6x-ai-runtime
- Databricks Docs (AWS), "Use custom Docker images with AI Runtime": https://docs.databricks.com/aws/en/machine-learning/ai-runtime/cli/docker-images
- Microsoft Learn, "Use custom Docker images with AI Runtime - Azure Databricks": https://learn.microsoft.com/en-us/azure/databricks/machine-learning/ai-runtime/cli/docker-images
- PyTorch, "FSDP2 tutorial": https://docs.pytorch.org/tutorials/intermediate/FSDP_tutorial.html
- PyTorch Blog, "FlashAttention-3": https://pytorch.org/blog/flashattention-3/

#AzureDatabricks #AIRuntime #GPU #FineTuning
