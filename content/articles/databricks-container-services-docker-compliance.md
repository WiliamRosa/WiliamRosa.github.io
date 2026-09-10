---
title: "Runtime engessado ou imagem Docker própria: o dilema de compliance que o Databricks Container Services resolve"
date: 2026-06-26T09:00:00-03:00
draft: false
tags: ["Databricks", "Docker", "CI/CD", "Compliance", "DevOps"]
summary: "Databricks Container Services deixa trocar o runtime gerenciado por uma imagem Docker própria, construída e escaneada no seu próprio pipeline de CI/CD. Resolve certificado corporativo, biblioteca proibida e ambiente travado, mas exige abrir mão de parte do conforto de um cluster totalmente gerenciado."
ShowToc: true
---

Toda empresa que já passou por auditoria de segurança conhece a pergunta incômoda: "esse ambiente de processamento de dado, quem garante que ele não muda de uma execução pra outra, e quem garante que o certificado interno da empresa está instalado nele?" Num cluster Databricks padrão, a resposta tende a ser vaga, porque o runtime é gerenciado pela Databricks e atualizado com o tempo. Pra times que rodam workload em ambiente regulado, banco, saúde, setor público, isso é exatamente o tipo de resposta que não passa numa auditoria.

O Databricks MVP Hubert Dudek publicou um artigo detalhando como o Databricks Container Services muda essa conversa: em vez de aceitar o runtime padrão como caixa preta, dá pra construir a própria imagem Docker, versionar ela junto do código, escanear ela no mesmo pipeline de CI/CD que já existe pra aplicação, e usar exatamente essa imagem, travada, em produção. A ideia de "ambiente dourado" (golden image) que nunca muda sozinho deixa de ser promessa e vira configuração literal de cluster.

## O mecanismo: Databricks entrega o Spark, você entrega o resto

Container Services deixa especificar uma imagem Docker na hora de criar o compute, mas antes disso um workspace admin precisa habilitar o recurso explicitamente pra conta inteira, via CLI (`databricks workspace-conf set-status --json '{"enableDcs": "true"}'`), não vem ligado por padrão. A Databricks recomenda partir de uma base já testada por ela, publicada em `databricksruntime/standard`, `databricksruntime/minimal` ou `databricksruntime/python` no Docker Hub, com Dockerfiles públicos no GitHub em `databricks/containers` (imagem com sufixo `-LTS` recebe patch regular, as demais são só exemplo). É possível também construir a imagem do zero, mas nesse caso o Dockerfile precisa entregar JDK (na versão compatível com o Runtime alvo), bash, iproute2, coreutils, procps, sudo e acl, sobre Ubuntu (Alpine é suportado com pacote extra de coreutils/procps/sudo e setup manual de Python). Na inicialização do compute, a Databricks baixa a imagem do seu registry, cria o container, copia o código do Databricks Runtime pra dentro dele e só então roda os init scripts, sempre ignorando qualquer `CMD` ou `ENTRYPOINT` que a imagem declare. Dá pra pensar assim: o "motor" (agendamento de job, integração com Unity Catalog, runtime Spark) continua sendo responsabilidade da Databricks, e o "chassi" (biblioteca de sistema, certificado, binário nativo) passa a ser seu.

Vale registrar que esse fluxo descrito aqui é especificamente o Container Services pra compute de acesso dedicado; existe uma variante em Beta separada pra compute em modo de acesso standard, com página própria na documentação, que não é o foco deste artigo.

## Mão na massa: base própria, publicada e usada num cluster

Um Dockerfile mínimo que parte da base oficial, adiciona uma biblioteca Python e um certificado corporativo:

```dockerfile
FROM databricksruntime/standard:16.4-LTS

# biblioteca extra usando o pip específico da imagem
RUN /databricks/python3/bin/pip install pandas==2.2.2

# certificado interno da empresa, exigência recorrente de compliance
COPY corp-ca.crt /usr/local/share/ca-certificates/corp-ca.crt
RUN update-ca-certificates
```

Depois de publicar essa imagem num registry (Docker Hub ou Azure Container Registry, com autenticação básica), o cluster é criado apontando pra ela via API ou UI:

```bash
databricks clusters create \
  --cluster-name etl-compliance \
  --node-type-id Standard_DS3_v2 \
  --json '{
    "num_workers": 2,
    "docker_image": {
      "url": "meuregistro.azurecr.io/etl-runtime:2026-06-25",
      "basic_auth": {
        "username": "{{secrets/docker/registry-user}}",
        "password": "{{secrets/docker/registry-pass}}"
      }
    },
    "spark_version": "16.4.x-scala2.12"
  }'
```

