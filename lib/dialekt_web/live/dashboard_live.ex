defmodule DialektWeb.DashboardLive do
  use DialektWeb, :live_view

  alias Dialekt.Learning

  @impl true
  def mount(_params, _session, socket) do
    configs = Learning.list_configs()

    {:ok,
     assign(socket,
       configs: configs,
       show_form: Enum.empty?(configs),
       editing_config_id: nil,
       edit_name: ""
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
  def handle_event("delete_config", %{"config-id" => config_id}, socket) do
    config = Learning.get_config!(String.to_integer(config_id))
    {:ok, _} = Learning.delete_config(config)

    # Refresh the configs list
    configs = Learning.list_configs()

    {:noreply, assign(socket, configs: configs, show_form: Enum.empty?(configs))}
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
end
