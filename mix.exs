defmodule Jinja.MixProject do
  use Mix.Project

  def project do
    [
      app: :jinja,
      version: "0.0.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:pythonx, "~> 0.4.5"}
    ]
  end
end
