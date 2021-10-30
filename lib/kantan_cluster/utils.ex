defmodule KantanCluster.Utils do
  @moduledoc false

  # random_* functions are adopted from LiveBook.
  # See https://github.com/livebook-dev/livebook/blob/da8b55b9d1825c279914e85f75e8307e74e3e547/lib/livebook/utils.ex

  @doc """
  Generates a random short binary id.
  """
  @spec random_short_id :: binary
  def random_short_id() do
    :crypto.strong_rand_bytes(5) |> Base.encode32(case: :lower)
  end

  @doc """
  Generates a random cookie for a distributed node.
  """
  @spec random_cookie :: atom
  def random_cookie() do
    :"c_#{Base.url_encode64(:crypto.strong_rand_bytes(39))}"
  end

  @spec node_hostname :: binary
  def node_hostname() do
    [_name, host] = node() |> Atom.to_string() |> :binary.split("@")
    host
  end

  @spec longnames_mode?(binary) :: boolean
  def longnames_mode?(name) when is_binary(name), do: name =~ "."

  @spec longnames_mode? :: boolean
  def longnames_mode?(), do: longnames_mode?(node_hostname())

  @spec shortnames_mode?(binary) :: boolean
  def shortnames_mode?(name) when is_binary(name), do: !longnames_mode?(name)

  @spec shortnames_mode? :: boolean
  def shortnames_mode?(), do: !longnames_mode?(node_hostname())
end
