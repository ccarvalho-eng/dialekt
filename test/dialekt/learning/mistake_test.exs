defmodule Dialekt.Learning.MistakeTest do
  use Dialekt.DataCase, async: true

  alias Dialekt.Learning.Mistake

  describe "changeset/2" do
    test "accepts the required correction fields" do
      changeset =
        Mistake.changeset(%Mistake{}, %{
          config_id: 1,
          original_input: "Como estas",
          corrected_form: "¿Cómo estás?",
          explanation: "Add the question mark and accents."
        })

      assert changeset.valid?
    end

    test "requires a config, original input, and corrected form" do
      changeset = Mistake.changeset(%Mistake{}, %{})

      assert %{config_id: _, original_input: _, corrected_form: _} = errors_on(changeset)
    end
  end
end
