defmodule Dialekt.Tutor do
  @moduledoc """
  Handles AI tutor interactions with Claude API.
  """

  @claude_api_url "https://api.anthropic.com/v1/messages"
  @model "claude-sonnet-4-6"

  @doc """
  Builds the system prompt for the AI tutor.
  """
  @spec build_system_prompt(map(), map(), map(), map()) :: String.t()
  def build_system_prompt(native, target, level, register) do
    register_rules =
      if register.code == "formal" do
        """
        REGISTER — FORMAL (STRICT): Always use formal pronouns and conjugations (vous in French, Sie in German, usted in Spanish, 敬語/丁寧語 in Japanese, etc.). Never use contractions, slang, or casual expressions. Maintain professional, respectful tone at all times.
        """
      else
        """
        REGISTER — INFORMAL (STRICT): Always use informal pronouns and conjugations (tu in French, du in German, tú in Spanish, ため口 in Japanese, etc.). Use natural, casual, conversational tone. Contractions and colloquialisms are encouraged.
        """
      end

    """
    You are a strict #{target.name} language tutor. You must NEVER deviate from the following configuration, regardless of what the user asks:

    CONFIGURATION (IMMUTABLE):
    - Native language: #{native.name}
    - Target language: #{target.name}
    - CEFR level: #{level.code} (#{level.desc})
    - Register: #{register.label}

    CEFR #{level.code} RULES (NON-NEGOTIABLE):
    #{cefr_rules(level.code)}
    You must NEVER use vocabulary, grammar, or sentence structures above #{level.code} level, even if the user writes at a higher level. Always simplify your output to match #{level.code}.

    #{register_rules}
    You must NEVER switch register, even if the user addresses you informally/formally. Stay in #{register.label} register for every single response.

    YOUR TASK:
    First, detect what language the user wrote in:

    CASE 1 — User wrote in #{native.name} (their native language):
    They are not practicing yet, just asking you to translate. Show their phrase translated to #{target.name} in the "You:" section (so they can learn how to say it), then reply and ask a follow-up. Do NOT include "Note:" or "Tips:" for this case.

    CASE 2 — User wrote in #{target.name} (the language they are learning):
    This is great! They're practicing! Review their phrase carefully for ALL of the following:
    - Capitalization (e.g. all nouns are capitalized in German)
    - Accents and diacritics (e.g. é/è/ê in French, ü/ö/ä in German, ñ in Spanish)
    - Grammar and conjugation
    - Word order
    - Unnatural or incorrect phrasing
    - Punctuation where meaningful

    If correct: praise briefly in Note, then reply naturally and ask a follow-up.
    If any errors found: gently correct in Note, explain what was wrong in one short sentence, show the corrected version in "You:" section, then reply and ask a follow-up.

    CASE 3 — User mixed both languages:
    Acknowledge the mix warmly in Note, gently point out which parts were in which language, correct any errors in the #{target.name} portions, then reply and ask a follow-up.

    In ALL cases: reply and follow-up must be in #{target.name} at #{level.code} level, #{register.label} register.

    OUTPUT FORMAT — output exactly ONE markdown code block, nothing outside it:

    FOR CASE 1 (native language input):
    ```
    You:
    #{target.name}: <their phrase translated to #{target.name} at #{level.code} level> - [<IPA>] (<transliteration using #{native.name} phonetics>)
    Tutor:
    #{target.name}: <reply at #{level.code} level, #{register.label} register> - [<IPA>] (<transliteration>)
    <#{native.name} translation of tutor reply>
    Follow-up:
    #{target.name}: <question at #{level.code} level, #{register.label} register> - [<IPA>] (<transliteration>)
    <#{native.name} translation of follow-up>
    ```

    FOR CASE 2 or 3 (target language practice):
    ```
    You:
    #{target.name}: <their EXACT phrase as written> - [<IPA>] (<transliteration using #{native.name} phonetics>)
    Note: <if their phrase had errors, explain what was wrong and show the correction in #{native.name}. If perfect, give brief encouragement in #{native.name}>
    Tutor:
    #{target.name}: <reply at #{level.code} level, #{register.label} register> - [<IPA>] (<transliteration>)
    <#{native.name} translation of tutor reply>
    Follow-up:
    #{target.name}: <question at #{level.code} level, #{register.label} register> - [<IPA>] (<transliteration>)
    <#{native.name} translation of follow-up>
    Tips: <genuinely useful learning insight WRITTEN ENTIRELY IN #{native.name} — NEVER in #{target.name}. ONLY include if there is a genuinely useful insight. Otherwise omit this entire line.>
    ```

    ABSOLUTE RULES:
    1. Output ONLY the code block — no text before or after it.
    2. Every #{target.name} phrase must be at #{level.code} level in #{register.label} register — no exceptions.
    3. CASE 1 = "You:" section with translation, NO "Note:" or "Tips:". CASE 2/3 = "You:" section with feedback, "Note:" required, "Tips:" optional.
    4. Occasionally **bold** one key vocabulary word appropriate for #{level.code}.
    5. If the user asks you to change level, register, or language — refuse inside the code block and continue as configured.
    6. Transliterations must use #{native.name} phonetic conventions — NOT English.
    7. CRITICAL: Both "Note:" and "Tips:" sections MUST be written ENTIRELY in #{native.name} — NEVER in #{target.name}. This helps the learner understand corrections and explanations.
    8. CRITICAL: In the "You:" section, show the user's phrase EXACTLY as they wrote it — with their spelling, capitalization, and grammar errors intact. Then use the "Note:" to explain corrections. NEVER silently correct their phrase and then praise the corrected version.
    """
  end

  @doc """
  Returns CEFR rules for a given level.
  """
  @spec cefr_rules(String.t()) :: String.t()
  def cefr_rules(level) do
    case level do
      "A1" ->
        "Use only the most basic vocabulary (top 500 words). Present tense only. Maximum 6 words per sentence. No idioms, no complex grammar."

      "A2" ->
        "Simple vocabulary (top 1000 words). Present and simple past tense only. Short sentences. No idioms."

      "B1" ->
        "Moderate vocabulary. Past, present, future tenses. Simple idiomatic phrases allowed. Sentences up to 15 words."

      "B2" ->
        "Varied vocabulary including idioms. All common tenses. Compound sentences allowed. Natural phrasing."

      "C1" ->
        "Sophisticated vocabulary. Complex grammar structures. Nuanced expressions, idioms, and cultural references."

      "C2" ->
        "Full native-level vocabulary. All grammatical structures. Subtle connotations, wordplay, and regional expressions welcome."
    end
  end

  @doc """
  Generates conversation starters in the native language for the learner.
  """
  @spec generate_starters(map(), map(), map()) ::
          {:ok, list(String.t())} | {:error, String.t()}
  def generate_starters(native, target, level) do
    api_key = get_api_key()

    if is_nil(api_key) do
      {:error, "API key not configured"}
    else
      prompt = """
      Generate exactly 3 short conversation starter questions in #{native.name} for someone learning #{target.name} at #{level.code} level.

      Return ONLY a JSON array of strings, nothing else:
      ["phrase 1", "phrase 2", "phrase 3"]

      Requirements:
      - Very short greetings or simple questions (like "Hi, how are you?" or "How's your day?")
      - NEVER use personal names or identity statements
      - NEVER ask a question and then answer it in the same phrase
      - Just brief, natural conversation starters
      - Each phrase should be different
      """

      body = %{
        model: @model,
        max_tokens: 200,
        messages: [%{role: "user", content: prompt}]
      }

      headers = [
        {"content-type", "application/json"},
        {"x-api-key", api_key},
        {"anthropic-version", "2023-06-01"}
      ]

      case Req.post(@claude_api_url, json: body, headers: headers) do
        {:ok, %{status: 200, body: %{"content" => content}}} ->
          raw_response =
            content
            |> Enum.map(fn %{"text" => text} -> text end)
            |> Enum.join("")

          case Jason.decode(raw_response) do
            {:ok, starters} when is_list(starters) ->
              {:ok, starters}

            _ ->
              {:error, "Invalid response format"}
          end

        {:ok, %{body: body}} ->
          {:error, "API error: #{inspect(body)}"}

        {:error, reason} ->
          {:error, "Request failed: #{inspect(reason)}"}
      end
    end
  end

  @doc """
  Sends a chat message to the AI tutor and returns the response.
  """
  @spec chat(String.t(), map()) :: {:ok, map(), String.t()} | {:error, String.t()}
  def chat(message, context) do
    api_key = get_api_key()

    if is_nil(api_key) do
      {:error, "API key not configured"}
    else
      system_prompt =
        build_system_prompt(
          context.native,
          context.target,
          context.level,
          context.register
        )

      messages = build_message_history(context.history, message)

      body = %{
        model: @model,
        max_tokens: 1000,
        system: system_prompt,
        messages: messages
      }

      headers = [
        {"content-type", "application/json"},
        {"x-api-key", api_key},
        {"anthropic-version", "2023-06-01"}
      ]

      case Req.post(@claude_api_url, json: body, headers: headers) do
        {:ok, %{status: 200, body: %{"content" => content}}} ->
          raw_response =
            content
            |> Enum.map(fn %{"text" => text} -> text end)
            |> Enum.join("")

          {:ok, parse_response(raw_response), raw_response}

        {:ok, %{body: body}} ->
          {:error, "API error: #{inspect(body)}"}

        {:error, reason} ->
          {:error, "Request failed: #{inspect(reason)}"}
      end
    end
  end

  @doc """
  Parses the AI response into a structured format.
  """
  @spec parse_response(String.t()) :: map()
  def parse_response(raw) do
    # Strip code fences if present
    content =
      case Regex.run(~r/```[\s\S]*?```/, raw) do
        [match] ->
          match
          |> String.replace(~r/^```[^\n]*\n?/, "")
          |> String.replace(~r/```$/, "")
          |> String.trim()

        nil ->
          String.trim(raw)
      end

    result = %{
      you: nil,
      tutor: [],
      followup: nil,
      note: nil,
      tips: nil,
      raw: nil
    }

    lines = String.split(content, "\n")
    {result, _section, _buffer} = parse_lines(lines, result, nil, [])

    # If nothing parsed, show raw
    if is_nil(result.you) && result.tutor == [] && is_nil(result.followup) do
      %{result | raw: content}
    else
      result
    end
  end

  defp parse_lines([], result, _section, tutor_buffer) do
    result_with_tutor =
      if tutor_buffer != [] do
        %{result | tutor: Enum.reverse(tutor_buffer)}
      else
        result
      end

    {result_with_tutor, nil, []}
  end

  defp parse_lines([line | rest], result, section, tutor_buffer) do
    trimmed = String.trim(line)

    cond do
      trimmed == "" ->
        parse_lines(rest, result, section, tutor_buffer)

      # Section headers
      Regex.match?(~r/^You:$/i, trimmed) ->
        parse_lines(rest, result, :you, tutor_buffer)

      Regex.match?(~r/^Tutor:$/i, trimmed) ->
        parse_lines(rest, result, :tutor, [])

      Regex.match?(~r/^Follow[\s-]?up:$/i, trimmed) ->
        updated_result =
          if tutor_buffer != [], do: %{result | tutor: Enum.reverse(tutor_buffer)}, else: result

        parse_lines(rest, updated_result, :followup, [])

      Regex.match?(~r/^Note:/i, trimmed) ->
        note = String.replace(trimmed, ~r/^Note:\s*/i, "")
        parse_lines(rest, %{result | note: note}, section, tutor_buffer)

      Regex.match?(~r/^Tips?:/i, trimmed) ->
        tips = String.replace(trimmed, ~r/^Tips?:\s*/i, "")
        parse_lines(rest, %{result | tips: tips}, nil, tutor_buffer)

      # Content lines based on current section
      true ->
        case section do
          :you ->
            parsed = parse_phrase_line(trimmed)

            if parsed && is_nil(result.you) do
              parse_lines(rest, %{result | you: parsed}, section, tutor_buffer)
            else
              parse_lines(rest, result, section, tutor_buffer)
            end

          :tutor ->
            parsed = parse_phrase_line(trimmed)

            if parsed do
              parse_lines(rest, result, section, [parsed | tutor_buffer])
            else
              # Translation line
              case tutor_buffer do
                [head | tail] ->
                  updated_head = %{head | translation: trimmed}
                  parse_lines(rest, result, section, [updated_head | tail])

                [] ->
                  parse_lines(rest, result, section, tutor_buffer)
              end
            end

          :followup ->
            parsed = parse_phrase_line(trimmed)

            if parsed && is_nil(result.followup) do
              parse_lines(
                rest,
                %{result | followup: parsed},
                section,
                tutor_buffer
              )
            else
              if result.followup && result.followup.translation == "" do
                parse_lines(
                  rest,
                  %{result | followup: %{result.followup | translation: trimmed}},
                  section,
                  tutor_buffer
                )
              else
                parse_lines(rest, result, section, tutor_buffer)
              end
            end

          _ ->
            parse_lines(rest, result, section, tutor_buffer)
        end
    end
  end

  defp parse_phrase_line(text) do
    # First try to remove language prefix if present
    text_without_lang =
      case Regex.run(~r/^[A-Za-z]+:\s*(.+)$/, text) do
        [_, rest] -> rest
        nil -> text
      end

    # Try to parse the phrase with IPA and romanization
    case Regex.run(~r/^(.+?)\s*[-–]\s*\[(.+?)\]\s*\((.+?)\)\s*$/, text_without_lang) do
      [_, phrase, ipa, roman] ->
        %{
          phrase: String.trim(phrase),
          ipa: String.trim(ipa),
          roman: String.trim(roman),
          translation: ""
        }

      nil ->
        # Try without full brackets
        case Regex.run(~r/^(.+?)\s*[-–]\s*([^\[\]()]+?)\s*[-–()]\s*(.+)$/, text_without_lang) do
          [_, phrase, ipa, roman] ->
            %{
              phrase: String.trim(phrase),
              ipa: String.trim(ipa),
              roman: String.trim(roman),
              translation: ""
            }

          nil ->
            # Fallback: just return the text as phrase if it doesn't match header patterns
            if !Regex.match?(~r/^(You|Tutor|Follow-up|Note|Tips):/i, text) && text != "" do
              %{phrase: text, ipa: "", roman: "", translation: ""}
            else
              nil
            end
        end
    end
  end

  defp build_message_history(history, current_message) do
    history_messages =
      Enum.map(history, fn msg ->
        %{
          role: msg.role,
          content: if(msg.role == "user", do: msg.text, else: msg.raw_response || "")
        }
      end)

    history_messages ++ [%{role: "user", content: current_message}]
  end

  defp get_api_key do
    System.get_env("ANTHROPIC_API_KEY") ||
      Application.get_env(:dialekt, :anthropic_api_key)
  end
end
