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

<img width="1425" height="764" alt="Untitled" src="https://github.com/user-attachments/assets/2c62c285-eec9-42a8-aee3-c364bc0e60e9" />

> **How it works:** Type in either your native language or the target language. The AI tutor always responds in the target language to maintain immersion. When you write in your native language, your message is translated to the target language with phonetics. When you practice in the target language, you receive corrections and guidance. All responses include phonetics and translations to help you understand.

## Features

- **Adaptive Conversations** - Vocabulary and grammar adjust to your CEFR level (A1-C2)
- **Multi-Language Support** - English, Spanish, French, German, Mandarin, Japanese, Portuguese, Arabic, Russian, Hindi
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
cp .env.example .env  # Add your ANTHROPIC_API_KEY

# Setup and run
mix ecto.setup && mix phx.server
```

Visit [localhost:4000](http://localhost:4000)


