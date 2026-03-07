defmodule Dialekt.TutorTest do
  use ExUnit.Case, async: true

  alias Dialekt.Tutor
  alias Dialekt.Languages

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

  describe "chat/2" do
    @tag :skip
    test "sends message to Claude API with proper configuration" do
      # This test would require mocking the API call
      # For now, we'll skip it since it requires actual API integration
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
  end
end
