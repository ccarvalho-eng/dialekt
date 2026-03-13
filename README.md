```
██████  ██  █████  ██      ███████ ██   ██ ████████
██   ██ ██ ██   ██ ██      ██      ██  ██     ██
██   ██ ██ ███████ ██      █████   █████      ██
██   ██ ██ ██   ██ ██      ██      ██  ██     ██
██████  ██ ██   ██ ███████ ███████ ██   ██    ██
```

[![CI](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/ci.yml?style=flat-square&logo=github-actions)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/codecov/c/github/ccarvalho-eng/dialekt?style=flat-square)](https://codecov.io/gh/ccarvalho-eng/dialekt)
[![Security](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/security.yml?style=flat-square&label=Security)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/security.yml)

```
"So the Lord scattered them over the face of the whole earth." — Genesis 11:8
```

An AI-powered language tutor leveraging adaptive CEFR-aligned pedagogy and real-time conversational synthesis.

<img width="1566" height="764" alt="Untitled" src="https://github.com/user-attachments/assets/edb56322-0315-46a9-8db2-30adb94adf30" />

> **How it works:** Type in either your native language or the target language. The AI tutor always responds in the target language to maintain immersion. When you write in your native language, your message is translated to the target language with phonetics. When you practice in the target language, you receive corrections and guidance. All responses include phonetics and translations to help you understand.

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Input Layer                         │
│                  (Native or Target Language)                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
┌─────────────────────────────────────────────────────────────────┐
│                    Phoenix LiveView Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │  SetupLive   │  │ DashboardLive│  │     ChatLive         │   │
│  │  (Config)    │  │  (Sessions)  │  │  (Conversation)      │   │
│  └──────────────┘  └──────────────┘  └──────────┬───────────┘   │
└─────────────────────────────────────────────────┼───────────────┘
                                                  │
┌─────────────────────────────────────────────────────────────────┐
│                      Business Logic Layer                       │
│  ┌──────────────────────────────┐  ┌────────────────────────┐   │
│  │    Dialekt.Tutor             │  │  Dialekt.Learning      │   │
│  │  • Build CEFR prompts        │  │  • Config schema       │   │
│  │  • Enforce register rules    │  │  • ChatSession schema  │   │
│  │  • Parse AI responses        │  │  • Persistence layer   │   │
│  │  • Generate starters         │  │                        │   │
│  └────────────┬─────────────────┘  └────────────────────────┘   │
└───────────────┼─────────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     HTTP Client Layer (ReqLLM)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │  Anthropic   │  │   OpenAI     │  │    OpenRouter        │   │
│  │  Claude 3.5  │  │  GPT-4/4o    │  │  (Multiple models)   │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Structured Response Format                     │
│  • You: [phrase + IPA + transliteration]                        │
│  • Note: [corrections in native language]                       │
│  • Tutor: [response in target + translation]                    │
│  • Follow-up: [question to continue]                            │
│  • Tips: [learning insights]                                    │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PostgreSQL Database                        │
│  • User configurations (languages, CEFR level, register)        │
│  • Chat sessions and message history                            │
└─────────────────────────────────────────────────────────────────┘
```

## Features

- **Adaptive Conversations** - Vocabulary and grammar adjust to your CEFR level (A1-C2)
- **Multi-Language Support** - English, Spanish, French, German, Mandarin, Japanese, Portuguese, Arabic, Russian, Hindi
- **Multiple LLM Providers** - Choose between Anthropic, OpenAI, or OpenRouter
- **Contextual Feedback** - Real-time corrections, translations, IPA phonetics
- **Text-to-Speech** - Native pronunciation synthesis
- **Session Management** - Save and resume configurations

## Quick Start

```bash
# Start PostgreSQL
docker compose -f dockercompose.yml up -d

# Install dependencies (versions in .tool-versions)
asdf install && mix deps.get

# Configure environment
cp .env.example .env  # Add API key for your chosen provider (Anthropic/OpenAI/OpenRouter)

# Setup and run
mix ecto.setup && mix phx.server
```

Visit [localhost:4000](http://localhost:4000)


