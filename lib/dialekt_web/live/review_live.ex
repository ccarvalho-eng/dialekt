defmodule DialektWeb.ReviewLive do
  use DialektWeb, :live_view

  alias Dialekt.Learning

  @statuses %{"active" => :active, "learned" => :learned, "all" => :all}

  @impl true
  def mount(_params, _session, socket) do
    theme = get_connect_params(socket)["theme"] || "light"

    {:ok,
     socket
     |> stream_configure(:mistakes, dom_id: fn mistake -> "mistake-#{mistake.id}" end)
     |> assign(
       config: nil,
       status: :active,
       active_count: 0,
       learned_count: 0,
       all_count: 0,
       visible_count: 0,
       loading: true,
       load_request: nil,
       theme: theme
     )
     |> stream(:mistakes, [])}
  end

  @impl true
  def handle_params(%{"config_id" => config_id} = params, _uri, socket) do
    with {config_id, ""} <- Integer.parse(config_id),
         true <- config_id > 0 do
      status = parse_status(params["status"])
      request = {config_id, status}

      {:noreply,
       socket
       |> assign(status: status, loading: true, load_request: request)
       |> start_async({:load_review, request}, fn -> load_review(config_id, status) end)}
    else
      _ -> {:noreply, invalid_review_redirect(socket)}
    end
  end

  @impl true
  def handle_async(
        {:load_review, request},
        {:ok, {:not_found, request}},
        %{assigns: %{load_request: request}} = socket
      ) do
    {:noreply, invalid_review_redirect(socket)}
  end

  def handle_async(
        {:load_review, request},
        {:ok, %{request: request} = review},
        %{assigns: %{load_request: request}} = socket
      ) do
    {:noreply,
     socket
     |> assign(
       config: review.config,
       active_count: review.active_count,
       learned_count: review.learned_count,
       all_count: review.all_count,
       visible_count: length(review.mistakes),
       loading: false
     )
     |> stream(:mistakes, review.mistakes, reset: true)}
  end

  def handle_async({:load_review, _request}, {:ok, _stale_review}, socket) do
    {:noreply, socket}
  end

  def handle_async(
        {:load_review, request},
        {:exit, _reason},
        %{assigns: %{load_request: request}} = socket
      ) do
    {:noreply, invalid_review_redirect(socket)}
  end

  def handle_async({:load_review, _request}, {:exit, _reason}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("mark_learned", %{"id" => mistake_id}, socket) do
    update_mistake(socket, mistake_id, &Learning.mark_mistake_learned/2)
  end

  @impl true
  def handle_event("restore", %{"id" => mistake_id}, socket) do
    update_mistake(socket, mistake_id, &Learning.restore_mistake/2)
  end

  @impl true
  def handle_event("toggle_theme", _, socket) do
    theme = if socket.assigns.theme == "dark", do: "light", else: "dark"

    {:noreply,
     socket
     |> assign(theme: theme)
     |> push_event("update-theme", %{theme: theme})}
  end

  @impl true
  def handle_event("sync_theme", %{"theme" => theme}, socket) do
    {:noreply, assign(socket, theme: theme)}
  end

  defp load_review(config_id, status) do
    %{
      request: {config_id, status},
      config: Learning.get_config!(config_id),
      mistakes: Learning.list_mistakes_for_config(config_id, status: status, limit: 50),
      active_count: Learning.count_mistakes_for_config(config_id, :active),
      learned_count: Learning.count_mistakes_for_config(config_id, :learned),
      all_count: Learning.count_mistakes_for_config(config_id, :all)
    }
  rescue
    Ecto.NoResultsError ->
      {:not_found, {config_id, status}}
  end

  defp update_mistake(socket, mistake_id, operation) do
    with {mistake_id, ""} <- Integer.parse(mistake_id),
         {:ok, _mistake} <- operation.(socket.assigns.config.id, mistake_id) do
      config_id = socket.assigns.config.id
      status = socket.assigns.status
      request = {config_id, status}

      {:noreply,
       socket
       |> assign(loading: true, load_request: request)
       |> start_async({:load_review, request}, fn -> load_review(config_id, status) end)}
    else
      _ -> {:noreply, put_flash(socket, :error, "That review item is unavailable.")}
    end
  rescue
    Ecto.NoResultsError ->
      {:noreply, put_flash(socket, :error, "That review item is unavailable.")}
  end

  defp parse_status(status) do
    Map.get(@statuses, status, :active)
  end

  defp invalid_review_redirect(socket) do
    socket
    |> put_flash(:error, "That learning configuration is unavailable.")
    |> push_navigate(to: ~p"/dashboard")
  end

  defp text_direction(language_code) when language_code in ["ar", "fa", "he", "ur"] do
    "rtl"
  end

  defp text_direction(_language_code) do
    "ltr"
  end

  defp empty_title(:active) do
    "No active mistakes"
  end

  defp empty_title(:learned) do
    "Nothing learned yet"
  end

  defp empty_title(:all) do
    "No mistakes recorded"
  end

  defp empty_message(:active) do
    "You are caught up. New corrections from chats will appear here."
  end

  defp empty_message(:learned) do
    "Mark a correction learned when you feel confident using it."
  end

  defp empty_message(:all) do
    "Corrections will be collected automatically as you practice."
  end
end
