defmodule KantanCluster do
  @moduledoc """
  Form a simple Erlang cluster easily in Elixir.
  """

  @typedoc """
  A node type.
  See https://hexdocs.pm/elixir/1.12/Node.html#start/3
  """
  @type node_type :: :longnames | :shortnames

  @typedoc """
  Options for a cluster.

  * `:node` - the name of a node that we want to start (default: `{:longnames, :"xxxx@127.0.0.1"}` where `xxxx` is a random string)
  * `:cookie` - [Erlang magic cookie] to form a cluster (default: random cookie)
  * `:connect_to` - a list of nodes we want our node to be connected with (default: `[]`)

  """
  @type option() ::
          {:node, {node_type(), node()}}
          | {:cookie, atom()}
          | {:connect_to, node() | [node()]}

  @doc """
  Starts a node and attempts to connect it to specified nodes. Configuration
  options can be specified as an argument

      KantanCluster.start(
        node: {:longnames, :"node1@127.0.0.1"},
        cookie: :hello,
        connect_to: [:"nerves@nerves-mn00.local"]
      )

  or in your `config/config.exs`.

      config :kantan_cluster,
        node: {:longnames, :"node1@127.0.0.1"},
        cookie: :hello,
        connect_to: [:"nerves@nerves-mn00.local"]

  """
  @spec start([option()]) :: GenServer.on_start() | [GenServer.on_start()]
  def start(opts \\ []) when is_list(opts) do
    ensure_distribution!(opts)
    validate_hostname_resolution!()
    set_cookie(opts)
    KantanCluster.Config.get_connect_to_option(opts) |> connect()
  end

  @doc """
  Stops a node.
  """
  def stop() do
    # KantanCluster.NodeConnector will be stopped when node gets stopped.
    Node.stop()
  end

  @doc """
  Connects current node to specified nodes.
  """
  @spec connect(node() | [node()]) :: GenServer.on_start() | [GenServer.on_start()]
  def connect(connect_to) when is_atom(connect_to) do
    KantanCluster.NodeConnectorSupervisor.find_or_start_child_process(connect_to)
  end

  def connect(connect_to) when is_list(connect_to) do
    connect_to |> Enum.map(&KantanCluster.NodeConnectorSupervisor.find_or_start_child_process/1)
  end

  @doc """
  Disconnects current node from speficied nodes.
  """
  @spec disconnect(node() | [node()]) :: :ok
  def disconnect(node_name) when is_atom(node_name) do
    KantanCluster.NodeConnector.disconnect(node_name)
  end

  def disconnect(node_names) when is_list(node_names) do
    node_names |> Enum.each(&KantanCluster.NodeConnector.disconnect/1)
    :ok
  end

  @spec ensure_distribution!(keyword()) :: :ok
  defp ensure_distribution!(opts) do
    unless Node.alive?() do
      case System.cmd("epmd", ["-daemon"]) do
        {_, 0} -> :ok
        _ -> raise("could not start epmd (Erlang Port Mapper Driver).")
      end

      {type, name} = KantanCluster.Config.get_node_option(opts)

      case Node.start(name, type) do
        {:ok, _} -> :ok
        {:error, reason} -> raise("could not start distributed node: #{inspect(reason)}")
      end
    end
  end

  import Record
  defrecordp :hostent, Record.extract(:hostent, from_lib: "kernel/include/inet.hrl")

  defp validate_hostname_resolution!() do
    validate_hostname_resolution!(KantanCluster.Utils.shortnames_mode?())
  end

  defp validate_hostname_resolution!(_shortnames_mode = true) do
    hostname = KantanCluster.Utils.node_hostname() |> to_charlist()

    case :inet.gethostbyname(hostname) do
      {:error, :nxdomain} ->
        invalid_hostname!("your hostname \"#{hostname}\" does not resolve to an IP address")

      {:ok, hostent(h_addrtype: :inet, h_addr_list: addresses)} ->
        any_loopback? = Enum.any?(addresses, &match?({127, _, _, _}, &1))

        unless any_loopback? do
          invalid_hostname!(
            "your hostname \"#{hostname}\" does not resolve to a loopback address (127.0.0.0/8)"
          )
        end

      _ ->
        :ok
    end
  end

  defp validate_hostname_resolution!(_), do: :ok

  @spec invalid_hostname!(binary()) :: no_return()
  defp invalid_hostname!(prelude) do
    raise("""
    #{prelude}, which indicates something wrong in your OS configuration.

    Make sure your computer's name resolves locally or start KantanCluster using a long distribution name.
    """)
  end

  @spec set_cookie(keyword()) :: true
  defp set_cookie(opts) do
    KantanCluster.Config.get_cookie_option(opts) |> Node.set_cookie()
  end
end
