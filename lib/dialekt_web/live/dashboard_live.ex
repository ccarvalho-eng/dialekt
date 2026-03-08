defmodule DialektWeb.DashboardLive do
  use DialektWeb, :live_view

  alias Dialekt.Learning

  @impl true
  def mount(_params, _session, socket) do
    configs = Learning.list_configs()

    {:ok, assign(socket, configs: configs, show_form: Enum.empty?(configs))}
  end
end
