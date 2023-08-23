defmodule KantanCluster.MixProject do
  use Mix.Project

  @version "0.5.0"
  @source_url "https://github.com/mnishiguchi/kantan_cluster"

  def project do
    [
      app: :kantan_cluster,
      version: @version,
      description: "Form a simple Erlang cluster easily in Elixir",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      dialyzer: dialyzer(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :inets, :ssl],
      mod: {KantanCluster.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30", only: [:dev], runtime: false},
      {:libcluster, "~> 3.3"},
      {:mix_test_watch, "~> 1.1", only: [:dev], runtime: false},
      {:phoenix_pubsub, "~> 2.1"}
    ]
  end

  defp dialyzer() do
    [
      flags: [:extra_return, :unmatched_returns, :error_handling]
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp package do
    %{
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE*",
        "CHANGELOG*"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    }
  end
end
