defmodule KantanCluster.NodeConnector do
  @moduledoc false

  use GenServer
  require Logger

  @polling_interval_ms :timer.seconds(5)

  ## API

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts) do
    node = Keyword.fetch!(opts, :node)

    case whereis(node) do
      nil -> GenServer.start_link(__MODULE__, %{node: node}, name: {:global, server_name(node)})
      pid -> {:ok, pid}
    end
  end

  @spec whereis(atom) :: nil | pid
  def whereis(node) when is_atom(node) do
    case server_name(node) |> :global.whereis_name() do
      :undefined -> nil
      pid -> pid
    end
  end

  defp server_name(node) when is_atom(node) do
    {__MODULE__, node}
  end

  ## Callback

  @impl GenServer
  def init(%{node: other_node}) do
    connected = connect_node(other_node)
    Node.monitor(other_node, true)
    send(self(), :tick)

    {:ok, %{node: other_node, connected: connected}}
  end

  @impl GenServer
  def handle_info({:nodedown, node}, state) do
    Logger.warning("#{node} is down")

    {:noreply, %{state | connected: false}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    Process.send_after(self(), :tick, @polling_interval_ms)

    if state.connected do
      {:noreply, state}
    else
      {:noreply, %{state | connected: connect_node(state.node)}}
    end
  end

  @spec connect_node(node()) :: boolean()
  defp connect_node(other_node) do
    if connected = Node.connect(other_node) do
      Logger.info("connected from #{Node.self()} to #{other_node}")
    else
      Logger.warning("could not connect from #{Node.self()} to #{other_node}")
    end

    connected
  end
end
