defmodule KantanCluster.NodeConnector do
  @moduledoc false

  use GenServer
  require Logger

  @polling_interval_ms :timer.seconds(5)

  ## API

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts) do
    connect_to = Keyword.fetch!(opts, :connect_to)

    case whereis(connect_to) do
      nil ->
        Singleton.start_child(__MODULE__, %{connect_to: connect_to}, server_name(connect_to))

      pid ->
        {:ok, pid}
    end
  end

  @spec whereis(atom) :: nil | pid
  def whereis(connect_to) when is_atom(connect_to) do
    case server_name(connect_to) |> :global.whereis_name() do
      :undefined -> nil
      pid -> pid
    end
  end

  defp server_name(connect_to) when is_atom(connect_to) do
    {__MODULE__, connect_to}
  end

  ## Callback

  @impl GenServer
  def init(%{connect_to: connect_to}) do
    connect_node(connect_to)
    send(self(), :tick)

    {:ok, %{connect_to: connect_to}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    # Node.monitor/2 does not trigger :nodedown every now and then. Pinging periodically is more
    # reliable for monitoring connected nodes.
    Process.send_after(self(), :tick, @polling_interval_ms)

    if :pang == Node.ping(state.connect_to) do
      connect_node(state.connect_to)
    end

    {:noreply, state}
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
