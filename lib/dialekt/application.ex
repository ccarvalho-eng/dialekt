defmodule Dialekt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DialektWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:dialekt, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Dialekt.PubSub},
      # Start a worker by calling: Dialekt.Worker.start_link(arg)
      # {Dialekt.Worker, arg},
      # Start to serve requests, typically the last entry
      DialektWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dialekt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DialektWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
