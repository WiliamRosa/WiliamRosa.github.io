---
title: "O PostgreSQL 19 atrasou um mês: o preço de deixar LLM achar bug antes do usuário"
date: 2026-11-20T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Lakebase", "PostgreSQL", "Engenharia de Software"]
ShowToc: true
summary: "O PostgreSQL 19 saiu cerca de um mês depois do período usual. A causa não foi uma feature quebrada, foi um salto na quantidade de bugs e falhas de segurança encontrados por revisores usando LLM, que consumiu capacidade de revisão que normalmente iria para estabilizar o próximo release. O que isso ensina sobre o custo real de QA assistido por IA em projeto open source grande."
---

Toda vez que um release de software atrasa, a primeira suspeita é sempre a mesma: alguma feature grande travou, alguém subestimou a complexidade de algo, o cronograma era otimista demais. Com o PostgreSQL 19 aconteceu outra coisa. O release saiu quase um mês depois da janela que o projeto segue há anos, mas não porque uma feature nova quebrou. Saiu atrasado porque os próprios committers, revisando código com apoio de LLM, passaram a encontrar muito mais bug e falha de segurança do que em qualquer ciclo anterior, e corrigir isso consumiu o tempo que normalmente iria para estabilizar o próximo release.

É um caso raro de atraso que não é sintoma de problema, é sintoma de QA funcionando melhor do que o cronograma esperava. E justamente por isso merece atenção de quem roda Postgres em produção, inclusive quem roda via Azure Databricks Lakebase: a dinâmica que atrasou o release é a mesma que deveria mudar como você avalia o risco de adotar uma versão nova logo que ela sai.

## O cronograma que o PostgreSQL segue há anos

Antes de entender o atraso, vale entender o que é considerado normal. O PostgreSQL lança uma versão maior por ano, num ciclo de 14 a 15 meses, dividido em duas fases bem definidas. A fase de desenvolvimento tem cinco commitfests, em julho, setembro, novembro, janeiro e março ou abril, terminando em feature freeze depois do último. A partir daí começa a fase de estabilização: Beta 1 em maio, corte do branch de release por volta do Beta 2 em junho, Beta 3 em agosto, release candidate em setembro, e disponibilidade geral no fim de setembro ou em outubro.

Esse cronograma tem uma válvula de escape embutida: feature que não estabiliza a tempo é empurrada pro próximo major release, para não comprometer a data de GA. É um mecanismo desenhado para absorver atraso de feature individual sem atrasar o release como um todo.

{{< figure src="release-cycle.png" alt="Diagrama do ciclo de release do PostgreSQL mostrando as fases de desenvolvimento com cinco commitfests seguidas pela fase de estabilização com beta, release candidate e disponibilidade geral, totalizando 14 a 15 meses" caption="O ciclo normal de release do PostgreSQL: cinco commitfests de desenvolvimento, depois estabilização em beta e release candidate até a disponibilidade geral." >}}

## Os números que mudaram em 2026

O que não existia era um mecanismo para absorver um salto geral na quantidade de bug encontrado, e foi exatamente isso que aconteceu a partir de fevereiro de 2026. As releases trimestrais de atualização, que historicamente corrigiam entre 1 e 4 CVEs por ciclo desde agosto de 2023, saltaram para 5 CVEs em fevereiro de 2026, 11 em maio e 28 em agosto. O número de correções de bug por atualização subiu de uma faixa de 50 a 75 para cerca de 140.

O padrão de commit conta a mesma história de outro ângulo. Comparando a mesma janela de abril a setembro em anos consecutivos, os commits para o branch master caíram ligeiramente de 2025 para 2026, mas os commits retroportados (back-patched) para versões anteriores subiram 61%. Olhando especificamente o branch da versão anterior, os commits retroportados para REL_18_STABLE em 2026 (433) ficaram cerca de 75% acima do que foi retroportado para REL_17_STABLE em 2025 (248). A atualização de novembro teve tantas correções que a equipe de release emitiu um segundo release candidate só para absorvê-las.

## Por que achar bug mais rápido significa lançar mais devagar

A explicação que os próprios autores do artigo original, dois committers do projeto, dão para esse padrão não é que os committers ficaram mais descuidados. É que LLM passou a facilitar muito a identificação de bug e brecha de segurança em código já existente, e boa parte dos relatos que chegam de fora do projeto hoje é fruto de alguém usando LLM para encontrar o problema antes de reportar. Mais revisor eficaz encontrando mais problema real é, objetivamente, uma melhoria de qualidade. O efeito colateral é que cada problema encontrado precisa ser corrigido, testado e, frequentemente, retroportado para várias versões ainda em manutenção, e essa capacidade de revisão é finita: toda hora gasta corrigindo bug retroativo é hora que não vai para estabilizar feature nova do próximo ciclo.

