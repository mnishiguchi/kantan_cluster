defmodule KantanCluster do
  @moduledoc File.read!("README.md")
             |> String.split("<!-- MODULEDOC -->")
             |> hd()

  @pubsub_name KantanCluster.PubSub

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
    - [Erlang magic cookie](https://erlang.org/doc/reference_manual/distributed.html#security) to form a cluster
    - default: random cookie
  """

  @type option() ::
          {:name, node}
          | {:sname, node}
          | {:cookie, atom}

  @type topic :: binary
  @type message :: any
  @type node_name :: atom | binary

  ## node

  @doc """
  Starts a node. Configuration
  options can be specified as a keyword argument

      KantanCluster.start(
        name: :"hoge@172.17.0.7",
        cookie: :mycookie
      )

  or in your `config/config.exs`.

      config :kantan_cluster,
        name: :"hoge@172.17.0.7",
        cookie: :mycookie

  """
  @spec start_node([option]) :: :ok
  def start_node(opts \\ []) when is_list(opts) do
    ensure_distribution!(opts)
    validate_hostname_resolution!()
    KantanCluster.Config.get_cookie_option(opts) |> Node.set_cookie()
    :ok
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

  ## pubsub

  def pubsub_name(), do: @pubsub_name

  @doc "See `Phoenix.PubSub.broadcast/4`"
  @spec broadcast(topic, message) :: :ok | {:error, term}
  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(@pubsub_name, topic, message)
  end

  @doc "See `Phoenix.PubSub.broadcast!/4`"
  @spec broadcast!(topic, message) :: :ok
  def broadcast!(topic, message) do
    Phoenix.PubSub.broadcast(@pubsub_name, topic, message)
  end

  @doc "See `Phoenix.PubSub.broadcast_from/5`"
  @spec broadcast_from(pid, topic, message) :: :ok | {:error, term}
  def broadcast_from(from, topic, message) do
    Phoenix.PubSub.broadcast_from(@pubsub_name, from, topic, message)
  end

  @doc "See `Phoenix.PubSub.broadcast_from!/5`"
  @spec broadcast_from!(pid, topic, message) :: :ok
  def broadcast_from!(from, topic, message) do
    Phoenix.PubSub.broadcast_from!(@pubsub_name, from, topic, message)
  end

  @doc "See `Phoenix.PubSub.direct_broadcast/5`"
  @spec direct_broadcast(node_name, topic, message) :: :ok
  def direct_broadcast(node_name, topic, message) do
    Phoenix.PubSub.direct_broadcast(node_name, @pubsub_name, topic, message)
  end

  @doc "See `Phoenix.PubSub.direct_broadcast!/5`"
  @spec direct_broadcast!(node_name, topic, message) :: :ok
  def direct_broadcast!(node_name, topic, message) do
    Phoenix.PubSub.direct_broadcast!(node_name, @pubsub_name, topic, message)
  end

  @doc "See `Phoenix.PubSub.local_broadcast/4`"
  @spec local_broadcast(topic, message) :: :ok
  def local_broadcast(topic, message) do
    Phoenix.PubSub.local_broadcast(@pubsub_name, topic, message)
  end

  @doc "See `Phoenix.PubSub.local_broadcast_from/5`"
  @spec local_broadcast_from(pid, topic, message) :: :ok
  def local_broadcast_from(from, topic, message) do
    Phoenix.PubSub.local_broadcast_from(@pubsub_name, from, topic, message)
  end

  @doc "See `Phoenix.PubSub.node_name/1`"
  @spec node_name :: node_name
  def node_name() do
    Phoenix.PubSub.node_name(@pubsub_name)
  end

  @doc "See `Phoenix.PubSub.subscribe/3`"
  @spec subscribe(topic, keyword) :: :ok | {:error, term}
  def subscribe(topic, opts \\ []) do
    Phoenix.PubSub.subscribe(@pubsub_name, topic, opts)
  end

  @doc "See `Phoenix.PubSub.unsubscribe/2`"
  @spec unsubscribe(topic) :: :ok
  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(@pubsub_name, topic)
  end
end
