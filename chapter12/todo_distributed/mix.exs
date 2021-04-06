defmodule GprocTodoApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :gproc_todo_app,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:logger, :gproc, :cowboy, :plug],
      mod: {Todo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gproc, "0.3.1"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.4.0"},
      {:meck, "0.8.2", only: :test},
      {:httpoison, "0.4.3", only: :test}
    ]
  end
end
