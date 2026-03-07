# Dialekt

An AI-powered language learning app that adapts to your skill level and provides real-time conversational practice with Claude.

## Features

### Learning Configuration
- **12 Major Languages**: English, Spanish, French, German, Portuguese, Chinese, Japanese, Arabic, Russian, Korean, Hindi, Italian
- **Native Language Support**: Get translations and explanations in your native language
- **CEFR Levels (A1-C2)**: From beginner to mastery
- **Register Options**: Practice formal or informal speech patterns

### AI Tutor Experience
- **Intelligent Feedback**: Get corrections only when practicing the target language
- **Contextual Translations**: See your phrases translated with IPA and phonetic guides
- **Adaptive Responses**: Claude adjusts vocabulary and grammar to your CEFR level
- **Dynamic Conversation Starters**: AI-generated prompts tailored to your learning context

### Technical Features
- Built with Phoenix LiveView for real-time interactions
- Powered by Claude Sonnet 4.6 API
- Phonetic transcriptions using native language conventions
- Clean, responsive UI optimized for learning

## Setup

1. **Set your Anthropic API key:**
   ```bash
   export ANTHROPIC_API_KEY=your-api-key-here
   ```

2. **Install dependencies:**
   ```bash
   mix setup
   ```

3. **Start the Phoenix server:**
   ```bash
   mix phx.server
   ```

4. **Open your browser:**

   Visit [`localhost:4000`](http://localhost:4000)

## How It Works

1. **Choose Your Configuration**: Select native language, target language, CEFR level, and register
2. **Start Chatting**: Use conversation starters or type your own messages
3. **Get Smart Feedback**:
   - Write in your native language → See the translation in target language
   - Write in target language → Get corrections and encouragement
4. **Practice & Improve**: Continue the conversation at your level

## Tech Stack

- **Framework**: Phoenix 1.7 + LiveView
- **Language**: Elixir
- **AI**: Claude Sonnet 4.6 via Anthropic API
- **Styling**: Custom CSS with CSS variables

## Learn More

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Anthropic Claude API](https://www.anthropic.com/api)
