defmodule DialektWeb.DashboardLive do
  use DialektWeb, :live_view

  alias Dialekt.Learning

  @impl true
  def mount(_params, _session, socket) do
    theme = get_connect_params(socket)["theme"] || "light"

    {:ok,
     socket
     |> assign(
       sessions_by_config: %{},
       editing_config_id: nil,
       edit_name: "",
       expanded_config_id: nil,
       deleting_config_id: nil,
       deleting_config_name: nil,
       deleting_session_id: nil,
       theme: theme
     )
     |> assign_dashboard_data()}
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
    config_id = String.to_integer(config_id)
    config = Enum.find(socket.assigns.configs, &(&1.id == config_id))

    {:noreply,
     assign(socket,
       deleting_config_id: config_id,
       deleting_config_name: if(config, do: config.name, else: "this configuration")
     )}
  end

  @impl true
  def handle_event("delete_config", _, socket) do
    if socket.assigns.deleting_config_id do
      config = Learning.get_config!(socket.assigns.deleting_config_id)

      case Learning.delete_config(config) do
        {:ok, _} ->
          {:noreply,
           socket
           |> assign(
             sessions_by_config: %{},
             expanded_config_id: nil,
             deleting_config_id: nil,
             deleting_config_name: nil
           )
           |> assign_dashboard_data()}

        {:error, changeset} ->
          require Logger
          Logger.error("Failed to delete config: #{inspect(changeset)}")
          {:noreply, assign(socket, deleting_config_id: nil, deleting_config_name: nil)}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("cancel_delete", _, socket) do
    {:noreply,
     assign(socket,
       deleting_config_id: nil,
       deleting_config_name: nil,
       deleting_session_id: nil
     )}
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
    name = String.trim(socket.assigns.edit_name)

    if name != "" do
      config = Learning.get_config!(String.to_integer(config_id))
      {:ok, _} = Learning.update_config(config, %{name: name})

      # Refresh configs and exit edit mode
      configs = Learning.list_configs()

      {:noreply,
       assign(socket,
         configs: configs,
         editing_config_id: nil,
         edit_name: ""
       )}
    else
      # Don't save if name is empty, just cancel edit
      {:noreply, assign(socket, editing_config_id: nil, edit_name: "")}
    end
  end

  @impl true
  def handle_event("save_name_with_value", %{"config-id" => config_id, "name" => name}, socket) do
    name = String.trim(name)

    if name != "" do
      config = Learning.get_config!(String.to_integer(config_id))
      {:ok, _} = Learning.update_config(config, %{name: name})

      # Refresh configs and exit edit mode
      configs = Learning.list_configs()

      {:noreply,
       assign(socket,
         configs: configs,
         editing_config_id: nil,
         edit_name: ""
       )}
    else
      # Don't save if name is empty, just cancel edit
      {:noreply, assign(socket, editing_config_id: nil, edit_name: "")}
    end
  end

  @impl true
  def handle_event("cancel_edit", _, socket) do
    {:noreply, assign(socket, editing_config_id: nil, edit_name: "")}
  end

  @impl true
  def handle_event("toggle_sessions", %{"config-id" => config_id}, socket) do
    config_id = String.to_integer(config_id)

    if socket.assigns.expanded_config_id == config_id do
      {:noreply, assign(socket, expanded_config_id: nil)}
    else
      sessions = Learning.list_sessions_for_config(config_id)

      {:noreply,
       assign(socket,
         expanded_config_id: config_id,
         sessions_by_config: Map.put(socket.assigns.sessions_by_config, config_id, sessions)
       )}
    end
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

      case Learning.delete_session(session) do
        {:ok, _} ->
          {:noreply,
           socket
           |> assign(deleting_session_id: nil)
           |> refresh_expanded_sessions()
           |> assign_dashboard_data()}

        {:error, _changeset} ->
          {:noreply, assign(socket, deleting_session_id: nil)}
      end
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

  defp assign_dashboard_data(socket) do
    configs = Learning.list_configs()
    config_ids = Enum.map(configs, & &1.id)

    assign(socket,
      configs: configs,
      session_counts: Learning.session_counts_by_config(config_ids),
      mistake_counts: Learning.active_mistake_counts_by_config(config_ids),
      show_form: Enum.empty?(configs)
    )
  end

  defp refresh_expanded_sessions(%{assigns: %{expanded_config_id: nil}} = socket) do
    socket
  end

  defp refresh_expanded_sessions(socket) do
    config_id = socket.assigns.expanded_config_id
    sessions = Learning.list_sessions_for_config(config_id)

    assign(
      socket,
      sessions_by_config: Map.put(socket.assigns.sessions_by_config, config_id, sessions)
    )
  end
end
