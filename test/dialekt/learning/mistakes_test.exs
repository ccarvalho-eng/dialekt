defmodule Dialekt.Learning.MistakesTest do
  use Dialekt.DataCase, async: true

  alias Dialekt.Learning
  alias Dialekt.Learning.Mistake

  describe "mistake review" do
    setup do
      {:ok, config} = create_config("Spanish Practice", "es")
      {:ok, other_config} = create_config("German Practice", "de")

      %{config: config, other_config: other_config}
    end

    test "lists newest mistakes first and isolates configurations", %{
      config: config,
      other_config: other_config
    } do
      {:ok, first} = create_mistake(config.id, "Como estas", "¿Cómo estás?")
      {:ok, second} = create_mistake(config.id, "Yo es", "Yo soy")
      {:ok, other} = create_mistake(other_config.id, "Ich bin gut", "Mir geht es gut")

      assert Enum.map(Learning.list_mistakes_for_config(config.id), & &1.id) == [
               second.id,
               first.id
             ]

      refute other.id in Enum.map(Learning.list_mistakes_for_config(config.id), & &1.id)

      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_mistake_for_config!(config.id, other.id)
      end
    end

    test "filters and counts active, learned, and all mistakes", %{config: config} do
      {:ok, active} = create_mistake(config.id, "Como estas", "¿Cómo estás?")
      {:ok, learned} = create_mistake(config.id, "Yo es", "Yo soy")
      {:ok, learned} = Learning.mark_mistake_learned(config.id, learned.id)

      assert Enum.map(Learning.list_mistakes_for_config(config.id), & &1.id) == [active.id]

      assert Enum.map(
               Learning.list_mistakes_for_config(config.id, status: :learned),
               & &1.id
             ) == [learned.id]

      assert Learning.count_mistakes_for_config(config.id, :active) == 1
      assert Learning.count_mistakes_for_config(config.id, :learned) == 1
      assert Learning.count_mistakes_for_config(config.id, :all) == 2
    end

    test "marks a mistake learned and restores it", %{config: config} do
      {:ok, mistake} = create_mistake(config.id, "Como estas", "¿Cómo estás?")

      assert {:ok, %Mistake{learned_at: %DateTime{}} = learned} =
               Learning.mark_mistake_learned(config.id, mistake.id)

      assert {:ok, %Mistake{learned_at: nil}} =
               Learning.restore_mistake(config.id, learned.id)
    end

    test "deleting a config cascades to its mistakes", %{config: config} do
      {:ok, mistake} = create_mistake(config.id, "Como estas", "¿Cómo estás?")

      assert {:ok, _config} = Learning.delete_config(config)
      assert Repo.get(Mistake, mistake.id) == nil
    end

    test "completes a tutor response and correction atomically", %{config: config} do
      {:ok, session} = Learning.create_session(config.id)
      messages = [%{"role" => "assistant", "content" => "Corrected response"}]

      assert {:ok, updated_session, %Mistake{} = mistake} =
               Learning.complete_tutor_response(session, messages, %{
                 original_input: "Como estas",
                 corrected_form: "¿Cómo estás?",
                 explanation: "Add the accents."
               })

      assert updated_session.messages == messages
      assert mistake.config_id == config.id
      assert mistake.original_input == "Como estas"
      assert mistake.corrected_form == "¿Cómo estás?"
      assert Learning.count_mistakes_for_config(config.id, :all) == 1
    end

    test "saves the response without a mistake when correction metadata is blank", %{
      config: config
    } do
      {:ok, session} = Learning.create_session(config.id)
      messages = [%{"role" => "assistant", "content" => "Encouraging response"}]

      assert {:ok, updated_session, nil} =
               Learning.complete_tutor_response(session, messages, %{
                 original_input: "Hola",
                 corrected_form: "  ",
                 explanation: "Great work."
               })

      assert updated_session.messages == messages
      assert Learning.count_mistakes_for_config(config.id, :all) == 0
    end

    test "rolls back message persistence when a valid-looking correction cannot be stored", %{
      config: config
    } do
      {:ok, session} = Learning.create_session(config.id)
      messages = [%{"role" => "assistant", "content" => "Response"}]

      assert {:error, %Ecto.Changeset{}} =
               Learning.complete_tutor_response(session, messages, %{
                 original_input: "Como estas",
                 corrected_form: "¿Cómo estás?",
                 explanation: ["not", "text"]
               })

      assert Learning.get_session!(session.id).messages == []
      assert Learning.count_mistakes_for_config(config.id, :all) == 0
    end
  end

  defp create_config(name, target_language_code) do
    Learning.create_config(%{
      name: name,
      native_language_code: "en",
      target_language_code: target_language_code,
      cefr_level_code: "A2",
      register_code: "informal"
    })
  end

  defp create_mistake(config_id, original_input, corrected_form) do
    Learning.create_mistake(%{
      config_id: config_id,
      original_input: original_input,
      corrected_form: corrected_form,
      explanation: "A short explanation"
    })
  end
end
