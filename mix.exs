defmodule ElixirAgentKit.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_agent_kit,
      version: "1.2.2",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps:
        if(Mix.env() == :docs,
          do: [{:ex_doc, "~> 0.40.0", only: :docs, runtime: false}],
          else: []
        ),
      description: "Versioned coding-agent practices and safe project setup for Elixir teams",
      source_url: "https://github.com/sallaumen/elixir-agent-kit",
      package: [
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/sallaumen/elixir-agent-kit"},
        files:
          ~w(lib priv docs mix.exs README.md LICENSE CHANGELOG.md CONTRIBUTING.md SECURITY.md)
      ],
      docs: [
        main: "installation",
        source_ref: System.get_env("DOCS_SOURCE_REF", "main"),
        footer: false,
        extras: ["docs/installation.md", "docs/instalacao.md"]
      ],
      aliases: [check: ["format --check-formatted", "compile --warnings-as-errors", "test"]]
    ]
  end

  def cli, do: [preferred_envs: [check: :test]]

  def application, do: [extra_applications: [:crypto]]
end