Note a tag da imagem carregando a data do build: numa auditoria, "qual exatamente é o ambiente que rodou esse job em produção no dia X" vira uma resposta objetiva, não uma suposição sobre o estado do runtime gerenciado naquela data.

## Onde entra o CI/CD de verdade

O ganho maior não é o Dockerfile em si, é encaixar a construção da imagem no mesmo pipeline que já faz build e teste de código de aplicação: build da imagem, scan de vulnerabilidade (Trivy, Grype, ou o scanner que a empresa já usa), push pro registry privado só se o scan passar, e só então liberação da tag nova pro cluster de produção. Isso transforma "qual biblioteca está instalada nesse cluster" de pergunta que só o time de plataforma sabe responder em artefato versionado no Git, com histórico e review, igual qualquer outro deploy.

**Na prática:** o argumento de compliance é o que mais aparece nesse tipo de decisão, mas o efeito colateral que mais economiza tempo de time no dia a dia é outro, biblioteca nativa e binário que hoje viram init script frágil e demorado passam a fazer parte da imagem, e o cluster sobe mais rápido porque não precisa reinstalar nada toda vez.

## Imagem própria ou init script: como escolher

Nem toda customização justifica sair construindo Dockerfile. A própria documentação da Databricks separa os dois casos com um critério simples: o que precisa acontecer na construção do ambiente (biblioteca de sistema, certificado, binário nativo, JDK específico) pertence à imagem; o que precisa acontecer toda vez que o compute liga (subir um daemon de segurança, registrar o node num serviço externo, configuração que depende de variável só disponível em runtime) pertence ao init script, mesmo rodando dentro de um container customizado. Misturar as duas coisas, colocando no init script o que devia estar no Dockerfile, é o motivo mais comum de cluster que demora minutos a mais pra subir sem necessidade nenhuma: toda inicialização reinstala pacote que já podia estar cozido na imagem desde o build.

Isso importa porque a decisão de adotar Container Services não é tudo ou nada. Dá pra manter o runtime gerenciado padrão pra maioria dos clusters e reservar a imagem própria só pros workloads que realmente carregam exigência de compliance ou dependência nativa incomum, o que limita a superfície de manutenção justamente ao ponto onde o ganho compensa o custo de manter imagem atualizada.

## O que isso não resolve

Container Services não é gratuito em manutenção. A imagem passa a ser responsabilidade de quem construiu, incluindo atualização de patch de segurança do sistema operacional base, uma tarefa que o runtime gerenciado normalmente absorve sozinho. Databricks Runtime for Machine Learning não é suportado nesse modelo, então workload de ML que depende dele precisa ficar fora dessa estratégia ou replicar manualmente o que aquele runtime já entrega pronto. Acesso a Volumes do Unity Catalog exige ligar `spark.databricks.unityCatalog.volumes.enabled=true` na configuração Spark do compute, e Hive metastore federado exige `spark.databricks.unityCatalog.hms.federation.enabled=true`, nenhum dos dois vem habilitado por padrão. Autenticação via notebook não é suportada nesse modelo. Vale ainda evitar montar recurso na faixa `172.17.0.0/16`, que é a rede padrão do próprio Docker e pode gerar conflito de IP difícil de diagnosticar. E a documentação é direta numa ressalva que vale levar a sério: um container que funciona local ou na máquina de build pode falhar, ter feature desabilitada, ou parar de funcionar silenciosamente quando sobe num compute Databricks real, no pior caso corrompendo dado ou expondo dado a terceiro, então "testei localmente" não é suficiente, o teste em compute real de não produção é obrigatório antes de qualquer promoção pra produção.

## Vale a pena adotar?

Faz sentido pra quem já tem exigência de compliance documentada (certificado corporativo obrigatório, biblioteca proibida por política interna, ambiente que precisa ser auditável e reprodutível) ou pra quem já mantém pipeline de CI/CD maduro e quer eliminar init script frágil. Não faz sentido trocar o conforto do runtime gerenciado por Docker só porque parece mais "engenheiro de plataforma": cada imagem própria é mais um artefato pra manter atualizado e mais uma superfície de erro no lançamento do cluster.

## Referências

- Microsoft Learn, "Databricks Container Services for dedicated compute": https://learn.microsoft.com/en-us/azure/databricks/compute/custom-containers
- Databricks base images e Dockerfiles: https://github.com/databricks/containers

#Databricks #Docker #CICD #Compliance
