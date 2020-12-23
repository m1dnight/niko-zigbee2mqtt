defmodule Niko.MixProject do
  use Mix.Project

  def project do
    [
      app: :niko_connector,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Niko.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tortoise, "~> 0.9"},
      {:poison, "~> 4.0.1"},
      {:pubsub, "~> 1.0"}
    ]
  end
end
