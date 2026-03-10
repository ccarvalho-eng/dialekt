# Dialekt

[![CI](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/ci.yml?style=flat-square&logo=github-actions)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/codecov/c/github/ccarvalho-eng/dialekt?style=flat-square)](https://codecov.io/gh/ccarvalho-eng/dialekt)
[![Security](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/security.yml?style=flat-square&label=Security)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/security.yml)

AI-powered language tutor built with Phoenix LiveView that adapts to your CEFR proficiency level (A1-C2) and provides real-time conversational practice with Claude AI.

## Features

- **Adaptive Conversations** - Vocabulary and grammar automatically adjust to your CEFR level
- **Multi-Language Support** - 10+ languages including English, Spanish, French, German, Mandarin, Japanese, Portuguese, Arabic, Russian, Hindi
- **Contextual Feedback** - Real-time corrections, translations, and IPA phonetics
- **Text-to-Speech** - Native pronunciation with voice synthesis
- **Session Management** - Save and resume learning configurations
- **Register Awareness** - Practice formal or informal conversation styles

## Tech Stack

- Elixir 1.17 • Phoenix 1.8 • LiveView 1.1
- PostgreSQL 17 • Anthropic Claude API
- TailwindCSS • Bandit HTTP Server

## Quick Start

**Prerequisites:** Elixir 1.17+, Erlang/OTP 27+, PostgreSQL 17, Anthropic API key

### Local Development

```bash
# Start PostgreSQL (Docker Compose)
docker compose -f dockercompose.yml up -d

# Install dependencies
asdf install  # or ensure versions match .tool-versions
mix deps.get

# Configure environment
cp .env.example .env
# Add your ANTHROPIC_API_KEY to .env

# Setup database and start server
mix ecto.setup
mix phx.server
```

Visit [localhost:4000](http://localhost:4000)

### Production Deployment

```bash
docker build -t dialekt .
docker run -p 4000:4000 \
  -e SECRET_KEY_BASE=your-secret-key \
  -e DATABASE_URL=ecto://user:pass@host/dialekt_prod \
  -e ANTHROPIC_API_KEY=your-key \
  dialekt
```

## Usage

1. Select native language, target language, CEFR level (A1-C2), and register (formal/informal)
2. Chat using AI-generated starters or your own messages
3. Receive real-time corrections, translations, and pronunciation help
4. Manage multiple learning configurations from the dashboard

## Development

### Commands

```bash
mix setup              # Install deps and setup
mix test               # Run tests (80 test cases)
mix format             # Format code
mix credo              # Code quality checks
mix dialyzer           # Static analysis
mix sobelow            # Security scanning
mix deps.audit         # Dependency vulnerabilities
mix coveralls.html     # Coverage report (target: 75%)
```

### Code Quality

- **CI/CD** - GitHub Actions for tests, linting, security scans
- **Coverage** - 75% target with ExCoveralls
- **Security** - Sobelow, CodeQL, Trivy, TruffleHog, npm audit
- **Analysis** - Credo (style), Dialyzer (types), mix_audit (deps)
- **Dependencies** - Automated updates via Dependabot

### Environment Variables

Required variables (see `.env.example`):

```bash
ANTHROPIC_API_KEY      # Claude AI API key (required)
DATABASE_URL           # PostgreSQL connection
SECRET_KEY_BASE        # Phoenix secret (generate with: mix phx.gen.secret)
PHX_HOST               # Application hostname
PORT                   # Server port (default: 4000)
```

## Architecture

- **Backend** - Elixir 1.17.3, Phoenix 1.8, LiveView 1.1 for real-time UI
- **Database** - PostgreSQL 17 with Ecto 3.13
- **AI Integration** - Anthropic Claude API via Req HTTP client
- **Deployment** - Docker multi-stage builds, Debian Bookworm, non-root execution
- **Server** - Bandit 1.5 (HTTP/1.1 and HTTP/2)

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.