**Minha leitura:** o dado mais revelador aqui não é o atraso de um mês, é a proporção entre commit no master e commit retroportado. Um projeto saudável tenta manter a maior parte do esforço em feature nova, com manutenção de versão anterior como fração menor do trabalho. Quando o retroportado cresce 61% enquanto o trabalho no master cai, isso é sinal de que a dívida de qualidade acumulada ao longo dos anos está sendo paga agora, de uma vez, por um motivo específico: ficou mais fácil enxergar essa dívida. Vale perguntar se esse padrão se estabiliza num novo normal ou se é só o primeiro ciclo absorvendo o choque.

## Mão na massa: o que verificar antes de atualizar seu ambiente Lakebase

O PostgreSQL 19 trouxe, entre outras coisas, `REPACK` para reconstruir tabela com bloat sem travar leitura e escrita, estabilização de plano de consulta sem precisar reescrever SQL da aplicação, e `WAIT FOR LSN` para garantir leitura consistente numa réplica sem recorrer a polling. Antes de assumir que vale adotar isso de imediato num ambiente de Lakebase Postgres, um checklist simples de verificação, escrito aqui como exemplo didático e não como script oficial de nenhuma das fontes consultadas, ajuda a decidir com mais segurança:

```sql
-- Checklist exploratório antes de migrar para PostgreSQL 19
-- (ilustrativo, não é script de migração oficial)

-- 1. Confirma a versão em execução
SELECT version();

-- 2. Lista extensões instaladas que podem ter dependência de versão
SELECT extname, extversion FROM pg_extension;

-- 3. Mede o bloat atual das tabelas mais críticas,
--    candidato natural para REPACK depois da migração
SELECT relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS tamanho_total,
       n_dead_tup
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 10;

-- 4. Verifica se algum plano de consulta crítico já está
--    fixado manualmente (hint, pg_hint_plan e afins),
--    candidato a revisar com a nova estabilização de plano
```

A ideia não é que esse script resolva a decisão por você. É que, num release marcado justamente por um esforço de qualidade acima do normal, a melhor forma de aproveitar isso é entrar na migração sabendo exatamente o que vai mudar no seu ambiente, não só confiando que "um release mais revisado é automaticamente um release mais seguro para o seu caso".

## O que isso não resolve

Um ciclo de release mais revisado não elimina a necessidade de teste de regressão próprio. Bug encontrado por LLM e corrigido antes do GA reduz a chance de você ser o primeiro a tropeçar nele em produção, mas não garante que o seu padrão específico de uso, suas extensões, seu volume de dados, não vai expor outro problema que nenhum revisor encontrou ainda. E o salto em back-patch para versões anteriores é, em parte, um sintoma de dívida técnica histórica sendo paga agora. Não há garantia de que o ritmo de correção retroativa volte ao patamar anterior nos próximos ciclos; pode ser que esse seja o novo normal enquanto o projeto termina de destravar essa dívida acumulada.

## Vale a pena já migrar?

Vale planejar a migração, não vale migrar no primeiro dia só porque "o release foi mais revisado". **Na prática:** trate o atraso do PostgreSQL 19 como um sinal positivo sobre o processo, não como uma garantia sobre o resultado. Rode seu próprio teste de carga e de regressão antes de mover produção, principalmente se você depende de comportamento específico de plano de consulta ou de extensão de terceiro. O ganho real dessa história não está na versão 19 em si, está no que ela revela sobre como LLM está mudando a curva de custo entre achar bug rápido e corrigir bug com cuidado, e essa tensão não desaparece só porque um release específico passou por ela.

## Referências

- Databricks Blog, "Why PostgreSQL 19 Shipped Late": https://www.databricks.com/blog/why-postgresql-19-shipped-late
- PostgreSQL Global Development Group, "PostgreSQL 19 Released": https://www.postgresql.org/about/news/postgresql-19-released-3449/
- Databricks Blog, "PostgreSQL 19 is Available on Lakebase": https://www.databricks.com/blog/postgresql-19-available-lakebase

#AzureDatabricks #Lakebase #PostgreSQL #EngenhariaDeSoftware
