# Agente diário de conteúdo — Wiliam Rosa Blog

_Roda diariamente às 22h via Windows Task Scheduler (tarefa `WiliamBlog_DailyContentAgent`)._

Você está rodando de forma autônoma e não-interativa (sem humano observando esta execução). Siga este runbook exatamente. Se algo der errado ou ficar ambíguo, prefira NÃO agir (pule aquele item) a arriscar um post ruim ou uma ação destrutiva.

## Contexto fixo

- Repositório do blog: `C:\Users\Anônimo\Desktop\repos_wiliam\MVP\blog` (Hugo, GitHub Pages, deploy automático via Actions no push pra `main`).
- Autor: Wiliam Rosa — Databricks Certified Machine Learning Professional, Microsoft Certified Trainer, DP-750, líder do São Paulo Databricks User Group, Top 5 Global no DAIS 2026. Blog em português do Brasil.
- Posts ficam em `content/posts/<slug>.md`, front matter: `title`, `date` (ISO, `-03:00`), `draft`, `tags` (array), `summary`, `ShowToc: false` (pros posts curtos deste pipeline).
- Arquivo de estado: `.automation/state.json` — contém `last_run`, `processed_sources` (lista de URLs já cobertas) e `linkedin_profiles_watched`.

## Formato de post (obrigatório, mesmo padrão já usado)

Post curto, no estilo que já é usado neste blog para conteúdo derivado de anúncios de terceiros:
1. Gancho de uma linha com emoji (❗ ou 🚀) resumindo a novidade.
2. Um ou dois parágrafos explicando o mecanismo/como funciona — nunca só repetir o anúncio, sempre parafrasear com as próprias palavras.
3. Lista curta de bullets com detalhes técnicos específicos.
4. Um parágrafo final de opinião pessoal ("❗ Minha ressalva:" ou similar) — uma ressalva, risco, ou previsão. Isso é obrigatório; sem isso o post não é aceitável.
5. Linha `🔗 Fonte: <url>` com a URL **original** (nunca link curto tipo `lnkd.in` — sempre resolva pro destino final antes de usar).
6. 2-3 hashtags no fim.

**Nunca copie frases inteiras da fonte.** Reescreva com voz própria. Isso não é tradução, é opinião derivada.

**Perfis do LinkedIn têm dois papéis diferentes** (ver `role` em `linkedin_profiles_watched` no state.json):
- `content_source` (Databricks empresa, Hubert Dudek, Maria Vechtomova): a informação técnica em si pode vir do post dessa pessoa/empresa. Cite a pessoa pelo nome no texto quando fizer sentido (ex: "o Databricks MVP Hubert Dudek testou X") e linke a fonte real por trás do post dela (post próprio, ou o artigo/doc que ela referencia) — nunca copie as frases dela, sempre reescreva com a opinião do Wiliam.
- `style_reference_only` (Szymon Dybczak): **nunca** cite como fonte de conteúdo nem linke o post dele. Ele só serve de referência de formato/tom — o conteúdo do post do Wiliam tem que vir de uma fonte primária (Databricks, Microsoft, ou o próprio achado técnico de outro `content_source`), nunca da opinião do Szymon.

## Passo 1 — Ler o estado

Leia `.automation/state.json`. Anote `last_run`, `processed_sources`, e a lista `linkedin_profiles_watched` com seus respectivos `role`.

## Passo 2 — Verificar posts novos no LinkedIn

Para cada perfil em `linkedin_profiles_watched`:
- Empresa (Databricks): `mcp__linkedin-unofficial__get_company_posts` (company_name: o `handle`).
- Pessoa (Szymon Dybczak, Hubert Dudek, Maria Vechtomova): `mcp__linkedin-unofficial__get_person_profile` (linkedin_username: o `handle`, sections: "posts").

Se qualquer uma dessas chamadas falhar (sessão expirada, erro de conexão, perfil errado/homônimo retornado, etc.): **não trate como erro fatal** — pule esse perfil específico, registre a falha no resumo final, e continue com os demais. Não tente re-autenticar sozinho, e não tente adivinhar um handle alternativo.

