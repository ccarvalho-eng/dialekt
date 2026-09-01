defmodule Dialekt.Learning.Mistake do
  @moduledoc """
  A correction captured for later review within a learning configuration.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Dialekt.Learning.Config

  @required_fields ~w(config_id original_input corrected_form)a
  @optional_fields ~w(explanation learned_at)a

  schema "mistakes" do
    belongs_to(:config, Config)
    field(:original_input, :string)
    field(:corrected_form, :string)
    field(:explanation, :string)
    field(:learned_at, :utc_datetime)

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{}

  @doc """
  Builds a changeset for a captured correction.
  """
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(mistake, attrs) do
    mistake
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:config_id)
  end
end
