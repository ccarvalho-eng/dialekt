defmodule Dialekt.LearningTest do
  use Dialekt.DataCase, async: true

  alias Dialekt.Learning
  alias Dialekt.Learning.{ChatSession, Config}

  describe "list_configs/0" do
    test "returns all configs" do
      config1 = insert_config(%{name: "German Practice"})
      config2 = insert_config(%{name: "French Practice"})

      configs = Learning.list_configs()

      assert length(configs) == 2
      assert Enum.any?(configs, &(&1.id == config1.id))
      assert Enum.any?(configs, &(&1.id == config2.id))
    end

    test "returns empty list when no configs exist" do
      assert Learning.list_configs() == []
    end
  end

  describe "get_config!/1" do
    test "returns the config with given id" do
      config = insert_config(%{name: "Test Config"})
      fetched = Learning.get_config!(config.id)

      assert fetched.id == config.id
      assert fetched.name == "Test Config"
    end

    test "raises when config does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_config!(99_999)
      end
    end
  end

  describe "create_config/1" do
    test "creates config with valid attributes" do
      attrs = %{
        name: "German B1",
        native_language_code: "en",
        target_language_code: "de",
        cefr_level_code: "B1",
        register_code: "formal"
      }

      assert {:ok, %Config{} = config} = Learning.create_config(attrs)
      assert config.name == "German B1"
      assert config.native_language_code == "en"
      assert config.target_language_code == "de"
      assert config.cefr_level_code == "B1"
      assert config.register_code == "formal"
    end

    test "returns error with invalid attributes" do
      attrs = %{name: ""}

      assert {:error, %Ecto.Changeset{}} = Learning.create_config(attrs)
    end
  end

  describe "update_config/2" do
    test "updates config with valid attributes" do
      config = insert_config(%{name: "Original Name"})
      attrs = %{name: "Updated Name"}

      assert {:ok, %Config{} = updated} =
               Learning.update_config(config, attrs)

      assert updated.name == "Updated Name"
      assert updated.id == config.id
    end

    test "returns error with invalid attributes" do
      config = insert_config(%{name: "Valid Name"})
      attrs = %{name: ""}

      assert {:error, %Ecto.Changeset{}} =
               Learning.update_config(config, attrs)
    end
  end

  describe "delete_config/1" do
    test "deletes the config" do
      config = insert_config(%{name: "To Delete"})

      assert {:ok, %Config{}} = Learning.delete_config(config)

      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_config!(config.id)
      end
    end
  end

  ## Chat Sessions

  describe "list_sessions_for_config/1" do
    test "returns all sessions for a config ordered by most recent" do
      config = insert_config(%{name: "Test Config"})
      {:ok, _session1} = Learning.create_session(config.id)
      {:ok, _session2} = Learning.create_session(config.id)

      sessions = Learning.list_sessions_for_config(config.id)

      assert length(sessions) == 2

      [first, second | _] = sessions
      assert first.inserted_at >= second.inserted_at
    end

    test "returns empty list when no sessions exist" do
      config = insert_config(%{name: "Test Config"})

      assert Learning.list_sessions_for_config(config.id) == []
    end

    test "only returns sessions for the specified config" do
      config1 = insert_config(%{name: "Config 1"})
      config2 = insert_config(%{name: "Config 2"})
      {:ok, _session1} = Learning.create_session(config1.id)
      {:ok, session2} = Learning.create_session(config2.id)

      sessions = Learning.list_sessions_for_config(config2.id)

      assert length(sessions) == 1
      assert hd(sessions).id == session2.id
    end
  end

  describe "get_session!/1" do
    test "returns the session with given id" do
      config = insert_config(%{name: "Test Config"})
      {:ok, session} = Learning.create_session(config.id)

      fetched = Learning.get_session!(session.id)

      assert fetched.id == session.id
      assert fetched.config_id == config.id
    end

    test "raises when session does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_session!(99_999)
      end
    end
  end

  describe "create_session/1" do
    test "creates session with valid config_id" do
      config = insert_config(%{name: "Test Config"})

      assert {:ok, %ChatSession{} = session} =
               Learning.create_session(config.id)

      assert session.config_id == config.id
      assert session.messages == []
    end

    test "returns error with invalid config_id" do
      assert {:error, %Ecto.Changeset{}} =
               Learning.create_session(99_999)
    end
  end

  describe "add_message/2" do
    test "adds message to session" do
      config = insert_config(%{name: "Test Config"})
      {:ok, session} = Learning.create_session(config.id)

      message = %{role: "user", content: "Hello"}

      assert {:ok, updated} = Learning.add_message(session, message)
      assert length(updated.messages) == 1
      assert hd(updated.messages) == message
    end

    test "appends to existing messages" do
      config = insert_config(%{name: "Test Config"})
      {:ok, session} = Learning.create_session(config.id)

      msg1 = %{role: "user", content: "Hello"}
      msg2 = %{role: "assistant", content: "Hi!"}

      {:ok, session} = Learning.add_message(session, msg1)
      {:ok, updated} = Learning.add_message(session, msg2)

      assert length(updated.messages) == 2
      assert updated.messages == [msg1, msg2]
    end
  end

  describe "delete_session/1" do
    test "deletes the session" do
      config = insert_config(%{name: "Test Config"})
      {:ok, session} = Learning.create_session(config.id)

      assert {:ok, %ChatSession{}} = Learning.delete_session(session)

      assert_raise Ecto.NoResultsError, fn ->
        Learning.get_session!(session.id)
      end
    end
  end

  # Test helpers

  defp insert_config(attrs) do
    default_attrs = %{
      name: "Test Config",
      native_language_code: "en",
      target_language_code: "de",
      cefr_level_code: "B1",
      register_code: "formal"
    }

    %Config{}
    |> Config.changeset(Map.merge(default_attrs, attrs))
    |> Repo.insert!()
  end
end
