defmodule KantanCluster do
  @moduledoc """
  Form a simple Erlang cluster easily in Elixir.
  """

  require Logger

  @typedoc """
  A node type. See `Node.start/3`.
  """
  @type node_type :: :longnames | :shortnames

  @typedoc """
  Options for a cluster.

  * `:node`
    - the name of a node that you want to start
    - default: `{:longnames, :"xxxx@yyyy.local"}` where `xxxx` is a random string, `yyyy` is the hostname of a machine
    - examples:
      - `"node1"`
      - `{:longnames, :"node1@nerves-mn00.local"`}
      - `{:shortnames, :"node1@nerves-mn00"`}
  * `:cookie`
    - [Erlang magic cookie] to form a cluster
    - default: random cookie
  * `:connect_to`
    - a list of nodes we want our node to be connected with
    - default: `[]`

  [Erlang magic cookie]: https://erlang.org/doc/reference_manual/distributed.html#security
  """
  @type option() ::
          {:node, binary | {node_type, node}}
          | {:cookie, atom}
          | {:connect_to, node | [node]}

  @doc """
  Starts a node and attempts to connect it to specified nodes. Configuration
  options can be specified as an argument

      KantanCluster.start(
        node: "node1",
        cookie: :hello,
        connect_to: [:"nerves@nerves-mn00.local"]
      )

  or in your `config/config.exs`.

      config :kantan_cluster,
        node: "node1",
        cookie: :hello,
        connect_to: [:"nerves@nerves-mn00.local"]

  """
  @spec start([option]) :: :ok
  def start(opts \\ []) when is_list(opts) do
    ensure_distribution!(opts)
    validate_hostname_resolution!()
    set_cookie(opts)
    KantanCluster.Config.get_connect_to_option(opts) |> connect()
    :ok
  end

  @doc """
  Stops a node and all the connections.
  """
  @spec stop :: :ok | {:error, :not_allowed | :not_found}
  def stop() do
    KantanCluster.NodeConnectorSupervisor.terminate_children()
    Node.stop()
  end

  @doc """
  Connects current node to specified nodes.
  """
  @spec connect(node | [node]) :: {:ok, [pid]}
  def connect(connect_to) when is_atom(connect_to), do: connect([connect_to])

  def connect(connect_to) when is_list(connect_to) do
    pids =
      connect_to
      |> Enum.map(&KantanCluster.NodeConnectorSupervisor.find_or_start_child_process/1)

    {:ok, pids}
  end

  @doc """
  Disconnects current node from speficied nodes.
  """
  @spec disconnect(node | [node]) :: :ok
  def disconnect(node_name) when is_atom(node_name), do: disconnect([node_name])

  def disconnect(node_names) when is_list(node_names) do
    :ok = node_names |> Enum.each(&KantanCluster.NodeConnector.disconnect/1)
  end

  @spec ensure_distribution!(keyword) :: :ok
  defp ensure_distribution!(opts) do
    if Node.alive?() do
      Logger.info("distributed node already started: #{Node.self()}")
    else
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
    KantanCluster.Utils.node_hostname()
    |> KantanCluster.Utils.shortnames_mode?()
    |> validate_hostname_resolution!()
  end

  defp validate_hostname_resolution!(true = _shortnames_mode) do
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

  defp validate_hostname_resolution!(false = _shortnames_mode), do: :ok

  @spec invalid_hostname!(binary) :: no_return
  defp invalid_hostname!(prelude) do
    raise("""
    #{prelude}, which indicates something wrong in your OS configuration.

    Make sure your computer's name resolves locally or start KantanCluster using a long distribution name.
    """)
  end

  @spec set_cookie(keyword) :: true
  defp set_cookie(opts) do
    KantanCluster.Config.get_cookie_option(opts) |> Node.set_cookie()
  end
end
