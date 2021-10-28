defmodule KantanCluster.NodeConnectorSupervisor do
  @moduledoc false

  use DynamicSupervisor

  ## API

  @doc """
  Starts a supervisor for `NodeConnector` servers.
  """
  @spec start_link(any) :: {:error, any} | {:ok, pid}
  def start_link(_init_arg) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Finds or creates a child process for a specified node name.
  """
  @spec find_or_start_child_process(node) :: pid | nil
  def find_or_start_child_process(node_name) do
    existing_process(node_name) || new_process(node_name)
  end

  @doc """
  Lists all the children.
  """
  @spec which_children() ::
          [{any, :restarting | :undefined | pid, :supervisor | :worker, :dynamic | [atom]}]
  def which_children() do
    # ID is always `:undefined` but it is normal behavior for Dynamic Supervisor.
    Supervisor.which_children(__MODULE__)
  end

  @doc """
  Lists the registry keys of all the children.
  """
  @spec keys :: [node]
  def keys() do
    which_children()
    |> Enum.map(fn {_, pid, _, _} ->
      KantanCluster.ProcessRegistry.key(pid)
    end)
  end

  @spec existing_process(node) :: pid | nil
  defp existing_process(node_name) do
    KantanCluster.NodeConnector.whereis(node_name)
  end

  @spec new_process(node) :: pid | :ignore | {:error, :max_children | any}
  defp new_process(node_name) do
    case start_child(node_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
      other -> other
    end
  end

  @spec start_child(node) :: DynamicSupervisor.on_start_child()
  defp start_child(connect_to) do
    DynamicSupervisor.start_child(__MODULE__, {KantanCluster.NodeConnector, connect_to})
  end

  ## Callback

  @impl DynamicSupervisor
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
