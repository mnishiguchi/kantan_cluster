defmodule KantanCluster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @default_topology [
    strategy: Cluster.Strategy.Gossip,
    secret: "kantan_cluster_secret"
  ]

  @impl Application
  def start(_type, _args) do
    # See https://hexdocs.pm/libcluster/readme.html
    # for available topology settings
    topologies =
      Application.get_env(:kantan_cluster, :topologies) ||
        [kantan_cluster_default: @default_topology]

    children = [
      {Cluster.Supervisor, [topologies, [name: KantanCluster.ClusterSupervisor]]},
      {Phoenix.PubSub, name: KantanCluster.pubsub_name()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KantanCluster.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
