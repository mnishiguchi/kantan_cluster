defmodule EasyCluster.Utils do
  @moduledoc false

  # Many functions here are adopted from [LiveBook].
  # [LiveBook]: https://github.com/livebook-dev/livebook/blob/da8b55b9d1825c279914e85f75e8307e74e3e547/lib/livebook/utils.ex

  @type id :: binary()

  @doc """
  Generates a random binary id.
  """
  @spec random_id() :: id()
  def random_id() do
    :crypto.strong_rand_bytes(20) |> Base.encode32(case: :lower)
  end

  @doc """
  Generates a random short binary id.
  """
  @spec random_short_id() :: id()
  def random_short_id() do
    :crypto.strong_rand_bytes(5) |> Base.encode32(case: :lower)
  end

  @doc """
  Generates a random cookie for a distributed node.
  """
  @spec random_cookie() :: atom()
  def random_cookie() do
    :"c_#{Base.url_encode64(:crypto.strong_rand_bytes(39))}"
  end

  @doc """
  Returns the host part of a node.
  """
  @spec node_host() :: binary()
  def node_host() do
    [_name, host] = node() |> Atom.to_string() |> :binary.split("@")
    host
  end
end
