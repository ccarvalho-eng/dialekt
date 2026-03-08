defmodule DialektWeb.DashboardLive do
  use DialektWeb, :live_view

  alias Dialekt.Learning

  @impl true
  def mount(_params, _session, socket) do
    configs = Learning.list_configs()
    theme = get_connect_params(socket)["theme"] || "light"

    {:ok,
     assign(socket,
       configs: configs,
       show_form: Enum.empty?(configs),
       editing_config_id: nil,
       edit_name: "",
       expanded_config_id: nil,
       deleting_config_id: nil,
       deleting_session_id: nil,
       theme: theme
     )}
  end

  @impl true
  def handle_event("start_new_chat", %{"config-id" => config_id}, socket) do
    # Create a new chat session for this config
    {:ok, session} = Learning.create_session(String.to_integer(config_id))

    # Navigate to chat with session_id
    {:noreply, push_navigate(socket, to: ~p"/chat?session_id=#{session.id}")}
  end

  @impl true
  def handle_event("show_delete_config", %{"config-id" => config_id}, socket) do
    {:noreply, assign(socket, deleting_config_id: String.to_integer(config_id))}
  end

  @impl true
  def handle_event("delete_config", _, socket) do
    if socket.assigns.deleting_config_id do
      config = Learning.get_config!(socket.assigns.deleting_config_id)
      {:ok, _} = Learning.delete_config(config)

      # Refresh the configs list
      configs = Learning.list_configs()

      {:noreply,
       assign(socket,
         configs: configs,
         show_form: Enum.empty?(configs),
         deleting_config_id: nil
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel_delete", _, socket) do
    {:noreply, assign(socket, deleting_config_id: nil, deleting_session_id: nil)}
  end

  @impl true
  def handle_event("edit_name", %{"config-id" => config_id}, socket) do
    config = Learning.get_config!(String.to_integer(config_id))

    {:noreply, assign(socket, editing_config_id: config.id, edit_name: config.name)}
  end

  @impl true
  def handle_event("update_edit_name", %{"value" => value}, socket) do
    {:noreply, assign(socket, edit_name: value)}
  end

  @impl true
  def handle_event("save_name", %{"config-id" => config_id}, socket) do
    config = Learning.get_config!(String.to_integer(config_id))
    {:ok, _} = Learning.update_config(config, %{name: socket.assigns.edit_name})

    # Refresh configs and exit edit mode
    configs = Learning.list_configs()

    {:noreply,
     assign(socket,
       configs: configs,
       editing_config_id: nil,
       edit_name: ""
     )}
  end

  @impl true
  def handle_event("cancel_edit", _, socket) do
    {:noreply, assign(socket, editing_config_id: nil, edit_name: "")}
  end

  @impl true
  def handle_event("toggle_sessions", %{"config-id" => config_id}, socket) do
    config_id = String.to_integer(config_id)

    new_expanded =
      if socket.assigns.expanded_config_id == config_id do
        nil
      else
        config_id
      end

    {:noreply, assign(socket, expanded_config_id: new_expanded)}
  end

  @impl true
  def handle_event("resume_session", %{"session-id" => session_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/chat?session_id=#{session_id}")}
  end

  @impl true
  def handle_event("show_delete_session", %{"session-id" => session_id}, socket) do
    {:noreply, assign(socket, deleting_session_id: String.to_integer(session_id))}
  end

  @impl true
  def handle_event("delete_session", _, socket) do
    if socket.assigns.deleting_session_id do
      session = Learning.get_session!(socket.assigns.deleting_session_id)
      {:ok, _} = Learning.delete_session(session)

      {:noreply, assign(socket, deleting_session_id: nil)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("toggle_theme", _, socket) do
    new_theme = if socket.assigns.theme == "dark", do: "light", else: "dark"

    {:noreply,
     socket
     |> assign(theme: new_theme)
     |> push_event("update-theme", %{theme: new_theme})}
  end

  @impl true
  def handle_event("sync_theme", %{"theme" => theme}, socket) do
    {:noreply, assign(socket, theme: theme)}
  end
end
