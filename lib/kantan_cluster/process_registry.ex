defmodule KantanCluster.ProcessRegistry do
  @moduledoc false

  @type key :: any

  @spec child_spec(any) :: Supervisor.child_spec()
  def child_spec(_args) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @doc """
  Returns a via tuple for accessing a process that is held in this registry.

  ## Examples

      iex> ProcessRegistry.via(:"nerves@nerves-mn00.local")
      {:via, Registry, {KantanCluster.ProcessRegistry, :"nerves@nerves-mn00.local"}}

  """
  @spec via(key) :: {:via, Registry, {KantanCluster.ProcessRegistry, binary}}
  def via(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  @spec whereis(key) :: pid | nil
  def whereis(key) do
    case Registry.whereis_name({__MODULE__, key}) do
      :undefined -> nil
      pid -> pid
    end
  end

  @spec keys(pid) :: [key]
  def keys(pid) do
    Registry.keys(__MODULE__, pid)
  end
end
