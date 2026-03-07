defmodule DialektWeb.ChatLive do
  use DialektWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     assign(socket,
       native_code: params["native"],
       target_code: params["target"],
       level_code: params["level"],
       register_code: params["register"]
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-4">
      <h1 class="text-2xl">Chat View - Coming Soon</h1>
      <p>Native: {@native_code}</p>
      <p>Target: {@target_code}</p>
      <p>Level: {@level_code}</p>
      <p>Register: {@register_code}</p>
    </div>
    """
  end
end
