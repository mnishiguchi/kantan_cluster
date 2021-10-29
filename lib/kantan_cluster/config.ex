defmodule KantanCluster.Config do
  @moduledoc false

  def get_node_option(opts) do
    (opts[:node] || Application.get_env(:kantan_cluster, :node))
    |> parse_node_option()
  end

  # when node option is explicit
  defp parse_node_option({:longnames, _} = node_opt), do: node_opt
  defp parse_node_option({:shortnames, _} = node_opt), do: node_opt

  # when node option is inplicit
  defp parse_node_option(nil) do
    {:ok, hostname} = :inet.gethostname()
    {:longnames, :"n_#{KantanCluster.Utils.random_short_id()}@#{hostname}.local"}
  end

  defp parse_node_option(node_opt) when is_binary(node_opt) do
    {:ok, hostname} = :inet.gethostname()
    {:longnames, :"#{node_opt}@#{hostname}.local"}
  end

  def get_cookie_option(opts) do
    opts[:cookie] ||
      Application.get_env(:kantan_cluster, :cookie) ||
      KantanCluster.Utils.random_cookie()
  end

  def get_connect_to_option(opts) do
    opts[:connect_to] ||
      Application.get_env(:kantan_cluster, :connect_to) ||
      []
  end
end
