defmodule Dialekt.Learning.ChatSession do
  @moduledoc """
  Schema for persisting chat sessions and their message history.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Dialekt.Learning.Config

  @required_fields ~w(config_id)a
  @optional_fields ~w()a

  schema "chat_sessions" do
    belongs_to(:config, Config)
    field(:messages, {:array, :map}, default: [])

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{}

  @doc """
  Changeset for creating a new chat session.
  """
  @spec create_changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def create_changeset(session, attrs) do
    session
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:config_id)
  end

  @doc """
  Changeset for adding a message to the session.
  """
  @spec add_message_changeset(t(), map()) :: Ecto.Changeset.t()
  def add_message_changeset(session, message) do
    updated_messages = session.messages ++ [message]
    change(session, messages: updated_messages)
  end
end
