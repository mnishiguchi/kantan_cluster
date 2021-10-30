defmodule KantanCluster.PubSub do
  @moduledoc false

  @spec subscribe(binary) :: :ok | {:error, any}
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(__MODULE__, topic)
  end

  @spec unsubscribe(binary) :: :ok
  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(__MODULE__, topic)
  end

  @spec broadcast(binary, any) :: :ok | {:error, any}
  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(__MODULE__, topic, message)
  end
end
