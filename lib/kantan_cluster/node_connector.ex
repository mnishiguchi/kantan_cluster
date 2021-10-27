defmodule KantanCluster.NodeConnector do
  @moduledoc false

  # When a server is unneeded, we want to stop it immediately.
  use GenServer, restart: :transient

  require Logger

  @polling_interval_ms :timer.seconds(5)

  ## API

  @doc """
  Connects to a specified node and start monitoring it.
  """
  @spec start_link(node()) :: GenServer.on_start()
  def start_link(connect_to) do
    if Node.self() == :nonode@nohost do
      :ignore
    else
      case whereis(connect_to) do
        nil -> GenServer.start_link(__MODULE__, connect_to, name: via(connect_to))
        pid -> {:ok, pid}
      end
    end
  end

  @doc """
  Disconnects from a specified node and stops monitoring it.
  """
  @spec disconnect(node()) :: :ok
  def disconnect(node_name) do
    Node.disconnect(node_name)
    whereis(node_name) |> GenServer.stop(:normal)
  end

  @spec whereis(node()) :: nil | pid
  def whereis(node_name) when is_atom(node_name) do
    KantanCluster.ProcessRegistry.whereis(node_name)
  end

  defp via(connect_to) when is_atom(connect_to) do
    KantanCluster.ProcessRegistry.via(connect_to)
  end

  ## Callback

  @impl GenServer
  def init(connect_to) do
    connect_node(connect_to)
    send(self(), :tick)

    {:ok, %{connect_to: connect_to}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    if Node.self() == :nonode@nohost do
      # If node is stopped, there is no need for monitoring.
      {:stop, :normal, state}
    else
      # Node.monitor/2 does not trigger :nodedown every now and then. Pinging
      # periodically is more reliable for monitoring connected nodes.
      Process.send_after(self(), :tick, @polling_interval_ms)

      if :pang == Node.ping(state.connect_to) do
        connect_node(state.connect_to)
      end

      {:noreply, state}
    end
  end

  @spec connect_node(node()) :: boolean()
  defp connect_node(connect_to) do
    if connected = Node.connect(connect_to) do
      Logger.info("connected from #{Node.self()} to #{connect_to}")
    else
      Logger.warning("could not connect from #{Node.self()} to #{connect_to}")
    end

    connected
  end
end
