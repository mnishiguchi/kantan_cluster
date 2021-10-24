defmodule EasyCluster.Node do
  @moduledoc false

  require Logger

  # The basic structure here is adopted from Livebook.
  # See https://github.com/livebook-dev/livebook/blob/da8b55b9d1825c279914e85f75e8307e74e3e547/lib/livebook/application.ex

  def start!() do
    ensure_distribution!()
    validate_hostname_resolution!()
    set_cookie()
  end

  def connect_to_other_nodes() do
    nodes_to_connect = Application.get_env(:easy_cluster, :connect_to, []) -- Node.list()

    Enum.each(nodes_to_connect, fn other_node ->
      {:ok, _pid} = EasyCluster.NodeConnector.start_link(node: other_node)
    end)
  end

  def connected?(node) do
    case Node.ping(node) do
      :pong -> true
      _ -> false
    end
  end

  @doc """
  Returns the host part of a node.
  """
  @spec hostname() :: binary()
  def hostname() do
    [_name, host] = node() |> Atom.to_string() |> :binary.split("@")
    host
  end

  @spec longnames_mode? :: boolean
  def longnames_mode?, do: EasyCluster.Node.hostname() =~ "."

  @spec shortnames_mode? :: boolean
  def shortnames_mode?, do: !longnames_mode?()

  defp ensure_distribution!() do
    unless Node.alive?() do
      case System.cmd("epmd", ["-daemon"]) do
        {_, 0} ->
          :ok

        _ ->
          EasyCluster.Config.abort!("""
          could not start epmd (Erlang Port Mapper Driver). EasyCluster uses epmd to \
          talk to different runtimes.
          """)
      end

      {type, name} = get_node_type_and_name()

      case Node.start(name, type) do
        {:ok, _} ->
          :ok

        {:error, reason} ->
          EasyCluster.Config.abort!("could not start distributed node: #{inspect(reason)}")
      end
    end
  end

  import Record
  defrecordp :hostent, Record.extract(:hostent, from_lib: "kernel/include/inet.hrl")

  defp validate_hostname_resolution!() do
    if EasyCluster.Node.shortnames_mode?() do
      hostname = EasyCluster.Node.hostname() |> to_charlist()

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
  end

  defp invalid_hostname!(prelude) do
    EasyCluster.Config.abort!("""
    #{prelude}, which indicates something wrong in your OS configuration.

    Make sure your computer's name resolves locally or start EasyCluster using a long distribution name.
    """)
  end

  def set_cookie() do
    cookie = Application.get_env(:easy_cluster, :cookie, EasyCluster.Utils.random_cookie())
    Node.set_cookie(cookie)
  end

  defp get_node_type_and_name() do
    case Application.get_env(:easy_cluster, :node) do
      nil ->
        {:longnames, :"#{random_short_name()}@127.0.0.1"}

      {type, name} when type in [:shortnames, :longnames] and is_atom(name) ->
        {type, name}
    end
  end

  defp random_short_name() do
    :"easy_cluster_#{EasyCluster.Utils.random_short_id()}"
  end
end
