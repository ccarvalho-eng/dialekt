defmodule Dialekt.Learning do
  @moduledoc """
  The Learning context handles persistence for language learning
  configurations and chat sessions.
  """

  import Ecto.Changeset
  import Ecto.Query

  alias Dialekt.Learning.{ChatSession, Config, Mistake}
  alias Dialekt.Repo

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
  Updates the conversation starters for a config.
  """
  @spec update_config_starters(Config.t(), list(String.t())) ::
          {:ok, Config.t()} | {:error, Ecto.Changeset.t()}
  def update_config_starters(%Config{} = config, starters) do
    config
    |> change(starters: starters)
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

  @doc """
  Counts the number of chat sessions for a given config.
  """
  @spec count_sessions_for_config(integer()) :: integer()
  def count_sessions_for_config(config_id) do
    ChatSession
    |> where([s], s.config_id == ^config_id)
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns chat-session counts keyed by configuration ID.
  """
  @spec session_counts_by_config([integer()]) :: %{optional(integer()) => non_neg_integer()}
  def session_counts_by_config([]) do
    %{}
  end

  def session_counts_by_config(config_ids) do
    ChatSession
    |> where([s], s.config_id in ^config_ids)
    |> group_by([s], s.config_id)
    |> select([s], {s.config_id, count(s.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Updates the entire message history for a session.
  """
  @spec update_session_messages(ChatSession.t(), list(map())) ::
          {:ok, ChatSession.t()} | {:error, Ecto.Changeset.t()}
  def update_session_messages(%ChatSession{} = session, messages) do
    session
    |> change(messages: messages)
    |> Repo.update()
  end

  @doc """
  Persists a completed assistant response and its optional correction atomically.
  """
  @spec complete_tutor_response(ChatSession.t(), list(map()), map() | nil) ::
          {:ok, ChatSession.t(), Mistake.t() | nil} | {:error, Ecto.Changeset.t()}
  def complete_tutor_response(%ChatSession{} = session, messages, mistake_attrs) do
    mistake_attrs = normalize_mistake_attrs(session, mistake_attrs)

    case Repo.transaction(fn ->
           with {:ok, updated_session} <-
                  session
                  |> change(messages: messages)
                  |> Repo.update(),
                {:ok, mistake} <- insert_optional_mistake(mistake_attrs) do
             {updated_session, mistake}
           else
             {:error, %Ecto.Changeset{} = changeset} -> Repo.rollback(changeset)
           end
         end) do
      {:ok, {updated_session, mistake}} ->
        {:ok, updated_session, mistake}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}
    end
  end

  ## Mistakes

  @doc """
  Creates a correction for later review.
  """
  @spec create_mistake(map()) :: {:ok, Mistake.t()} | {:error, Ecto.Changeset.t()}
  def create_mistake(attrs) do
    %Mistake{}
    |> Mistake.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists recent mistakes for a configuration, filtered by review state.
  """
  @spec list_mistakes_for_config(integer(), keyword()) :: [Mistake.t()]
  def list_mistakes_for_config(config_id, opts \\ []) do
    status = Keyword.get(opts, :status, :active)
    limit = opts |> Keyword.get(:limit, 50) |> min(100) |> max(1)

    Mistake
    |> where([m], m.config_id == ^config_id)
    |> filter_mistakes_by_status(status)
    |> order_by([m], desc: m.inserted_at, desc: m.id)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Counts mistakes for a configuration and review state.
  """
  @spec count_mistakes_for_config(integer(), :active | :learned | :all) :: non_neg_integer()
  def count_mistakes_for_config(config_id, status \\ :active) do
    Mistake
    |> where([m], m.config_id == ^config_id)
    |> filter_mistakes_by_status(status)
    |> Repo.aggregate(:count)
  end

  @doc """
  Returns active mistake counts keyed by configuration ID.
  """
  @spec active_mistake_counts_by_config([integer()]) :: %{
          optional(integer()) => non_neg_integer()
        }
  def active_mistake_counts_by_config([]) do
    %{}
  end

  def active_mistake_counts_by_config(config_ids) do
    Mistake
    |> where([m], m.config_id in ^config_ids and is_nil(m.learned_at))
    |> group_by([m], m.config_id)
    |> select([m], {m.config_id, count(m.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc """
  Gets a mistake only when it belongs to the supplied configuration.
  """
  @spec get_mistake_for_config!(integer(), integer()) :: Mistake.t()
  def get_mistake_for_config!(config_id, mistake_id) do
    Repo.get_by!(Mistake, id: mistake_id, config_id: config_id)
  end

  @doc """
  Marks a config-scoped mistake as learned.
  """
  @spec mark_mistake_learned(integer(), integer()) ::
          {:ok, Mistake.t()} | {:error, Ecto.Changeset.t()}
  def mark_mistake_learned(config_id, mistake_id) do
    config_id
    |> get_mistake_for_config!(mistake_id)
    |> change(learned_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> Repo.update()
  end

  @doc """
  Restores a config-scoped mistake to active review.
  """
  @spec restore_mistake(integer(), integer()) ::
          {:ok, Mistake.t()} | {:error, Ecto.Changeset.t()}
  def restore_mistake(config_id, mistake_id) do
    config_id
    |> get_mistake_for_config!(mistake_id)
    |> change(learned_at: nil)
    |> Repo.update()
  end

  defp filter_mistakes_by_status(query, :active) do
    where(query, [m], is_nil(m.learned_at))
  end

  defp filter_mistakes_by_status(query, :learned) do
    where(query, [m], not is_nil(m.learned_at))
  end

  defp filter_mistakes_by_status(query, :all) do
    query
  end

  defp normalize_mistake_attrs(_session, nil) do
    nil
  end

  defp normalize_mistake_attrs(session, attrs) when is_map(attrs) do
    original_input = attrs[:original_input] || attrs["original_input"]
    corrected_form = attrs[:corrected_form] || attrs["corrected_form"]

    if present_text?(original_input) && present_text?(corrected_form) do
      %{
        config_id: session.config_id,
        original_input: String.trim(original_input),
        corrected_form: String.trim(corrected_form),
        explanation: attrs[:explanation] || attrs["explanation"]
      }
    end
  end

  defp insert_optional_mistake(nil) do
    {:ok, nil}
  end

  defp insert_optional_mistake(attrs) do
    create_mistake(attrs)
  end

  defp present_text?(value) do
    is_binary(value) && String.trim(value) != ""
  end
end
