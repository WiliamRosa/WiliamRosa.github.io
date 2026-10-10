---
title: "O gargalo da IA em imagem médica não é o modelo, é conseguir ler o arquivo DICOM rápido o suficiente"
date: 2026-10-09T09:00:00-03:00
draft: false
tags: ["Azure Databricks", "Saúde", "Engenharia de Dados", "DICOM"]
summary: "Antes de qualquer modelo de segmentação ou classificação entrar em cena, times de imagem médica esbarram num problema mais chato: biblioteca de parsing DICOM é de thread única, e des-identificar PHI em cabeçalho e pixel em escala exige um pipeline próprio, não só mais GPU."
ShowToc: true
---

É tentador assumir que o maior obstáculo pra usar IA em imagem médica é a qualidade do modelo de segmentação ou classificação. Na prática, quem já tentou rodar isso em escala de hospital esbarra num problema bem menos glamouroso primeiro: como ler centena de milhar de arquivo DICOM, cada um às vezes com metadado espalhado em formato próprio, rápido o suficiente pra alimentar qualquer modelo depois, sem travar numa biblioteca de parsing que só sabe processar um arquivo de cada vez.

## Por que DICOM resiste a paralelismo ingênuo

A maioria das bibliotecas de parsing DICOM foi escrita assumindo uso de thread única, processar um arquivo por vez, sequencialmente. Isso não é um detalhe de implementação irrelevante, é o motivo direto pelo qual simplesmente jogar mais núcleo de CPU no problema não ajuda sozinho, o gargalo não é falta de paralelismo disponível no cluster, é a própria biblioteca não saber se beneficiar dele. A saída prática é inverter quem distribui o trabalho: em vez de esperar a biblioteca paralelizar internamente, o motor de processamento distribuído assume essa responsabilidade por fora, despachando arquivo por arquivo (ou lote de arquivo) pra executor diferente.

## O padrão medallion aplicado a imagem, não só a tabela

A arquitetura em camadas que já é familiar pra dado tabular se aplica aqui com um ajuste de ordem importante. Estudo bruto entra primeiro num armazenamento restrito, onde a des-identificação roda antes de qualquer outra etapa, não depois. Só então os valores de texto dos tags DICOM são extraídos pra tabela Delta, e coorte curada acaba sendo o resultado de unir esse metadado com dado clínico e, quando existe, dado ômico. A inversão que importa, des-identificar antes de extrair metadado, existe porque tag de texto dentro de um DICOM pode carregar informação de paciente, então adiar a des-identificação pra depois da extração já teria vazado dado sensível pra fora do armazenamento restrito.

## Mão na massa: distribuindo o parsing com pandas UDF

O padrão prático pra contornar a limitação de thread única de uma biblioteca de parsing é embrulhar a chamada da biblioteca dentro de uma função que o Spark consegue distribuir, tipicamente via `mapInPandas`, deixando o Spark cuidar da distribuição entre executor enquanto a biblioteca de parsing continua enxergando um arquivo de cada vez do seu próprio ponto de vista:

```python
import pandas as pd
from pyspark.sql.types import StructType, StructField, StringType

schema_saida = StructType([
    StructField("caminho_arquivo", StringType()),
    StructField("patient_id_pseudonimo", StringType()),
    StructField("modality", StringType()),
    StructField("study_description", StringType()),
])

def extrair_tags_dicom(iterador_lotes):
    import pydicom

    for lote in iterador_lotes:
        registros = []
        for caminho in lote["caminho_arquivo"]:
            ds = pydicom.dcmread(caminho, stop_before_pixels=True)
            registros.append({
                "caminho_arquivo": caminho,
                "patient_id_pseudonimo": pseudonimizar(ds.PatientID),
                "modality": str(ds.get("Modality", "")),
                "study_description": str(ds.get("StudyDescription", "")),
            })
        yield pd.DataFrame(registros, columns=[campo.name for campo in schema_saida])

df_arquivos = spark.read.table("saude.bronze.inventario_dicom_restrito")
df_tags = df_arquivos.mapInPandas(extrair_tags_dicom, schema=schema_saida)
df_tags.write.mode("append").saveAsTable("saude.silver.tags_dicom_pseudonimizado")
```

