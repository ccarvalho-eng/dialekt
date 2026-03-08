defmodule Dialekt.Learning do
  @moduledoc """
  The Learning context handles persistence for language learning
  configurations and chat sessions.
  """

  import Ecto.Query
  alias Dialekt.Repo
  alias Dialekt.Learning.{ChatSession, Config}

  @doc """
  Returns the list of learning configs.
  """
  @spec list_configs() :: [Config.t()]
  def list_configs do
    Repo.all(Config)
  end

  @doc """
  Gets a single config.
  Raises `Ecto.NoResultsError` if the Config does not exist.
  """
  @spec get_config!(integer()) :: Config.t()
  def get_config!(id) do
    Repo.get!(Config, id)
  end

  @doc """
  Creates a learning config.
  """
  @spec create_config(map()) :: {:ok, Config.t()} | {:error, Ecto.Changeset.t()}
  def create_config(attrs \\ %{}) do
    %Config{}
    |> Config.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a learning config.
  """
  @spec update_config(Config.t(), map()) :: {:ok, Config.t()} | {:error, Ecto.Changeset.t()}
  def update_config(%Config{} = config, attrs) do
    config
    |> Config.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a learning config.
  """
  @spec delete_config(Config.t()) :: {:ok, Config.t()} | {:error, Ecto.Changeset.t()}
  def delete_config(%Config{} = config) do
    Repo.delete(config)
  end

  ## Chat Sessions

  @doc """
  Returns the list of chat sessions for a given config.
  """
  @spec list_sessions_for_config(integer()) :: [ChatSession.t()]
  def list_sessions_for_config(config_id) do
    ChatSession
    |> where([s], s.config_id == ^config_id)
    |> order_by([s], desc: s.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single chat session.
  Raises `Ecto.NoResultsError` if the session does not exist.
  """
  @spec get_session!(integer()) :: ChatSession.t()
  def get_session!(id) do
    Repo.get!(ChatSession, id)
  end

  @doc """
  Creates a new chat session for a config.
  """
  @spec create_session(integer()) ::
          {:ok, ChatSession.t()} | {:error, Ecto.Changeset.t()}
  def create_session(config_id) do
    %ChatSession{}
    |> ChatSession.create_changeset(%{config_id: config_id})
    |> Repo.insert()
  end

  @doc """
  Adds a message to an existing chat session.
  """
  @spec add_message(ChatSession.t(), map()) ::
          {:ok, ChatSession.t()} | {:error, Ecto.Changeset.t()}
  def add_message(%ChatSession{} = session, message) do
    session
    |> ChatSession.add_message_changeset(message)
    |> Repo.update()
  end

  @doc """
  Deletes a chat session.
  """
  @spec delete_session(ChatSession.t()) ::
          {:ok, ChatSession.t()} | {:error, Ecto.Changeset.t()}
  def delete_session(%ChatSession{} = session) do
    Repo.delete(session)
  end
end
