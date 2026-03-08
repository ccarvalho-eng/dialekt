defmodule Dialekt.Learning.Config do
  @moduledoc """
  Schema for persisting language learning configurations.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Dialekt.Learning.ChatSession

  schema "learning_configs" do
    field(:name, :string)
    field(:native_language_code, :string)
    field(:target_language_code, :string)
    field(:cefr_level_code, :string)
    field(:register_code, :string)

    has_many(:chat_sessions, ChatSession)

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating or updating a config.
  """
  def changeset(config, attrs) do
    config
    |> cast(attrs, [
      :name,
      :native_language_code,
      :target_language_code,
      :cefr_level_code,
      :register_code
    ])
    |> validate_required([
      :name,
      :native_language_code,
      :target_language_code,
      :cefr_level_code,
      :register_code
    ])
    |> validate_length(:name, min: 1, max: 255)
  end
end
