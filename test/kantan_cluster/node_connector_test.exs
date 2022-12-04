defmodule KantanCluster.NodeConnectorTest do
  use ExUnit.Case

  alias KantanCluster.NodeConnector

  setup do
    on_exit(fn -> Node.stop() end)
  end

  describe "start_link/1" do
    test "ignore when node is not started" do
      assert :nonode@nohost == Node.self()
      assert :ignore == NodeConnector.start_link(:"node@127.0.0.1")
    end

    test "unique pid per node" do
      Node.start(:"node@127.0.0.1")
      assert {:ok, pid} = NodeConnector.start_link(:"node@127.0.0.1")
      assert {:ok, ^pid} = NodeConnector.start_link(:"node@127.0.0.1")
    end
  end
end
