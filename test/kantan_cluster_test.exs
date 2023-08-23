defmodule KantanClusterTest do
  use ExUnit.Case

  test "start_node/1" do
    assert Node.self() == :nonode@nohost
    assert Node.get_cookie() == :nocookie

    :ok =
      KantanCluster.start_node(
        name: :"node1@127.0.0.1",
        cookie: :super_secure_cookie
      )

    assert Node.self() == :"node1@127.0.0.1"
    assert Node.get_cookie() == :super_secure_cookie
  end
end
