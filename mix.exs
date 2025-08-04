defmodule Jinja.MixProject do
  use Mix.Project

  @documentation "https://hexdocs.pm/jinja"
  @git_repository "https://git.dupunkto.org/~axcelott/jinja"

  def project do
    [
      name: "Jinja2",
      app: :jinja,
      version: "0.0.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      source_url: @git_repository,
      homepage_url: @documentation,
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  def description do
    "Jinja bindings for Elixir using Pythonx"
  end

  defp package do
    [
      licenses: ["Unlicense"],
      links: %{"Sources" => @git_repository}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:structo, "~> 0.2.0"},
      {:pythonx, "~> 0.4.5"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
    ]
  end

  defp docs do
    [
      main: "Jinja",
      api_reference: false,
      authors: ["Robijntje"],
      formatters: ["html"]
    ]
  end
end
