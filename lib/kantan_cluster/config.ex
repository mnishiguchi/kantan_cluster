defmodule KantanCluster.Config do
  @moduledoc false

  def get_node_option(opts) do
    [
      Keyword.take(opts, [:name]),
      Keyword.take(opts, [:sname]),
      Keyword.take(Application.get_all_env(:kantan_cluster), [:name]),
      Keyword.take(Application.get_all_env(:kantan_cluster), [:sname])
    ]
    |> List.flatten()
    |> List.first()
    |> valid_node_option()
  end

  defp valid_node_option(nil), do: {:shortnames, :"n_#{KantanCluster.Utils.random_short_id()}"}
  defp valid_node_option({:name, name}), do: {:longnames, name}
  defp valid_node_option({:sname, name}), do: {:shortnames, name}
  defp valid_node_option(invalid), do: raise("Invalid node option #{inspect(invalid)}")

  def get_cookie_option(opts, default \\ KantanCluster.Utils.random_cookie()) do
    opts[:cookie] || Application.get_env(:kantan_cluster, :cookie) || default
  end

  def get_connect_to_option(opts, default \\ []) do
    opts[:connect_to] || Application.get_env(:kantan_cluster, :connect_to) || default
  end
end