O ponto central desse código não é a chamada a `pydicom` em si, qualquer biblioteca de parsing serviria no lugar, é o `mapInPandas` reduzir a unidade de paralelismo pro nível de lote de arquivo, deixando a distribuição entre máquina ser responsabilidade do motor, não da biblioteca.

## De-identificação em duas camadas, cabeçalho e pixel

Des-identificar um estudo de imagem médica exige tratar duas superfícies de exposição de PHI separadamente, e tratar só uma deixa a outra aberta. No cabeçalho, uma técnica de criptografia que preserva formato garante que o mesmo identificador de paciente sempre vire o mesmo pseudônimo, o que importa pra manter a possibilidade de ligação entre datasets diferentes sem expor o identificador original. No pixel da própria imagem, existe uma categoria de exposição menos óbvia, texto queimado direto na imagem durante a aquisição, nome de paciente aparecendo como pixel visível num scan, não como metadado de texto. Resolver isso exige uma camada separada de reconhecimento óptico combinado com modelo de linguagem visual, rodando de forma distribuída pelo mesmo motivo que o parsing de metadado precisa rodar distribuído, o volume de imagem inviabiliza processamento sequencial.

## O que isso não resolve sozinho

Boa parte dos números de performance e precisão citados em material técnico desse tipo vem de benchmark do próprio fornecedor, então vale reproduzir contra uma amostra real do seu próprio acervo antes de assumir que o mesmo ganho se repete, características de aquisição, fabricante de equipamento e protocolo clínico variam bastante entre instituição. Boa parte do material disponível publicamente também não detalha configuração completa nem dataset usado além do que está no acelerador de código aberto, então o caminho mais confiável de replicação ainda é partir do próprio código aberto e adaptar, não tentar reconstruir a arquitetura inteira só a partir da descrição em alto nível. E o framing mais ambicioso desse tipo de iniciativa, agente de IA como "co-cientista" analisando imagem médica de forma autônoma, continua sendo aspiracional, não uma peça de arquitetura com implementação detalhada disponível hoje.

**Minha leitura:** o que mais vale reter aqui não é a tecnologia de modelo em si, MONAI, segmentação, classificação, é a ordem das etapas. Times que tentam aplicar IA em imagem médica direto, deixando ingestão e des-identificação pra depois "porque isso é só engenharia", normalmente descobrem tarde demais que o verdadeiro gargalo de escala estava ali, numa biblioteca de parsing de thread única processando um arquivo de cada vez, não no modelo que ia rodar depois.

## Vale a pena investir nisso?

Pra qualquer time de saúde ou pesquisa clínica que já sente o acervo de imagem crescer mais rápido do que a capacidade de processar, o ganho real de investir em ingestão distribuída e des-identificação em duas camadas antes de qualquer modelagem é evitar descobrir o gargalo depois que o projeto já prometeu prazo baseado só na parte de modelo. O acelerador de código aberto é um ponto de partida razoável pra testar o padrão contra uma amostra pequena do próprio acervo antes de comprometer arquitetura em escala total.

## Referências

- Databricks Blog, "Biomedical Imaging's Real Bottleneck Is the Data, Not the Model": https://www.databricks.com/blog/biomedical-imagings-real-bottleneck-data-not-model
- Acelerador de código aberto Pixels (Databricks Industry Solutions): https://github.com/databricks-industry-solutions/pixels
- Databricks Blog, ingestão de DICOM mais rápida via Python Data Source API: https://www.databricks.com/blog/7x-faster-medical-image-ingestion-python-data-source-api
- Databricks Blog, de-identificação de imagem médica com modelo de linguagem visual: https://www.databricks.com/blog/de-identifying-medical-images-cost-effectively-vision-language-models-databricks

#AzureDatabricks #Saude #EngenhariaDeDados #DICOM