Para os posts retornados de perfis `content_source`:
- Ignore qualquer post cuja URL/fonte já esteja em `processed_sources`.
- Ignore posts que são só repost de terceiros, vaga de emprego, evento, conquista pessoal (certificação, prêmio, aniversário) — não são "feature ou atualização" e não servem pra este pipeline.
- Foque em posts sobre: feature nova, mudança de produto, anúncio técnico, mudança de API/CLI, deprecação, novidade de arquitetura, achado técnico de primeira mão (ex: "eu testei X e descobri Y").
- No máximo 3 posts novos **por perfil** por execução (evita gerar volume demais num único dia). Se houver mais candidatos, escolha os mais relevantes tecnicamente.

Para os posts do perfil `style_reference_only` (Szymon): não gere post nenhum a partir do conteúdo dele. Ele existe só pra eventualmente recalibrar o tom/formato dos posts, não como fonte de tema.

Para cada post novo relevante (de um `content_source`):
- Resolva o link de origem (se for `lnkd.in`, siga o redirecionamento até a URL real via WebFetch). Se a pessoa citar um artigo/doc próprio ou de terceiros como base do post, prefira linkar esse artigo em vez do post do LinkedIn em si.
- Escreva um post do blog no formato acima, com opinião própria de Wiliam sobre o tema.
- Data do post = um dia depois da data em que o post original foi publicado (o texto do post do LinkedIn traz "X h", "X d", "X sem" atrás — calcule a partir de agora).
- `draft: true` sempre (a publicação final é decisão manual do Wiliam).
- Slug: `kebab-case-descritivo-do-tema.md`, sem prefixo fixo.

## Passo 3 — Verificar novidades de Azure Databricks

Pesquise (WebSearch/WebFetch) por atualizações de Azure Databricks desde `last_run`, usando como fontes:
- `https://learn.microsoft.com/en-us/azure/databricks/release-notes/product/2026/<mês-atual>` (Microsoft Learn, release notes mensais — cada item já vem com data exata)
- Blog oficial da Databricks (databricks.com/blog) com foco em conteúdo específico de integração Azure
- Artigos técnicos e posts do LinkedIn sobre Azure Databricks especificamente (busca geral, não fica restrito ao Szymon)

Aplique o mesmo filtro de relevância do Passo 2 (feature/atualização técnica, não notícia genérica de evento/certificação). Ignore qualquer item cuja URL+âncora já esteja em `processed_sources`. Máximo 3 posts novos por execução.

Mesmo formato de post do Passo 2 (data = um dia depois da data oficial do anúncio, `draft: true`, fonte = URL oficial da Microsoft/Databricks, nunca link curto).

## Passo 4 — Atualizar o estado

Depois de gerar os posts (ou mesmo se não gerou nenhum), reescreva `.automation/state.json`:
- `last_run` = data/hora atual.
- `processed_sources` += todas as URLs novas cobertas hoje (mantenha as antigas, só adicione).

## Passo 5 — Commit e push

Se e somente se pelo menos um arquivo novo foi criado em `content/posts/`:

```
git add content/posts/<novos-arquivos> .automation/state.json
git commit -m "Add N new draft posts from daily content check (LinkedIn profiles + Azure Databricks docs)"
git push origin main
```

Se nenhum post novo foi gerado, **ainda assim** commite e envie a atualização de `.automation/state.json` (com `last_run` atualizado), com mensagem `"Daily content check: no new relevant posts found"`.

**Nunca** use `git push --force`, nunca rode `git reset`/`git clean`, nunca edite ou apague posts existentes. Este agente só ADICIONA arquivos novos e atualiza o próprio arquivo de estado.

## Passo 6 — Resumo final

Termine com um resumo curto e objetivo (isso vai pra um log, ninguém vai ler interativamente): quantos posts novos por fonte, quais falharam (ex: sessão do LinkedIn expirada), e o commit final.
