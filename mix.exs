defmodule KantanCluster.MixProject do
  use Mix.Project

  @version "0.3.1"
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
      aliases: aliases(),
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
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:phoenix_pubsub, "~> 2.0"}
    ]
  end

  defp dialyzer() do
    [
      flags: [:race_conditions, :unmatched_returns, :error_handling, :underspecs]
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

  # Aliases are shortcuts or tasks specific to the current project.
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      format: ["format", "credo"]
    ]
  end
end
