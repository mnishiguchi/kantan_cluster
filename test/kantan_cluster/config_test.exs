defmodule KantanCluster.ConfigTest do
  use ExUnit.Case

  import KantanCluster.Config

  describe "get_node_option/1" do
    test "in longnames mode" do
      opts = [name: :"node1@127.0.0.1"]
      assert {:longnames, :"node1@127.0.0.1"} == get_node_option(opts)
    end

    test "in shortnames mode" do
      opts = [sname: :"node2@my-machine"]
      assert {:shortnames, :"node2@my-machine"} == get_node_option(opts)
    end

    test "when no name is provided, generates random short name" do
      opts = []
      assert {:shortnames, short_name} = get_node_option(opts)
      assert "n_" <> <<_::binary>> = Atom.to_string(short_name)
    end
  end
end
