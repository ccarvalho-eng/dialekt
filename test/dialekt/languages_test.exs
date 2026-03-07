defmodule Dialekt.LanguagesTest do
  use ExUnit.Case, async: true

  alias Dialekt.Languages

  describe "all_languages/0" do
    test "returns a list of all available languages" do
      languages = Languages.all_languages()

      assert is_list(languages)
      assert length(languages) > 50

      # Check structure of first language
      first = hd(languages)
      assert %{code: _, name: _, flag: _, native: _} = first
      assert is_binary(first.code)
      assert is_binary(first.name)
      assert is_binary(first.flag)
      assert is_binary(first.native)
    end

    test "includes major languages" do
      languages = Languages.all_languages()
      codes = Enum.map(languages, & &1.code)

      assert "en" in codes
      assert "es" in codes
      assert "fr" in codes
      assert "de" in codes
      assert "zh" in codes
      assert "ja" in codes
      assert "ar" in codes
      assert "ru" in codes
    end
  end

  describe "get_language/1" do
    test "returns language by code" do
      assert %{code: "en", name: "English"} = Languages.get_language("en")
      assert %{code: "es", name: "Spanish"} = Languages.get_language("es")
      assert %{code: "fr", name: "French"} = Languages.get_language("fr")
    end

    test "returns nil for invalid code" do
      assert nil == Languages.get_language("invalid")
    end
  end

  describe "cefr_levels/0" do
    test "returns all CEFR levels" do
      levels = Languages.cefr_levels()

      assert length(levels) == 6

      Enum.each(levels, fn level ->
        assert %{code: _, label: _, desc: _} = level
        assert level.code in ["A1", "A2", "B1", "B2", "C1", "C2"]
      end)
    end
  end

  describe "get_cefr_level/1" do
    test "returns CEFR level by code" do
      assert %{code: "A1", label: "A1", desc: "Beginner"} =
               Languages.get_cefr_level("A1")

      assert %{code: "C2", label: "C2", desc: "Mastery"} =
               Languages.get_cefr_level("C2")
    end

    test "returns nil for invalid level" do
      assert nil == Languages.get_cefr_level("X1")
    end
  end

  describe "registers/0" do
    test "returns formal and informal registers" do
      registers = Languages.registers()

      assert length(registers) == 2

      assert Enum.find(registers, &(&1.code == "formal"))
      assert Enum.find(registers, &(&1.code == "informal"))

      Enum.each(registers, fn register ->
        assert %{code: _, label: _, desc: _, icon: _} = register
      end)
    end
  end

  describe "get_register/1" do
    test "returns register by code" do
      formal = Languages.get_register("formal")
      assert %{code: "formal", label: "Formal"} = formal

      informal = Languages.get_register("informal")
      assert %{code: "informal", label: "Informal"} = informal
    end

    test "returns nil for invalid register" do
      assert nil == Languages.get_register("invalid")
    end
  end

  describe "native_quick_languages/0" do
    test "returns quick selection of major native languages" do
      quick = Languages.native_quick_languages()

      assert is_list(quick)
      assert length(quick) == 12

      codes = Enum.map(quick, & &1.code)
      # Check for major languages
      assert "en" in codes
      assert "es" in codes
      assert "zh" in codes
      assert "ja" in codes
    end
  end
end
