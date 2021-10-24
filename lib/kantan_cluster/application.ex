defmodule KantanCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl Application
  def start(_type, _args) do
    KantanCluster.Node.start!()
    KantanCluster.Node.connect_to_other_nodes()

    children = [
      # Starts a worker by calling: KantanCluster.Worker.start_link(arg)
      # {KantanCluster.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KantanCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
