defmodule EasyCluster.MixProject do
  use Mix.Project

  def project do
    [
      app: :easy_cluster,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :os_mon, :inets, :ssl],
      mod: {EasyCluster.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false}
    ]
  end
end
