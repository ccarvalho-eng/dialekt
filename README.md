# Dialekt

[![CI](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/ci.yml?style=flat-square&logo=github-actions)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/codecov/c/github/ccarvalho-eng/dialekt?style=flat-square)](https://codecov.io/gh/ccarvalho-eng/dialekt)
[![Security](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/security.yml?style=flat-square&label=Security)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/security.yml)

AI-powered language tutor built with Phoenix LiveView that adapts to your CEFR proficiency level (A1-C2) and provides real-time conversational practice with Claude AI.

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

**Production:** Use the included `Dockerfile` for deployment. See `.env.example` for required environment variables.

## Usage

1. Select native language, target language, CEFR level (A1-C2), and register (formal/informal)
2. Chat using AI-generated starters or your own messages
3. Receive real-time corrections, translations, and pronunciation help
4. Manage multiple learning configurations from the dashboard

## Development

```bash
mix test               # Run tests
mix format             # Format code
mix credo              # Code quality
mix dialyzer           # Type checking
mix sobelow            # Security scan
mix coveralls.html     # Coverage report
```

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
