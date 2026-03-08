defmodule DialektWeb.DashboardLive do
  use DialektWeb, :live_view

  alias Dialekt.Learning

  @impl true
  def mount(_params, _session, socket) do
    configs = Learning.list_configs()

    {:ok, assign(socket, configs: configs, show_form: Enum.empty?(configs))}
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
end
