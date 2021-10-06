defmodule EasyCluster.Config do
  @moduledoc false

  @doc """
  Parses and validates the ip from env.
  """
  def get_ip_from_env!(env_key) do
    if ip = System.get_env(env_key) do
      get_ip_from_env!(env_key, ip)
    end
  end

  def get_ip_from_env!(env_key, ip) do
    case ip |> String.to_charlist() |> :inet.parse_address() do
      {:ok, ip} ->
        ip

      {:error, :einval} ->
        abort!("expected #{env_key} to be a valid ipv4 or ipv6 address, got: #{ip}")
    end
  end

  @doc """
  Parses the cookie from env.
  """
  def get_cookie_from_env(env_key) do
    if cookie = System.get_env(env_key) do
      String.to_atom(cookie)
    end
  end

  @spec longnames_mode? :: boolean
  def longnames_mode?, do: EasyCluster.Utils.node_host() =~ "."

  @spec shortnames_mode? :: boolean
  def shortnames_mode?, do: !longnames_mode?()

  @doc """
  Aborts booting due to a configuration error.
  """
  @spec abort!(String.t()) :: no_return()
  def abort!(message) do
    IO.puts("\nERROR!!! [EasyCluster] " <> message)
    System.halt(1)
  end
end
