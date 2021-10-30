defmodule KantanCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      KantanCluster.ProcessRegistry,
      KantanCluster.NodeConnectorSupervisor,
      {Phoenix.PubSub, name: KantanCluster.PubSub}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KantanCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
