# KantanCluster

かんたんクラスター

[![Hex version](https://img.shields.io/hexpm/v/kantan_cluster.svg 'Hex version')](https://hex.pm/packages/kantan_cluster)
[![API docs](https://img.shields.io/hexpm/v/kantan_cluster.svg?label=docs 'API docs')](https://hexdocs.pm/kantan_cluster)
[![CI](https://github.com/mnishiguchi/kantan_cluster/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/kantan_cluster/actions/workflows/ci.yml)

Form a simple Erlang cluster easily in Elixir.

- A wrapper of [`Node`] and [`Phoenix.PubSub`] with simple API
- Reconnection forever in case nodes get disconnected

[`Node`]: https://hexdocs.pm/elixir/Node.html
[`Phoenix.PubSub`]: https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html

## Getting started

Add `kantan_cluster` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kantan_cluster, "~> 0.3"}
  ]
end
```

Start a node and connect it to other nodes based on specified [options].

```elixir
iex> KantanCluster.start(
  node: "node1",
  cookie: :hello,
  connect_to: [:"nerves@nerves-mn00.local"]
)
:ok

iex(node1@My-Machine.local)>
```

Alternatively, [options] can be loaded from your `config/config.exs`.

```elixir
config :kantan_cluster,
  node: "node1",
  cookie: :hello,
  connect_to: [:"nerves@nerves-mn00.local"]
```

`kantan_cluster` starts a server that monitors the connection per node name under a `DynamicSupervisor`.

![](https://user-images.githubusercontent.com/7563926/139163607-704c0352-64ff-47f3-8697-9958654c27b4.png)

`kantan_cluster` monitors all the connected nodes and attempts to reconnect them automatically in case they get disconnected.

![](https://user-images.githubusercontent.com/7563926/138617820-562b8102-c478-424d-bfaa-e15abf08a722.png)

You can connect to or disconnect from a node on demand.

```elixir
KantanCluster.connect(:"nerves@nerves-mn01.local")

KantanCluster.disconnect(:"nerves@nerves-mn01.local")
```

For cleanup, just call `KantanCluster.stop/0`, which will stop the node and all the connections.

## Publish–subscribe

```elixir
# Subscribes the caller to the KantanCluster's topic.
KantanCluster.subscribe("users:123")

# Broadcasts message on given topic across the whole cluster.
KantanCluster.broadcast("users:123", {:hello, Node.self()})
```

## Acknowledgements

- This project is inspired by [nerves_pack（vintage_net含む）を使ってNerves起動時に`Node.connect()`するようにした by nishiuchikazuma](https://qiita.com/nishiuchikazuma/items/f68d2661959197d0765c).
- [Forming an Erlang cluster of Pi Zeros by underjord](https://youtu.be/ZdtAVlzFf6Q) is a great hands-on tutorial for connecting multiple [Nerves] devices.
- Some code is adopted from [`livebook`].

<!-- Links -->

[Erlang magic cookie]: https://erlang.org/doc/reference_manual/distributed.html#security
[`livebook`]: https://github.com/livebook-dev/livebook
[options]: https://hexdocs.pm/kantan_cluster/KantanCluster.html#t:option/0
[Nerves]: https://www.nerves-project.org/
