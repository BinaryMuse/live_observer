defmodule LiveObserver.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_observer,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases() do
    [
      dev: ["run --no-halt dev.exs"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # TODO: update once phoenix_live_view reaches 1.0.0
      {:phoenix_live_view, "~> 1.0.0-rc.1", phoenix_live_view_opts()},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:plug_cowboy, "~> 2.0", only: :dev},
      {:jason, "~> 1.0", only: [:dev, :test, :docs]},
      {:esbuild, "~> 0.7", only: :dev},
      {:tailwind, "~> 0.2", only: :dev}
    ]
  end

  defp phoenix_live_view_opts do
    if path = System.get_env("LIVE_VIEW_PATH") do
      [path: path]
    else
      []
    end
  end
end
