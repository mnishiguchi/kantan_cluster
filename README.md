# KantanCluster

[![Hex version](https://img.shields.io/hexpm/v/kantan_cluster.svg 'Hex version')](https://hex.pm/packages/kantan_cluster)
[![API docs](https://img.shields.io/hexpm/v/kantan_cluster.svg?label=docs 'API docs')](https://hexdocs.pm/kantan_cluster)
[![CI](https://github.com/mnishiguchi/kantan_cluster/actions/workflows/ci.yml/badge.svg)](https://github.com/mnishiguchi/kantan_cluster/actions/workflows/ci.yml)

Form a simple Erlang cluster easily in Elixir.

Documentation can be found at [https://hexdocs.pm/kantan_cluster](https://hexdocs.pm/kantan_cluster).

### Getting started

Add `kantan_cluster` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kantan_cluster, "~> 0.1.0"}
  ]
end
```

Configurarion for `kantan_cluster` in `config/config.exs` might look like this:

```elixir
import Config

config :kantan_cluster,
  node: {:longnames, :"nerves@nerves-mn00.local"},
  cookie: :my_secret_cookie,
  connect_to: [
    :"nerves@nerves-mn01.local",
    :"nerves@nerves-mn02.local"
  ]
```

* `:node` - a name of the node that we want to start (default: `{:longnames, :"xxxx@127.0.0.1"}` where `xxxx` is a random string)
* `:cookie` - [Erlang magic cookie] to form a cluster (default: random cookie)
* `:connect_to` - a list of nodes we want our node to be connected with (default: `[]`)

`kantan_cluster` monitors all the connected nodes and reconnects them automatically.

![](https://user-images.githubusercontent.com/7563926/138617820-562b8102-c478-424d-bfaa-e15abf08a722.png)

<!-- Links -->

[Erlang magic cookie]: https://erlang.org/doc/reference_manual/distributed.html#security
