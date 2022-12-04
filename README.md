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

Start `node1` in an IEx shell, then attempt to connect it to `node2` that is not started yet.

```elixir
iex> KantanCluster.start(name: :"node1@127.0.0.1", cookie: :hello, connect_to: :"node2@127.0.0.1")
:ok

iex(node1@127.0.0.1)2>
16:50:10.851 [warning] could not connect node1@127.0.0.1 to node2@127.0.0.1
```

Start `node2` in another IEx shell, then the two nodes get connected.

See what happens in `node1`, when `node2` is stopped and gets started again,

```elixir
iex> KantanCluster.start(name: :"node2@127.0.0.1", cookie: :hello)
:ok

iex(node2@127.0.0.1)2> Node.list
[:"node1@127.0.0.1"]

iex(node2@127.0.0.1)3> Node.stop
:ok

iex> KantanCluster.start(name: :"node2@127.0.0.1", cookie: :hello)
:ok
```

Alternatively, [options] can be loaded from your `config/config.exs`.

```elixir
config :kantan_cluster,
  name: :"node1@127.0.0.1",
  cookie: :hello,
  connect_to: [:"node2@127.0.0.1"]
```

`kantan_cluster` starts a server that monitors the connection per node name under a `DynamicSupervisor`.

![](https://user-images.githubusercontent.com/7563926/139163607-704c0352-64ff-47f3-8697-9958654c27b4.png)

`kantan_cluster` monitors all the connected nodes and attempts to reconnect them automatically in case they get disconnected.

You can connect to or disconnect from a node on demand.

```elixir
KantanCluster.connect(:"nerves@nerves-mn01.local")

KantanCluster.disconnect(:"nerves@nerves-mn01.local")
```

For cleanup, just call `KantanCluster.stop/0`, which will stop the node and all the connections.

## Publish-subscribe

The publish-subscribe allows us to make a published message available from anywhere in a cluster.
Under the hood, `kantan_cluster` uses [`phoenix_pubsub`] for all the heavy-lifting.

```elixir
# Somebody may publish temperature data on the topic "hello_nerves:measurements".
message = {:hello_nerves_measurements, %{temperature_c: 30.1}, node()}
KantanCluster.broadcast("hello_nerves:measurements", message)

# Anybody within the same cluster can subscribe to the topic and receive messages on the topic.
KantanCluster.subscribe("hello_nerves:measurements")

# In the subscribing process, you may receive the message using GenServer's handle_info callback.
defmodule HelloNervesSubscriber do
  use GenServer

  # ...

  @impl GenServer
  def handle_info({:hello_nerves_measurement, measurement, _node}, state) do
    {:noreply, %{state | last_measurement: measurement}}
  end
```

![kantan_cluster_inky_experiment_20220109_175511](https://user-images.githubusercontent.com/7563926/148710739-a11e504f-3398-4732-8531-cdb9292b672e.jpg)

## Acknowledgements

- This project is inspired by [nerves_pack（vintage_net含む）を使ってNerves起動時に`Node.connect()`するようにした by nishiuchikazuma](https://qiita.com/nishiuchikazuma/items/f68d2661959197d0765c).
- [Forming an Erlang cluster of Pi Zeros by underjord](https://youtu.be/ZdtAVlzFf6Q) is a great hands-on tutorial for connecting multiple [Nerves] devices.
- Some code is adopted from [`livebook`].

<!-- Links -->

[Erlang magic cookie]: https://erlang.org/doc/reference_manual/distributed.html#security
[`livebook`]: https://github.com/livebook-dev/livebook
[options]: https://hexdocs.pm/kantan_cluster/KantanCluster.html#t:option/0
[Nerves]: https://www.nerves-project.org/
[`phoenix_pubsub`]: https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html
