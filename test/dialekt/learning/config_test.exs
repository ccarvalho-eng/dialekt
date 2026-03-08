defmodule Dialekt.Learning.ConfigTest do
  use Dialekt.DataCase, async: true

  alias Dialekt.Learning.Config

  describe "changeset/2" do
    @valid_attrs %{
      name: "German Practice",
      native_language_code: "en",
      target_language_code: "de",
      cefr_level_code: "B1",
      register_code: "formal"
    }

    test "valid attributes" do
      changeset = Config.changeset(%Config{}, @valid_attrs)
      assert changeset.valid?
    end

    test "requires name" do
      attrs = Map.delete(@valid_attrs, :name)
      changeset = Config.changeset(%Config{}, attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "requires native_language_code" do
      attrs = Map.delete(@valid_attrs, :native_language_code)
      changeset = Config.changeset(%Config{}, attrs)

      assert %{native_language_code: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "requires target_language_code" do
      attrs = Map.delete(@valid_attrs, :target_language_code)
      changeset = Config.changeset(%Config{}, attrs)

      assert %{target_language_code: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "requires cefr_level_code" do
      attrs = Map.delete(@valid_attrs, :cefr_level_code)
      changeset = Config.changeset(%Config{}, attrs)

      assert %{cefr_level_code: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "requires register_code" do
      attrs = Map.delete(@valid_attrs, :register_code)
      changeset = Config.changeset(%Config{}, attrs)
      assert %{register_code: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates name cannot be blank" do
      attrs = Map.put(@valid_attrs, :name, "")
      changeset = Config.changeset(%Config{}, attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates name length maximum" do
      attrs = Map.put(@valid_attrs, :name, String.duplicate("a", 256))
      changeset = Config.changeset(%Config{}, attrs)

      assert %{name: ["should be at most 255 character(s)"]} =
               errors_on(changeset)
    end
  end
end
