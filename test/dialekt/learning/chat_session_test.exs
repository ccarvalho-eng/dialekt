defmodule Dialekt.Learning.ChatSessionTest do
  use Dialekt.DataCase, async: true

  alias Dialekt.Learning.{ChatSession, Config}
  alias Dialekt.Repo

  describe "create_changeset/2" do
    setup do
      config =
        Repo.insert!(%Config{
          name: "Test Config",
          native_language_code: "en",
          target_language_code: "de",
          cefr_level_code: "B1",
          register_code: "formal"
        })

      %{config: config}
    end

    test "valid attributes", %{config: config} do
      attrs = %{config_id: config.id}
      changeset = ChatSession.create_changeset(%ChatSession{}, attrs)
      assert changeset.valid?
    end

    test "requires config_id" do
      changeset = ChatSession.create_changeset(%ChatSession{}, %{})

      assert %{config_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates foreign key constraint" do
      attrs = %{config_id: 99999}

      assert {:error, changeset} =
               %ChatSession{}
               |> ChatSession.create_changeset(attrs)
               |> Repo.insert()

      assert %{config_id: ["does not exist"]} = errors_on(changeset)
    end

    test "defaults messages to empty list" do
      session = %ChatSession{}
      assert session.messages == []
    end
  end

  describe "add_message_changeset/2" do
    test "adds a message to existing messages" do
      session = %ChatSession{messages: [%{role: "user", content: "Hello"}]}

      new_message = %{role: "assistant", content: "Hi there!"}

      changeset = ChatSession.add_message_changeset(session, new_message)

      assert changeset.changes.messages == [
               %{role: "user", content: "Hello"},
               %{role: "assistant", content: "Hi there!"}
             ]
    end

    test "adds message to empty list" do
      session = %ChatSession{messages: []}
      new_message = %{role: "user", content: "First message"}

      changeset = ChatSession.add_message_changeset(session, new_message)

      assert changeset.changes.messages == [
               %{role: "user", content: "First message"}
             ]
    end
  end
end
