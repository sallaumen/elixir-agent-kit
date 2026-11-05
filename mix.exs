defmodule ElixirAgentKit.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_agent_kit,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: [],
      description: "Versioned coding-agent practices and safe project setup for Elixir teams",
      source_url: "https://github.com/sallaumen/elixir-agent-kit",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/sallaumen/elixir-agent-kit"},
        files:
          ~w(lib priv docs mix.exs README.md LICENSE CHANGELOG.md CONTRIBUTING.md SECURITY.md)
      ],
      aliases: [check: ["format --check-formatted", "compile --warnings-as-errors", "test"]]
    ]
  end

  def cli, do: [preferred_envs: [check: :test]]

  def application, do: [extra_applications: [:crypto]]
end
