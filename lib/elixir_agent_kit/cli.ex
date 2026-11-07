defmodule ElixirAgentKit.CLI do
  @moduledoc false

  def run(action, args) do
    opts = options!(action, args, Mix.Project.config()[:elixir_agent_kit])
    library = library_path()
    opts = Keyword.put(opts, :library_path, library)

    if action != :uninstall do
      skills = if is_list(opts[:skills]), do: Enum.map(opts[:skills], &to_string/1), else: ["all"]

      case ElixirAgentKit.Installer.missing_library_files(library, skills) do
        [] ->
          :ok

        missing ->
          Mix.raise(
            "Elixir Agent Kit library is incomplete at #{library}; missing #{Enum.join(missing, ", ")}. Run mix deps.get."
          )
      end
    end

    result = ElixirAgentKit.Installer.run(action, File.cwd!(), opts)
    if action != :uninstall, do: warn_hidden_claude()

    case result do
      {:ok, []} ->
        Mix.shell().info("Elixir Agent Kit #{ElixirAgentKit.version()}: no changes needed.")

      {:ok, paths} ->
        verb = if opts[:dry_run], do: "Would change", else: "Changed"
        Mix.shell().info("#{verb} #{length(paths)} paths:")
        Enum.each(paths, &Mix.shell().info("  " <> &1))

        if action in [:install, :sync] and not opts[:dry_run] do
          Mix.shell().info(
            "\nNext: run mix agent_kit.check, commit these paths, then ask a fresh agent\n" <>
              "session to follow .elixir-agent-kit/START.md and name the workflow it selects."
          )
        end

      {:drift, paths} ->
        Enum.each(paths, &Mix.shell().error("Out of sync: " <> &1))

        Mix.raise(
          "Elixir Agent Kit is missing or out of sync. Review changes, then run mix agent_kit.sync."
        )
    end
  rescue
    error in ArgumentError -> Mix.raise(Exception.message(error))
  end

  @doc false
  # Everything run/2 decides before the installer: flag parsing, the refusals
  # that need no project, and the mix.exs configuration rules. Pure, so the
  # rules are testable without a Mix project or a library on disk.
  def options!(action, args, project_config) do
    {flags, rest, invalid} =
      OptionParser.parse(args, strict: [agents: :string, skills: :string, dry_run: :boolean])

    if rest != [] or invalid != [],
      do: Mix.raise("Expected --agents codex,claude,generic, --skills ID,ID and/or --dry-run")

    if action == :check and flags[:dry_run], do: Mix.raise("check is already read-only")

    if action == :uninstall and (flags[:agents] || flags[:skills]),
      do: Mix.raise("uninstall removes everything the kit owns; it takes no selection flags")

    config = project_config || []

    unless Keyword.keyword?(config),
      do: Mix.raise(":elixir_agent_kit configuration must be a keyword list")

    unknown = Keyword.keys(config) -- [:agents, :skills]

    unless unknown == [],
      do: Mix.raise("Unknown Elixir Agent Kit configuration keys: #{inspect(unknown)}")

    # A declared :elixir_agent_kit entry is the source of truth, so a key removed
    # from mix.exs falls back to the default rather than to the recorded state.
    config =
      if project_config,
        do: config |> Keyword.put_new(:agents, [:generic]) |> Keyword.put_new(:skills, :all),
        else: config

    config
    |> override(:agents, flags[:agents])
    |> override(:skills, flags[:skills])
    |> Keyword.put(:dry_run, flags[:dry_run] || false)
  end

  # Claude Code ignores AGENTS.md once a CLAUDE.md applies, so a project with a
  # CLAUDE.md and no :claude selection hides the kit from that client silently.
  defp warn_hidden_claude do
    agents =
      case File.read(".elixir-agent-kit/state.tsv") do
        {:ok, state} ->
          case Regex.run(~r/^agents\t(.*)$/m, state) do
            [_, list] -> String.split(String.trim(list), ",")
            nil -> []
          end

        _ ->
          []
      end

    if File.regular?("CLAUDE.md") and agents != [] and "claude" not in agents do
      Mix.shell().info(
        "Note: CLAUDE.md exists but :claude is not selected, so Claude Code will not see the kit.\n" <>
          "Add :claude to agents in mix.exs and run mix agent_kit.sync if that client is used here."
      )
    end
  end

  defp library_path do
    case Mix.Project.deps_paths()[:elixir_agent_kit] do
      nil -> ElixirAgentKit.library_path()
      path -> Path.join(path, "priv/library")
    end
  end

  defp override(opts, _key, nil), do: opts

  defp override(opts, key, value),
    do: Keyword.put(opts, key, String.split(value, ",", trim: true))
end
