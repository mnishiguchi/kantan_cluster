defmodule KantanClusterTest do
  use ExUnit.Case

  alias KantanCluster.NodeConnectorSupervisor

  test "basics" do
    assert :nonode@nohost == Node.self()
    assert :nocookie == Node.get_cookie()
    assert [] == NodeConnectorSupervisor.keys()
    assert 0 == NodeConnectorSupervisor.which_children() |> length()

    :ok =
      KantanCluster.start(
        node: {:longnames, :"node1@127.0.0.1"},
        cookie: :my_secred_cookie,
        connect_to: [:"node2@127.0.0.1", :"node3@127.0.0.1"]
      )

    assert :"node1@127.0.0.1" == Node.self()
    assert :my_secred_cookie == Node.get_cookie()
    assert [:"node2@127.0.0.1", :"node3@127.0.0.1"] == NodeConnectorSupervisor.keys()
    assert 2 == NodeConnectorSupervisor.which_children() |> length()

    :ok = KantanCluster.disconnect(:"node3@127.0.0.1")
    assert [:"node2@127.0.0.1"] == NodeConnectorSupervisor.keys()
    assert 1 == NodeConnectorSupervisor.which_children() |> length()

    {:ok, _pids} = KantanCluster.connect(:"node4@127.0.0.1")
    assert [:"node2@127.0.0.1", :"node4@127.0.0.1"] == NodeConnectorSupervisor.keys()
    assert 2 == NodeConnectorSupervisor.which_children() |> length()

    :ok = KantanCluster.stop()
    assert :nonode@nohost == Node.self()
    assert :nocookie == Node.get_cookie()
    assert [] == NodeConnectorSupervisor.keys()
    assert 0 == NodeConnectorSupervisor.which_children() |> length()
  end
end
