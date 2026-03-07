defmodule Dialekt.References do
  @moduledoc """
  Handles fetching language reference data (alphabet, numbers) from Claude API.
  """

  @claude_api_url "https://api.anthropic.com/v1/messages"
  @model "claude-sonnet-4-6"

  def fetch(native, target) do
    api_key = Application.get_env(:dialekt, :anthropic_api_key)

    if !api_key do
      {:error, "API key not configured"}
    else
      prompt = """
      Generate a language reference guide for a #{native.name} speaker learning #{target.name}.
      Return ONLY a valid JSON object with this exact structure, no markdown, no explanation:
      {
        "alphabet": [{"char": "A", "ipa": "...", "hint": "like '...' in #{native.name}"}],
        "numbers": [{"word": "zero", "target": "...", "ipa": "...", "hint": "..."}]
      }
      For alphabet: include all letters/characters of #{target.name} with accurate IPA and a short pronunciation hint using #{native.name} phonetic conventions.
      For numbers: include 0-20, then 30, 40, 50, 100, 1000. For each number include the target word, IPA, and a transliteration hint using #{native.name} phonetic conventions (same as alphabet hints).
      Keep IPA accurate. Hints should help a #{native.name} speaker approximate the sound.
      """

      headers = [
        {"Content-Type", "application/json"},
        {"x-api-key", api_key},
        {"anthropic-version", "2023-06-01"}
      ]

      body = %{
        model: @model,
        max_tokens: 4000,
        messages: [%{role: "user", content: prompt}]
      }

      case Req.post(@claude_api_url, json: body, headers: headers) do
        {:ok, %{status: 200, body: %{"content" => content}}} ->
          raw = Enum.map(content, fn block -> Map.get(block, "text", "") end) |> Enum.join("")
          clean = String.replace(raw, ~r/```json|```/, "") |> String.trim()

          case Jason.decode(clean) do
            {:ok, data} -> {:ok, data}
            {:error, _} -> {:error, "Could not parse reference data"}
          end

        {:ok, %{status: status, body: body}} ->
          {:error, "API error: #{status} - #{inspect(body)}"}

        {:error, error} ->
          {:error, "Request failed: #{inspect(error)}"}
      end
    end
  end
end
