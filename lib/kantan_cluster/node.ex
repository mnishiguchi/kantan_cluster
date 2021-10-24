defmodule KantanCluster.Node do
  @moduledoc false

  # The basic structure here is adopted from Livebook.
  # See https://github.com/livebook-dev/livebook/blob/da8b55b9d1825c279914e85f75e8307e74e3e547/lib/livebook/application.ex

  @spec start! :: :ok | no_return()
  def start!() do
    ensure_distribution!()
    validate_hostname_resolution!()
    set_cookie()
    :ok
  end

  @spec connect_to_other_nodes() :: :ok
  def connect_to_other_nodes() do
    Application.get_env(:kantan_cluster, :connect_to, [])
    |> Enum.each(fn other_node ->
      {:ok, _pid} = KantanCluster.NodeConnector.start_link(node: other_node)
    end)
  end

  @spec connected?(node()) :: boolean
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
  def longnames_mode?, do: KantanCluster.Node.hostname() =~ "."

  @spec shortnames_mode? :: boolean
  def shortnames_mode?, do: !longnames_mode?()

  defp ensure_distribution!() do
    unless Node.alive?() do
      case System.cmd("epmd", ["-daemon"]) do
        {_, 0} ->
          :ok

        _ ->
          KantanCluster.Config.abort!("""
          could not start epmd (Erlang Port Mapper Driver). KantanCluster uses epmd to \
          talk to different runtimes.
          """)
      end

      {type, name} = get_node_type_and_name()

      case Node.start(name, type) do
        {:ok, _} ->
          :ok

        {:error, reason} ->
          KantanCluster.Config.abort!("could not start distributed node: #{inspect(reason)}")
      end
    end
  end

  import Record
  defrecordp :hostent, Record.extract(:hostent, from_lib: "kernel/include/inet.hrl")

  defp validate_hostname_resolution!() do
    validate_hostname_resolution!(KantanCluster.Node.shortnames_mode?())
  end

  defp validate_hostname_resolution!(_shortnames_mode = true) do
    hostname = KantanCluster.Node.hostname() |> to_charlist()

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

  defp validate_hostname_resolution!(_shortnames_mode = false), do: :ok

  @spec invalid_hostname!(binary()) :: no_return()
  def invalid_hostname!(prelude) do
    KantanCluster.Config.abort!("""
    #{prelude}, which indicates something wrong in your OS configuration.

    Make sure your computer's name resolves locally or start KantanCluster using a long distribution name.
    """)
  end

  @spec set_cookie :: true
  def set_cookie() do
    cookie = Application.get_env(:kantan_cluster, :cookie, KantanCluster.Utils.random_cookie())
    Node.set_cookie(cookie)
  end

  defp get_node_type_and_name() do
    case Application.get_env(:kantan_cluster, :node) do
      nil ->
        {:longnames, :"#{random_short_name()}@127.0.0.1"}

      {type, name} when type in [:shortnames, :longnames] and is_atom(name) ->
        {type, name}
    end
  end

  defp random_short_name() do
    :"kantan_cluster_#{KantanCluster.Utils.random_short_id()}"
  end
end
