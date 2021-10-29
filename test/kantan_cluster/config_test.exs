defmodule KantanCluster.ConfigTest do
  use ExUnit.Case

  import KantanCluster.Config

  describe "get_node_option/1" do
    test "explicit longnames mode" do
      opts = [node: {:longnames, :"node@127.0.0.1"}]
      assert {:longnames, :"node@127.0.0.1"} == get_node_option(opts)
    end

    test "explicit shortnames mode" do
      opts = [node: {:shortnames, :"node@my-machine"}]
      assert {:shortnames, :"node@my-machine"} == get_node_option(opts)
    end

    test "implicit name only" do
      opts = [node: "nerves"]
      {:ok, hostname} = :inet.gethostname()
      assert {:longnames, :"nerves@#{hostname}.local"} == get_node_option(opts)
    end

    test "implicit blank" do
      {:ok, hostname} = :inet.gethostname()
      assert {:longnames, long_name} = get_node_option([])
      assert Atom.to_string(long_name) =~ Regex.compile!(".*@#{hostname}.local")
    end
  end
end
