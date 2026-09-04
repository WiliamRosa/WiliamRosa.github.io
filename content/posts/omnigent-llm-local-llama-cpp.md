---
title: "Rodei o Omnigent com um LLM local no Mac, e a configuração levou menos de 30 minutos"
date: 2026-09-04T09:00:00-03:00
draft: true
tags: ["Databricks", "Omnigent", "Agentes de IA", "LLM Local", "Opinião"]
summary: "Configurar o Omnigent para rodar com um modelo quantizado local via llama.cpp é mais simples do que parece, e ainda revela que o Ollama, apesar de mais popular, é mais lento e mais trabalhoso de configurar pro mesmo modelo."
ShowToc: false
---

Rodar um coding agent inteiro sem gastar um único token de API soa bem no papel, mas a pergunta de sempre é quanto trabalho de configuração isso realmente exige.

A Databricks MVP Zoë Van Noppen testou na prática configurar o Omnigent, o meta-harness open-source da Databricks para orquestrar agentes de código, com um modelo de linguagem local rodando no próprio Mac, em vez de depender de API paga. O objetivo dela não era substituir modelo via API no dia a dia, mas entender se um modelo pequeno e quantizado rodando localmente consegue assumir tarefas simples que hoje são roteadas para modelo pago sem necessidade.

A configuração passa por instalar o `llama.cpp` via Homebrew e subir um servidor local com um modelo Gemma quantizado baixado direto do Hugging Face, depois instalar o harness Pi via npm junto com o plugin que conecta Pi ao llama.cpp. A parte final acontece dentro do próprio Omnigent, pelo comando `Omni setup`: escolher Pi como harness, configurar um gateway do tipo "URL base customizada + chave", apontar a URL base para o servidor local do llama.cpp, preencher uma chave de API qualquer (o campo exige algo, mas não valida nada localmente) e informar o nome do modelo local ao configurar o harness Claude via Responses API. Ela também tentou o mesmo processo com Ollama em vez de llama.cpp e achou mais trabalhoso: precisou depurar configuração de janela de contexto e URL base, e o mesmo modelo rodou mais devagar no Ollama do que no llama.cpp, algo que segundo ela é um problema já conhecido da comunidade.

Pontos técnicos que valem registrar:
- Instalação via `brew install llama.cpp`, subindo o servidor com `llama-server -hf <modelo-quantizado-no-Hugging-Face>`
- Harness Pi instalado via `npm install -g` mais o plugin `pi-llama-cpp`
- No `Omni setup`, o gateway customizado usa a URL do servidor `llama-server` local, uma chave de API qualquer (não validada) e o harness Claude via Responses API apontando pro nome do modelo local
- Ollama exigiu depuração extra de contexto e URL base, e rodou o mesmo modelo mais devagar que o llama.cpp

**Minhas considerações:** esse tipo de post prático, com comando exato e passo a passo real, vale mais do que dez posts de opinião sobre modelo local, porque tira a dúvida de "dá pra fazer isso hoje" da teoria. A ideia de rotear tarefa simples para modelo local e reservar o modelo pago só pro que exige mais raciocínio é um padrão de economia que ainda vejo pouco discutido no ecossistema Databricks, e acho que vamos ver mais gente adotando isso à medida que modelo quantizado pequeno continuar melhorando.

**Fonte:** https://www.linkedin.com/in/zo%C3%AB-van-noppen-7378b6139/#omnigent-llm-local-llama-cpp

#Databricks #Omnigent #AgentesIA
