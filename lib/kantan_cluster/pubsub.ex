defmodule KantanCluster.PubSub do
  @moduledoc """
  A thin wrapper around `Phoenix.PubSub`.
  """

  @spec subscribe(Phoenix.PubSub.topic()) :: :ok | {:error, any}
  def subscribe(topic) do
    Phoenix.PubSub.subscribe(__MODULE__, topic)
  end

  @spec unsubscribe(Phoenix.PubSub.topic()) :: :ok
  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(__MODULE__, topic)
  end

  @spec broadcast(Phoenix.PubSub.topic(), Phoenix.PubSub.message()) :: :ok | {:error, any}
  def broadcast(topic, message) do
    Phoenix.PubSub.broadcast(__MODULE__, topic, message)
  end
end
