defmodule Dialekt.TutorTest do
  use ExUnit.Case, async: true

  alias Dialekt.Languages
  alias Dialekt.Tutor

  describe "build_system_prompt/4" do
    test "builds system prompt with all parameters" do
      native = Languages.get_language("en")
      target = Languages.get_language("es")
      level = Languages.get_cefr_level("A1")
      register = Languages.get_register("informal")

      prompt = Tutor.build_system_prompt(native, target, level, register)

      assert prompt =~ "strict Spanish language tutor"
      assert prompt =~ "Native language: English"
      assert prompt =~ "Target language: Spanish"
      assert prompt =~ "CEFR level: A1 (Beginner)"
      assert prompt =~ "Register: Informal"
      assert prompt =~ "Use only the most basic vocabulary"
    end

    test "includes formal register rules when formal" do
      native = Languages.get_language("en")
      target = Languages.get_language("fr")
      level = Languages.get_cefr_level("B1")
      register = Languages.get_register("formal")

      prompt = Tutor.build_system_prompt(native, target, level, register)

      assert prompt =~ "REGISTER — FORMAL (STRICT)"
      assert prompt =~ "Always use formal pronouns"
    end

    test "includes informal register rules when informal" do
      native = Languages.get_language("en")
      target = Languages.get_language("de")
      level = Languages.get_cefr_level("A2")
      register = Languages.get_register("informal")

      prompt = Tutor.build_system_prompt(native, target, level, register)

      assert prompt =~ "REGISTER — INFORMAL (STRICT)"
      assert prompt =~ "Always use informal pronouns"
    end

    test "classifies plausible romanized target input before native-language input" do
      native = Languages.get_language("en")
      level = Languages.get_cefr_level("A1")
      register = Languages.get_register("informal")

      examples = [
        {"el", "ti kaneis"},
        {"ja", "ohayou gozaimasu"},
        {"ar", "kayfa haluk"}
      ]

      for {target_code, example} <- examples do
        target = Languages.get_language(target_code)
        prompt = Tutor.build_system_prompt(native, target, level, register)

        assert prompt =~ "ROMANIZED TARGET INPUT"
        assert prompt =~ example
        assert prompt =~ "classify it as target-language practice"
        assert prompt =~ "Do not emit `Correction:` solely to convert romanization"
      end
    end

    test "requires explicit correction metadata only for genuine errors" do
      native = Languages.get_language("en")
      target = Languages.get_language("es")
      level = Languages.get_cefr_level("A2")
      register = Languages.get_register("informal")

      prompt = Tutor.build_system_prompt(native, target, level, register)

      assert prompt =~ "Correction: <corrected phrase>"
      assert prompt =~ "only when the learner made a genuine error"
      assert prompt =~ "Keep the learner's original input unchanged in `You:`"
      assert prompt =~ "Omit `Correction:`"
    end
  end

  describe "cefr_rules/1" do
    test "returns appropriate rules for each CEFR level" do
      assert Tutor.cefr_rules("A1") =~ "most basic vocabulary"
      assert Tutor.cefr_rules("A2") =~ "Simple vocabulary"
      assert Tutor.cefr_rules("B1") =~ "Moderate vocabulary"
      assert Tutor.cefr_rules("B2") =~ "Varied vocabulary"
      assert Tutor.cefr_rules("C1") =~ "Sophisticated vocabulary"
      assert Tutor.cefr_rules("C2") =~ "Full native-level"
    end
  end

  describe "parse_response/1" do
    test "parses well-formed response with all sections" do
      raw = """
      ```
      You:
      Spanish: Hola, ¿cómo estás? - [ola komo estas] (oh-lah koh-moh ehs-tahs)
      Tutor:
      Spanish: ¡Hola! Estoy bien. - [ola estoi bien] (oh-lah ehs-toy bee-en)
      Hello! I'm well.
      Follow-up:
      Spanish: ¿Y tú? - [i tu] (ee too)
      And you?
      Tips: Remember to use upside-down question marks at the beginning of questions in Spanish.
      ```
      """

      result = Tutor.parse_response(raw)

      assert result.you.phrase == "Hola, ¿cómo estás?"
      assert result.you.ipa == "ola komo estas"
      assert result.you.roman == "oh-lah koh-moh ehs-tahs"

      assert hd(result.tutor).phrase == "¡Hola! Estoy bien."
      assert hd(result.tutor).translation == "Hello! I'm well."

      assert result.followup.phrase == "¿Y tú?"
      assert result.followup.translation == "And you?"

      assert result.tips =~ "upside-down question marks"
    end

    test "handles response without code fences" do
      raw = """
      You:
      Spanish: Buenos días - [buenos dias] (bway-nohs dee-ahs)
      Tutor:
      Spanish: Buenos días - [buenos dias] (bway-nohs dee-ahs)
      Good morning
      """

      result = Tutor.parse_response(raw)

      assert result.you.phrase == "Buenos días"
      assert hd(result.tutor).phrase == "Buenos días"
    end

    test "handles malformed response gracefully" do
      raw = "Some unexpected response format"

      result = Tutor.parse_response(raw)

      assert result.raw == raw
      assert is_nil(result.you)
      assert result.tutor == []
    end

    test "parses correction notes" do
      raw = """
      ```
      You:
      Spanish: Como estas - [komo estas] (koh-moh ehs-tahs)
      Note: Remember the accent: ¿Cómo estás?
      Tutor:
      Spanish: Bien, gracias - [bien grasias] (bee-en grah-see-ahs)
      Good, thanks
      ```
      """

      result = Tutor.parse_response(raw)

      assert result.note =~ "Remember the accent"
    end

    test "parses an explicit correction separately from the explanation" do
      raw = """
      ```
      You:
      Spanish: Como estas - [komo estas] (koh-moh ehs-tahs)
      Correction: ¿Cómo estás?
      Note: Add the opening question mark and written accents.
      Tutor:
      Spanish: Estoy bien - [estoi bien] (ehs-toy bee-en)
      I am well
      ```
      """

      result = Tutor.parse_response(raw)

      assert result.you.phrase == "Como estas"
      assert result.correction == "¿Cómo estás?"
      assert result.note == "Add the opening question mark and written accents."
    end

    test "leaves correction empty for correct, native, and romanized bridge responses" do
      responses = [
        "You:\nSpanish: Hola - [ola] (oh-lah)\nNote: Great work!\nTutor:\nSpanish: Hola - [ola] (oh-lah)\nHello",
        "You:\nSpanish: Buenos días - [bwenos dias] (bweh-nohs dee-ahs)\nTutor:\nSpanish: Hola - [ola] (oh-lah)\nHello",
        "You:\nJapanese: ohayou - [o.ha.joː] (oh-hah-yoh)\nNote: In Japanese script: おはよう.\nTutor:\nJapanese: おはよう - [o.ha.joː] (oh-hah-yoh)\nGood morning"
      ]

      for raw <- responses do
        assert Tutor.parse_response(raw).correction == nil
      end
    end

    test "keeps correction empty when a malformed response falls back to raw text" do
      result = Tutor.parse_response("<unexpected>response</unexpected>")

      assert result.correction == nil
      assert result.raw == "<unexpected>response</unexpected>"
    end
  end

  describe "generate_starters/3" do
    @tag :llm
    test "returns three conversation starters" do
      native = Languages.get_language("en")
      target = Languages.get_language("es")
      level = Languages.get_cefr_level("A1")

      assert {:ok, starters} = Tutor.generate_starters(native, target, level)
      assert length(starters) == 3
      assert Enum.all?(starters, &is_binary/1)
    end
  end

  describe "chat/2" do
    @tag :llm
    test "returns a parsed response and raw text" do
      native = Languages.get_language("en")
      target = Languages.get_language("es")
      level = Languages.get_cefr_level("A1")
      register = Languages.get_register("informal")

      context = %{
        native: native,
        target: target,
        level: level,
        register: register,
        history: []
      }

      assert {:ok, parsed, raw} = Tutor.chat("Hola", context)
      assert is_map(parsed)
      assert is_binary(raw)
      assert String.length(raw) > 0
    end

    @tag :llm
    test "includes openrouter provider options when using openrouter" do
      original_provider = Application.get_env(:dialekt, :ai_provider)
      original_model = Application.get_env(:dialekt, :ai_model)

      Application.put_env(:dialekt, :ai_provider, "openrouter")
      Application.put_env(:dialekt, :ai_model, "anthropic/claude-sonnet-4.6")

      native = Languages.get_language("en")
      target = Languages.get_language("es")
      level = Languages.get_cefr_level("A1")
      register = Languages.get_register("informal")

      context = %{
        native: native,
        target: target,
        level: level,
        register: register,
        history: []
      }

      assert {:ok, _parsed, raw} = Tutor.chat("Hola", context)
      assert String.length(raw) > 0

      Application.put_env(:dialekt, :ai_provider, original_provider)
      Application.put_env(:dialekt, :ai_model, original_model)
    end
  end
end
