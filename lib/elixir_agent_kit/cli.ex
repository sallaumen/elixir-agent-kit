defmodule ElixirAgentKit.CLI do
  @moduledoc false

  def run(action, args) do
    {flags, rest, invalid} =
      OptionParser.parse(args, strict: [agents: :string, skills: :string, dry_run: :boolean])

    if rest != [] or invalid != [],
      do: Mix.raise("Expected --agents codex,claude,generic, --skills ID,ID and/or --dry-run")

    if action == :check and flags[:dry_run], do: Mix.raise("check is already read-only")
    config = Mix.Project.config()[:elixir_agent_kit] || []

    unless Keyword.keyword?(config),
      do: Mix.raise(":elixir_agent_kit configuration must be a keyword list")

    unknown = Keyword.keys(config) -- [:agents, :skills]

    unless unknown == [],
      do: Mix.raise("Unknown Elixir Agent Kit configuration keys: #{inspect(unknown)}")

    opts =
      config
      |> override(:agents, flags[:agents])
      |> override(:skills, flags[:skills])
      |> Keyword.put(:dry_run, flags[:dry_run] || false)

    case ElixirAgentKit.Installer.run(action, File.cwd!(), opts) do
      {:ok, []} ->
        Mix.shell().info("Elixir Agent Kit #{ElixirAgentKit.version()}: no changes needed.")

      {:ok, paths} ->
        verb = if opts[:dry_run], do: "Would change", else: "Changed"
        Mix.shell().info("#{verb} #{length(paths)} paths:")
        Enum.each(paths, &Mix.shell().info("  " <> &1))

      {:drift, paths} ->
        Enum.each(paths, &Mix.shell().error("Out of sync: " <> &1))

        Mix.raise(
          "Elixir Agent Kit is missing or out of sync. Review changes, then run mix agent_kit.sync."
        )
    end
  rescue
    error in ArgumentError -> Mix.raise(Exception.message(error))
  end

  defp override(opts, _key, nil), do: opts

  defp override(opts, key, value),
    do: Keyword.put(opts, key, String.split(value, ",", trim: true))
end
