defmodule Dialekt.Learning do
  @moduledoc """
  The Learning context handles persistence for language learning
  configurations and chat sessions.
  """

  alias Dialekt.Repo
  alias Dialekt.Learning.Config

  @doc """
  Returns the list of learning configs.
  """
  def list_configs do
    Repo.all(Config)
  end

  @doc """
  Gets a single config.
  Raises `Ecto.NoResultsError` if the Config does not exist.
  """
  def get_config!(id) do
    Repo.get!(Config, id)
  end

  @doc """
  Creates a learning config.
  """
  def create_config(attrs \\ %{}) do
    %Config{}
    |> Config.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a learning config.
  """
  def update_config(%Config{} = config, attrs) do
    config
    |> Config.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a learning config.
  """
  def delete_config(%Config{} = config) do
    Repo.delete(config)
  end
end
