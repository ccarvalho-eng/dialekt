defmodule Dialekt.Learning.ChatSession do
  @moduledoc """
  Schema for persisting chat sessions and their message history.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Dialekt.Learning.Config

  schema "chat_sessions" do
    belongs_to(:config, Config)
    field(:messages, {:array, :map}, default: [])

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating a new chat session.
  """
  def create_changeset(session, attrs) do
    session
    |> cast(attrs, [:config_id])
    |> validate_required([:config_id])
    |> foreign_key_constraint(:config_id)
  end

  @doc """
  Changeset for adding a message to the session.
  """
  def add_message_changeset(session, message) do
    updated_messages = session.messages ++ [message]
    change(session, messages: updated_messages)
  end
end
