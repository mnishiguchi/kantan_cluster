defmodule KantanCluster.Utils do
  @moduledoc false

  # random_* functions are adopted from LiveBook.
  # See https://github.com/livebook-dev/livebook/blob/da8b55b9d1825c279914e85f75e8307e74e3e547/lib/livebook/utils.ex

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
  Parses the cookie from env.
  """
  def get_cookie_from_env(env_key) do
    if cookie = System.get_env(env_key) do
      String.to_atom(cookie)
    end
  end

  @doc """
  Aborts booting due to a configuration error.
  """
  @spec abort!(String.t()) :: no_return()
  def abort!(message) do
    IO.puts("\nERROR!!! [KantanCluster] " <> message)
    System.halt(1)
  end
end
