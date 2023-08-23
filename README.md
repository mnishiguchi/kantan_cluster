# KantanCluster

かんたんクラスター

[![Hex version](https://img.shields.io/hexpm/v/kantan_cluster.svg "Hex version")](https://hex.pm/packages/kantan_cluster)
[![API docs](https://img.shields.io/hexpm/v/kantan_cluster.svg?label=docs "API docs")](https://hexdocs.pm/kantan_cluster)
[![CI](https://github.com/mnishiguchi/kantan_cluster/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/kantan_cluster/actions/workflows/ci.yml)

<!-- MODULEDOC -->

Form a simple Erlang cluster easily in Elixir.

KantanCluster is a thin wrapper around
[libcluster](https://hexdocs.pm/libcluster) and
[phoenix_pubsub](https://hexdocs.pm/phoenix_pubsub). It allows you to try out
distributed Erlang nodes easily.

<!-- MODULEDOC -->

## Getting started

Add `kantan_cluster` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kantan_cluster, "~> 0.5"}
  ]
end
```

## Demo

Open an interactive [Elixir shell
(IEx)](https://elixir-lang.org/getting-started/introduction.html#interactive-mode)
in a terminal, and start a node with node name and cookie.

```elixir
iex

iex> Mix.install([{:kantan_cluster, "~> 0.5"}])
iex> KantanCluster.start_node(sname: :node1, cookie: :hello)
```

Open another terminal and do the same with a different node name. Make sure
that the cookie is the same.

```elixir
iex

iex> Mix.install([{:kantan_cluster, "~> 0.5"}])
iex> KantanCluster.start_node(sname: :node2, cookie: :hello)
```

These two nodes will be connected to each other automatically.

## Configuration

Alternatively, [options] can be loaded from your project's `config/config.exs`.
For available clustering strategies, see https://hexdocs.pm/libcluster/readme.html#clustering.

```elixir
config :kantan_cluster,
  name: :"node1@127.0.0.1",
  cookie: :super_secure_erlang_magic_cookie,
  topologies: [gossip_example: [
    strategy: Cluster.Strategy.Gossip,
    secret: "super_secure_gossip_secret"
  ]]
```

## Publish-Subscribe

Under the hood, `kantan_cluster` uses [phoenix_pubsub] for all the heavy-lifting.

```elixir
# subscribe to hello topic in one node
iex(hoge@my-machine)> KantanCluster.subscribe("hello")
```

```elixir
# publish a message to hello topic in another node
iex(piyo@my-machine)> KantanCluster.broadcast("hello", %{motto: "元氣があればなんでもできる"})
```

```elixir
# check the mailbox in a node that subscribes hello topic
iex(hoge@my-machine)> flush
```

The messages can be handled with a `GenServer` like below.

```elixir
# Somebody in the cluster may publish temperature data on the topic "hello_nerves:measurements".
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

This project is inspired by the following:
- [nerves_pack（vintage_net 含む）を使って Nerves 起動時に`Node.connect()`するようにした by nishiuchikazuma](https://qiita.com/nishiuchikazuma/items/f68d2661959197d0765c)
- [Forming an Erlang cluster of Pi Zeros by underjord](https://youtu.be/ZdtAVlzFf6Q) --- a great hands-on tutorial for connecting multiple [Nerves] devices
- [Let's Talk by Herman Verschooten](https://til.verschooten.name/til/2023-08-13/lets-talk)
- [Exploring Elixir Episode 7: Effortless Scaling With Automatic Clusters](https://www.youtube.com/watch?v=zQEgEnjuQsU)
- [livebook]

<!-- Links -->

[Erlang magic cookie]: https://erlang.org/doc/reference_manual/distributed.html#security
[livebook]: https://github.com/livebook-dev/livebook
[options]: https://hexdocs.pm/kantan_cluster/KantanCluster.html#t:option/0
[Nerves]: https://www.nerves-project.org/
[phoenix_pubsub]: https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html
