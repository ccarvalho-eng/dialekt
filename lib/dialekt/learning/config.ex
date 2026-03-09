defmodule Dialekt.Learning.Config do
  @moduledoc """
  Schema for persisting language learning configurations.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Dialekt.Learning.ChatSession

  @required_fields ~w(name native_language_code target_language_code cefr_level_code register_code)a
  @optional_fields ~w(starters)a

  schema "learning_configs" do
    field(:name, :string)
    field(:native_language_code, :string)
    field(:target_language_code, :string)
    field(:cefr_level_code, :string)
    field(:register_code, :string)
    field(:starters, {:array, :string}, default: [])

    has_many(:chat_sessions, ChatSession)

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{}

  @doc """
  Changeset for creating or updating a config.
  """
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(config, attrs) do
    config
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 1, max: 255)
  end
end
