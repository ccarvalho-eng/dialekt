```
██████╗ ██╗ █████╗ ██╗     ███████╗██╗  ██╗████████╗
██╔══██╗██║██╔══██╗██║     ██╔════╝██║ ██╔╝╚══██╔══╝
██║  ██║██║███████║██║     █████╗  █████╔╝    ██║   
██║  ██║██║██╔══██║██║     ██╔══╝  ██╔═██╗    ██║   
██████╔╝██║██║  ██║███████╗███████╗██║  ██╗   ██║   
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝                                                   
```

[![CI](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/ci.yml?style=flat-square&logo=github-actions)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/codecov/c/github/ccarvalho-eng/dialekt?style=flat-square)](https://codecov.io/gh/ccarvalho-eng/dialekt)
[![Security](https://img.shields.io/github/actions/workflow/status/ccarvalho-eng/dialekt/security.yml?style=flat-square&label=Security)](https://github.com/ccarvalho-eng/dialekt/actions/workflows/security.yml)

```
"So the Lord scattered them over the face of the whole earth." — Genesis 11:8
```

An AI-powered language tutor leveraging adaptive CEFR-aligned pedagogy and real-time conversational synthesis.

<img width="1572" height="764" alt="Untitled" src="https://github.com/user-attachments/assets/4ff89ade-a70b-4995-b028-9abf1337674c" />

> **How it works:** Type in either your native language or the target language. The AI tutor always responds in the target language to maintain immersion. When you write in your native language, your message is translated to the target language with phonetics. When you practice in the target language, you receive corrections and guidance. All responses include phonetics and translations to help you understand.

## Features

- **Adaptive Conversations** - Vocabulary and grammar adjust to your CEFR level (A1-C2)
- **Multi-Language Support** - 70+ languages including English, Spanish, French, German, Mandarin, Japanese, Portuguese, Arabic, Russian, Hindi
- **Multiple LLM Providers** - Choose between Anthropic, OpenAI, or OpenRouter
- **Contextual Feedback** - Real-time corrections, translations, IPA phonetics, and transliterations
- **Romanized Input** - Practice languages with non-Latin scripts before you are comfortable typing the native script
- **Mistake Review** - Corrections are saved automatically and can be marked learned or restored for more practice
- **Text-to-Speech** - Native pronunciation synthesis for all supported languages
- **Voice Input** - Browser-based speech-to-text with support for both native and target languages
- **Session Management** - Save and resume conversations for each learning configuration

## Prerequisites

- Git
- Docker with Docker Compose, for PostgreSQL
- Erlang/OTP, Elixir, and Node.js. The tested versions are listed in [`.tool-versions`](.tool-versions); `asdf` can install them for you.
- An API key for Anthropic, OpenAI, or OpenRouter

## Install and Run

```bash
# Clone and enter the project
git clone https://github.com/ccarvalho-eng/dialekt.git
cd dialekt

# Install the versions from .tool-versions when using asdf
asdf install

# Configure your provider and API key
cp .env.example .env

# Start PostgreSQL, install dependencies, create the database, and build assets
docker compose -f dockercompose.yml up -d
mix setup

# Start Dialekt
mix phx.server
```

Open [http://localhost:4000](http://localhost:4000).

### Configure the AI provider

Edit `.env` and set `AI_PROVIDER`, `AI_MODEL`, and the matching API key. You only need a key for the provider you use.

```dotenv
# Anthropic example
AI_PROVIDER=anthropic
AI_MODEL=claude-sonnet-4-6
ANTHROPIC_API_KEY=replace_me
```

```dotenv
# OpenAI example
AI_PROVIDER=openai
AI_MODEL=gpt-5-nano-2025-08-07
OPENAI_API_KEY=replace_me
```

```dotenv
# OpenRouter example
AI_PROVIDER=openrouter
AI_MODEL=anthropic/claude-sonnet-4.6
OPENROUTER_API_KEY=replace_me
```

Do not commit `.env`; it contains credentials.

## How to Use Dialekt

### 1. Create a learning configuration

On the setup page:

1. Choose your native language and the language you want to learn.
2. Select a CEFR level from A1 to C2. This controls vocabulary and grammar complexity.
3. Choose a formal or informal register.
4. Name and save the configuration.

You will land on the Dashboard, where each configuration has its own conversations and mistake-review queue.

### 2. Start or resume a conversation

Select **New Chat** on a Dashboard card. Expand the session count to resume an earlier conversation.

You can write in either language:

- **Native language:** Dialekt translates your phrase, adds pronunciation help, and answers in the target language.
- **Target language:** Dialekt keeps your original phrase visible, explains genuine errors, and shows a correction separately.
- **Romanized target language:** For languages with another writing system, type a phonetic form such as `ohayou gozaimasu` (Japanese), `ti kaneis` (Greek), or `kayfa haluk` (Arabic). Dialekt treats it as target-language practice and bridges you to the native script without counting the script conversion itself as a mistake.

Tutor replies include IPA, a native-language phonetic guide, a translation, and usually a follow-up question. Use the speaker button beside a phrase to hear it through your browser's text-to-speech support.

### 3. Review corrections

When the tutor identifies a genuine error, Dialekt adds it to the configuration's review queue automatically.

1. Select **Review** on a Dashboard card or in the Chat header.
2. Use **Active**, **Learned**, and **All** to filter the queue.
3. Select **Mark learned** when a correction feels familiar.
4. Open the Learned filter and select **Review again** to return an item to active practice.

Deleting a chat session does not delete its saved corrections. Deleting the entire learning configuration removes its sessions and mistake history.

## Using Voice Input

Dialekt supports browser-based speech-to-text:

1. Select the microphone beside the message field.
2. Use the language badge shown during recording to switch between your native and target language.
3. Speak naturally and select stop, or wait for recognition to finish.
4. Review the transcript in the message field before sending it.

Voice recognition uses the browser's Web Speech API and may require internet access. Browser support and recognition quality vary; Chromium-based browsers generally provide the broadest support. Your browser may ask for microphone permission the first time.

## Data and Privacy

- Learning configurations, chat history, and saved mistakes are stored in the configured PostgreSQL database.
- Conversation text and recent context are sent to the selected AI provider to generate a tutor response.
- Voice recognition and text-to-speech are browser features and may use services operated by the browser vendor.
- Dialekt currently has no user accounts or per-user authorization. Run it as a personal, trusted-instance application unless you add authentication and ownership controls.
- Keep `.env`, database backups, and provider credentials private.

## Troubleshooting

### The database is unavailable

Confirm PostgreSQL is healthy, then rerun setup:

```bash
docker compose -f dockercompose.yml ps
mix ecto.setup
```

### The tutor reports an API or model error

Check that `AI_PROVIDER` matches the API key variable and that `AI_MODEL` is a model ID available to that provider. Restart `mix phx.server` after changing `.env`.

### Voice input is unavailable

Grant microphone permission, use a browser that supports the Web Speech API, and verify that the selected language is supported by your browser. Privacy extensions can block speech recognition on localhost.

### Start over with an empty local database

The following command permanently deletes local configurations, sessions, and mistakes before recreating the database:

```bash
mix ecto.reset
```

## Architecture

```text
SetupLive ──► DashboardLive ──► ChatLive ──► Tutor / ReqLLM ──► AI provider
                    │               │
                    │               └── saves sessions and genuine corrections
                    ▼
                ReviewLive ◄──── Learning context ────► PostgreSQL
```

- `Dialekt.Tutor` builds the CEFR/register contract, calls ReqLLM, and parses structured replies.
- `Dialekt.Learning` owns configurations, chat sessions, transactional response completion, and mistake-review state.
- Phoenix LiveView provides setup, Dashboard, Chat, and Review interactions without a separate frontend API.

