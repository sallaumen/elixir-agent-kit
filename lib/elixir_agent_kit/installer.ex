defmodule ElixirAgentKit.Installer do
  @moduledoc false
  @state ".elixir-agent-kit/state.tsv"
  @start "\n\n<!-- elixir-agent-kit:start -->\n"
  @finish "<!-- elixir-agent-kit:end -->\n"
  @agents ~w(codex claude generic)

  def run(action, root, opts \\ []) when action in [:install, :sync, :check, :uninstall] do
    root = Path.expand(root)
    safe_path!(root, @state)
    previous = read_state(root)
    config = configuration(opts, previous)
    desired = if action == :uninstall, do: %{}, else: files(config, root, opts)
    entries = if previous, do: previous.entries, else: %{}
    changes = plan(root, desired, entries, action)
    state = if action == :uninstall, do: nil, else: encode_state(config, desired, root, entries)
    changes = put_change(changes, @state, read(root, @state), state)

    cond do
      action == :check ->
        if changes == [], do: {:ok, []}, else: {:drift, Enum.map(changes, &elem(&1, 0))}

      opts[:dry_run] ->
        {:ok, Enum.map(changes, &elem(&1, 0))}

      true ->
        Enum.each(changes, fn {path, contents} -> write(root, path, contents) end)
        {:ok, Enum.map(changes, &elem(&1, 0))}
    end
  end

  defp configuration(opts, previous) do
    agents = opts[:agents] || (previous && previous.agents) || ["generic"]
    skills = opts[:skills] || (previous && previous.skills) || ["all"]
    agents = normalize(agents)
    skills = normalize(skills)
    known = Enum.map(ElixirAgentKit.catalog(), & &1.id)

    unless agents != [] and Enum.all?(agents, &(&1 in @agents)),
      do: fail!("agents must be a non-empty selection of codex, claude, generic")

    unless skills == ["all"] or (skills != [] and Enum.all?(skills, &(&1 in known))),
      do: fail!("skills must be all or known IDs from mix agent_kit.list")

    %{agents: agents, skills: skills}
  end

  defp normalize(:all), do: ["all"]

  defp normalize(value) when is_list(value),
    do: value |> Enum.map(&to_string/1) |> Enum.uniq() |> Enum.sort()

  defp normalize(_), do: fail!("agents and skills must be lists")

  defp files(config, root, opts) do
    library =
      opts
      |> Keyword.get(:library_path, Path.join(root, "deps/elixir_agent_kit/priv/library"))
      |> Path.expand()

    # External path dependencies keep their explicit local location.
    target =
      if String.starts_with?(library, root <> "/"),
        do: "../" <> Path.relative_to(library, root),
        else: library

    payload = %{".elixir-agent-kit/START.md" => {:file, start_document(config, target)}}

    Enum.reduce(config.agents, payload, fn agent, acc ->
      instructions = if agent == "claude", do: "CLAUDE.md", else: "AGENTS.md"
      Map.put(acc, instructions, {:block, block(agent, config, root)})
    end)
  end

  defp start_document(config, target) do
    selection =
      if config.skills == ["all"],
        do: "Choose the smallest relevant workflow from the routing guide and catalog.",
        else: "Enabled workflow IDs: " <> Enum.map_join(config.skills, ", ", &"`#{&1}`") <> "."

    # Markdown destinations need encoding for spaces and parentheses in local paths.
    target =
      URI.encode(target, &(&1 in ?a..?z or &1 in ?A..?Z or &1 in ?0..?9 or &1 in ~c"/-._~:"))

    """
    # Elixir Agent Kit #{ElixirAgentKit.version()}

    Read the [shared contract](#{target}/CONTRACT.md), then use the
    [area routing guide](#{target}/ROUTING.md) and
    [workflow catalog](#{target}/CATALOG.md). #{selection}
    Read workflow bodies from the dependency; do not copy them into this project.
    Use the [Elixir context](#{target}/ELIXIR.md) only for technologies present here.
    Follow [practice evolution](#{target}/EVOLUTION.md) for reusable improvements.
    Project rules and the user's authorized scope govern the work.
    If a target is missing, run `mix deps.get` in this checkout before using the kit.
    If your client cannot read ignored dependency files, report that limitation;
    do not claim the practices were loaded. Do not edit this generated index.
    """
  end

  # Claude Code reads AGENTS.md only while no CLAUDE.md applies, so a Claude block
  # imports AGENTS.md whenever the kit manages it or the project already has one.
  # Otherwise creating CLAUDE.md would silently hide the project's instructions.
  defp block("claude", config, root) do
    cond do
      Enum.any?(config.agents, &(&1 != "claude")) -> wrap(import_agents())
      read(root, "AGENTS.md") != nil -> wrap(import_agents() <> "\n" <> reference())
      true -> wrap(reference())
    end
  end

  defp block(_agent, _config, _root), do: wrap(reference())

  defp wrap(body), do: @start <> "## Elixir Agent Kit\n\n" <> body <> @finish

  defp reference do
    "For development tasks, consult [.elixir-agent-kit/START.md](.elixir-agent-kit/START.md).\n" <>
      "Select the relevant workflow and read its shared contract. Preserve this project's rules.\n" <>
      "If the files are missing, report the missing setup; do not claim the practices were applied.\n"
  end

  defp import_agents do
    "Claude Code reads AGENTS.md only when no CLAUDE.md applies, so this block imports it.\n" <>
      "This project's instructions in AGENTS.md govern the work.\n\n@AGENTS.md\n"
  end

  defp plan(root, desired, previous, action) do
    paths = (Map.keys(desired) ++ Map.keys(previous)) |> Enum.uniq() |> Enum.sort()

    Enum.reduce(paths, [], fn path, changes ->
      safe_path!(root, path)
      current = read(root, path)
      old = previous[path]
      new = desired[path]
      kind = if new, do: elem(new, 0), else: elem(old, 0)
      owned = if kind == :block, do: extract_block(current, path), else: current

      if action != :check do
        cond do
          old == nil and owned != nil ->
            fail!("unmanaged content at #{path}; nothing was written")

          old != nil and owned != nil and digest(owned) != elem(old, 1) ->
            fail!(
              "locally modified managed content at #{path}; preserve it before syncing; nothing was written"
            )

          true ->
            :ok
        end
      end

      contents =
        case {kind, new} do
          {:file, nil} ->
            nil

          {:file, {:file, value}} ->
            value

          {:block, nil} ->
            remaining = remove_block(current, owned)
            if remaining == nil and elem(old, 2) == :existing, do: "", else: remaining

          {:block, {:block, value}} ->
            if owned,
              do: String.replace(current, owned, value, global: false),
              else: (current || "") <> value
        end

      put_change(changes, path, current, contents)
    end)
  end

  defp extract_block(nil, _path), do: nil

  defp extract_block(contents, path) do
    starts = length(:binary.matches(contents, "<!-- elixir-agent-kit:start -->"))
    ends = length(:binary.matches(contents, "<!-- elixir-agent-kit:end -->"))

    case {starts, ends, String.split(contents, @start, parts: 2)} do
      {0, 0, _} ->
        nil

      {1, 1, [_before, tail]} ->
        case String.split(tail, @finish, parts: 2) do
          [body, _after] -> @start <> body <> @finish
          _ -> fail!("malformed managed block in #{path}")
        end

      _ ->
        fail!("malformed or repeated managed markers in #{path}")
    end
  end

  defp remove_block(nil, _), do: nil
  defp remove_block(contents, nil), do: contents

  defp remove_block(contents, block) do
    case String.replace(contents, block, "", global: false) do
      "" -> nil
      remaining -> remaining
    end
  end

  defp encode_state(config, files, root, previous) do
    header =
      "schema\t1\nversion\t#{ElixirAgentKit.version()}\nagents\t#{Enum.join(config.agents, ",")}\nskills\t#{Enum.join(config.skills, ",")}\n"

    body =
      files
      |> Enum.sort()
      |> Enum.map_join("", fn {path, {kind, content}} ->
        origin =
          case previous[path] do
            {_, _, value} -> value
            nil -> if kind == :block and read(root, path) != nil, do: :existing, else: :created
          end

        "#{kind}\t#{path}\t#{digest(content)}\t#{origin}\n"
      end)

    header <> body
  end

  defp read_state(root) do
    case read(root, @state) do
      nil -> nil
      contents -> parse_state(contents)
    end
  end

  defp parse_state(contents) do
    with ["schema\t1", "version\t" <> version, "agents\t" <> agents, "skills\t" <> skills | rows] <-
           String.split(contents, "\n", trim: true),
         {:ok, _} <- Version.parse(version) do
      entries = Enum.map(rows, &parse_entry/1)

      unless length(entries) == map_size(Map.new(entries)),
        do: fail!("duplicate paths in managed state")

      %{
        agents: String.split(agents, ","),
        skills: String.split(skills, ","),
        entries: Map.new(entries)
      }
    else
      _ ->
        fail!("invalid managed state; restore .elixir-agent-kit/state.tsv from version control")
    end
  end

  defp parse_entry(row) do
    case String.split(row, "\t") do
      [kind, path, hash, origin]
      when kind in ["file", "block"] and origin in ["created", "existing"] ->
        valid_path =
          case kind do
            "block" ->
              path in ["AGENTS.md", "CLAUDE.md"]

            "file" ->
              String.starts_with?(path, ".elixir-agent-kit/library/") or
                path == ".elixir-agent-kit/START.md" or
                Regex.match?(~r/^\.(agents|claude)\/skills\/eak-[a-z0-9-]+\/SKILL\.md$/, path)
          end

        unless valid_path and Regex.match?(~r/^[a-f0-9]{64}$/, hash),
          do: fail!("invalid managed state entry")

        {path,
         {if(kind == "file", do: :file, else: :block), hash,
          if(origin == "existing", do: :existing, else: :created)}}

      _ ->
        fail!("invalid managed state entry")
    end
  end

  defp safe_path!(root, relative) do
    parts = Path.split(relative)

    unless Path.type(relative) == :relative and Enum.all?(parts, &(&1 not in ["..", ".", ""])),
      do: fail!("unsafe managed path")

    Enum.reduce(parts, root, fn part, parent ->
      path = Path.join(parent, part)

      case File.lstat(path) do
        {:ok, %{type: :symlink}} -> fail!("refusing symlink at #{relative}")
        {:ok, %{type: type}} when type in [:regular, :directory] -> :ok
        {:ok, _} -> fail!("unsupported file type at #{relative}")
        {:error, :enoent} -> :ok
        {:error, reason} -> fail!("cannot inspect #{relative}: #{reason}")
      end

      path
    end)
  end

  defp read(root, path) do
    case File.read(Path.join(root, path)) do
      {:ok, content} -> content
      {:error, :enoent} -> nil
      {:error, reason} -> fail!("cannot read #{path}: #{reason}")
    end
  end

  defp put_change(changes, _path, same, same), do: changes
  defp put_change(changes, path, _old, new), do: changes ++ [{path, new}]

  defp write(root, path, nil), do: File.rm!(Path.join(root, path))

  defp write(root, path, contents) do
    full = Path.join(root, path)
    File.mkdir_p!(Path.dirname(full))
    File.write!(full, contents)
  end

  defp digest(contents), do: :crypto.hash(:sha256, contents) |> Base.encode16(case: :lower)
  defp fail!(message), do: raise(ArgumentError, message)
end
