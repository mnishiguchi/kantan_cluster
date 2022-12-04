defmodule KantanCluster do
  @moduledoc """
  Form a simple Erlang cluster easily in Elixir.
  """

  require Logger

  @typedoc """
  Options for a cluster.

  * `:name`
    - the fully-qualified name of a node that you want to start
    - examples:
      - `:"node1@172.17.0.8"`
  * `:sname`
    - the short name of a node that you want to start
    - examples:
      - `:node1`
      - `:"node1@localhost"`
  * `:cookie`
    - [Erlang magic cookie] to form a cluster
    - default: random cookie
  * `:connect_to`
    - a list of nodes we want your node to be connected with
    - default: `[]`

  [Erlang magic cookie]: https://erlang.org/doc/reference_manual/distributed.html#security
  """
  @type option() ::
          {:name, node}
          | {:sname, node}
          | {:cookie, atom}
          | {:connect_to, node | [node]}

  @doc """
  Starts a node and attempts to connect it to specified nodes. Configuration
  options can be specified as an argument

      KantanCluster.start(
        name: :"hoge@172.17.0.7",
        cookie: :mycookie,
        connect_to: [:"piyo@172.17.0.8"]
      )

  or in your `config/config.exs`.

      config :kantan_cluster,
        name: :"hoge@172.17.0.7",
        cookie: :mycookie,
        connect_to: [:"piyo@172.17.0.8"]

  """
  @spec start([option]) :: :ok
  def start(opts \\ []) when is_list(opts) do
    ensure_distribution!(opts)
    validate_hostname_resolution!()
    KantanCluster.Config.get_cookie_option(opts) |> Node.set_cookie()
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
      Enum.map(connect_to, &KantanCluster.NodeConnectorSupervisor.find_or_start_child_process/1)

    {:ok, pids}
  end

  @doc """
  Disconnects current node from speficied nodes.
  """
  @spec disconnect(node | [node]) :: :ok
  def disconnect(node_name) when is_atom(node_name), do: disconnect([node_name])

  def disconnect(node_names) when is_list(node_names) do
    :ok = Enum.each(node_names, &KantanCluster.NodeConnector.disconnect/1)
  end

  @doc """
  Subscribes the caller to a given topic.

  * topic - The topic to subscribe to, for example: "users:123"
  """
  @spec subscribe(binary) :: :ok | {:error, any}
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(KantanCluster.PubSub, topic)
  end

  @doc """
  Unsubscribes the caller from a given topic.
  """
  @spec unsubscribe(binary) :: :ok
  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(KantanCluster.PubSub, topic)
  end

  @doc """
  Broadcasts message on a given topic across the whole cluster.

  * topic - The topic to broadcast to, ie: "users:123"
  * message - The payload of the broadcast
  """
  @spec broadcast(binary, any) :: :ok | {:error, any}
  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(KantanCluster.PubSub, topic, message)
  end

  @spec ensure_distribution!(keyword) :: :ok
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
end
