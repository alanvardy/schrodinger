defmodule Schrodinger.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :schrodinger,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],

      # Hex
      description: "Check any struct against multiple valid and invalid state definitions",
      package: package(),

      # Docs
      name: "Schrodinger",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Alan Vardy"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/alanvardy/schrodinger"},
      files: [
        "lib/schrodinger.ex",
        "lib/schrodinger",
        "mix.exs",
        "README.md"
      ]
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "README",
      canonical: "http://hexdocs.pm/schrodinger",
      source_url: "https://github.com/alanvardy/schrodinger",
      filter_prefix: "Schrodinger",
      extras: [
        "README.md": [filename: "README"],
        "CHANGELOG.md": [filename: "CHANGELOG"]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_check, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.3.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
