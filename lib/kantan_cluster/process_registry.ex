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

  @spec start_link() :: {:error, any} | {:ok, pid}
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  @doc """
  Returns a via tuple for accessing a process that is held in this registry.

  ## Examples

      iex> KantanCluster.ProcessRegistry.via(:"nerves@nerves-mn00.local")
      {:via, Registry, {KantanCluster.ProcessRegistry, :"nerves@nerves-mn00.local"}}

  """
  @spec via(key) :: {:via, Registry, {KantanCluster.ProcessRegistry, key}}
  def via(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  @doc """
  Finds a process id for a given key.
  """
  @spec whereis(key) :: pid | nil
  def whereis(key) do
    case Registry.whereis_name({__MODULE__, key}) do
      :undefined -> nil
      pid -> pid
    end
  end

  @doc """
  Finds a key for a given process.
  """
  @spec key(pid) :: key
  def key(pid) do
    Registry.keys(__MODULE__, pid) |> hd()
  end
end
