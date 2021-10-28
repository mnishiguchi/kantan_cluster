defmodule KantanCluster.Config do
  @moduledoc false

  def get_node_option(opts) do
    {:ok, hostname} = :inet.gethostname()

    opts[:node] ||
      Application.get_env(:kantan_cluster, :node) ||
      {:longnames, :"n_#{KantanCluster.Utils.random_short_id()}@#{hostname}.local"}
  end

  def get_cookie_option(opts) do
    opts[:cookie] ||
      Application.get_env(:kantan_cluster, :cookie) ||
      KantanCluster.Utils.get_cookie_from_env("COOKIE") ||
      KantanCluster.Utils.random_cookie()
  end

  def get_connect_to_option(opts) do
    opts[:connect_to] ||
      Application.get_env(:kantan_cluster, :connect_to) ||
      []
  end
end
