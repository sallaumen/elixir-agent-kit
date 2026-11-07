defmodule ElixirAgentKit.Installer do
  @moduledoc false
  @state ".elixir-agent-kit/state.tsv"
  @start "<!-- elixir-agent-kit:start -->\n"
  @finish "<!-- elixir-agent-kit:end -->\n"
  @agents ~w(codex claude generic)
  @plans_ignore ".elixir-agent-kit/plans/.gitignore"

  def run(action, root, opts \\ []) when action in [:install, :sync, :check, :uninstall] do
    root = Path.expand(root)
    safe_path!(root, @state)
    previous = read_state(root)
    config = configuration(opts, previous)
    desired = if action == :uninstall, do: %{}, else: files(config, root, opts)
    entries = if previous, do: previous.entries, else: %{}
    changes = plan(root, desired, entries, action)
    state = if action == :uninstall, do: nil, else: encode_state(config, desired, root, entries)
    changes = put_change(changes, @state, read_text(root, @state), state)

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

  @doc false
  # Library files every generated link points at. The CLI refuses to report a
  # consumer as in sync while one is missing, because the links would be broken.
  def missing_library_files(library, skills \\ ["all"]) do
    enabled =
      Enum.filter(ElixirAgentKit.catalog(), &(skills == ["all"] or &1.id in skills))

    ~w(CONTRACT.md ROUTING.md ELIXIR.md EVOLUTION.md HANDOFF.md templates/task-plan.md)
    |> Kernel.++(Enum.map(enabled, &"skills/#{&1.id}/SKILL.md"))
    |> Enum.reject(&File.regular?(Path.join(library, &1)))
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
    relative =
      if String.starts_with?(library, root <> "/"), do: Path.relative_to(library, root)

    # Markdown destinations need encoding for spaces and parentheses in local paths.
    target = fn depth ->
      path = if relative, do: String.duplicate("../", depth) <> relative, else: library
      URI.encode(path, &(&1 in ?a..?z or &1 in ?A..?Z or &1 in ?0..?9 or &1 in ~c"/-._~:"))
    end

    # The plans folder ignores its own contents, so the consumer's .gitignore is never touched.
    payload = %{
      ".elixir-agent-kit/START.md" => {:file, start_document(config, target.(1))},
      @plans_ignore => {:file, "*\n!.gitignore\n"}
    }

    Enum.reduce(config.agents, payload, fn agent, acc ->
      instructions = if agent == "claude", do: "CLAUDE.md", else: "AGENTS.md"
      acc = Map.put(acc, instructions, {:block, block(agent, config, root)})

      case pointer_path(agent) do
        nil -> acc
        path -> Map.put(acc, path, {:file, pointer_document(config, target.(3))})
      end
    end)
  end

  # One generated skill per native skill directory: a discovery entry with the
  # catalog and links into the dependency. No workflow body is copied.
  defp pointer_path("claude"), do: ".claude/skills/elixir-agent-kit/SKILL.md"
  defp pointer_path("codex"), do: ".agents/skills/elixir-agent-kit/SKILL.md"
  defp pointer_path(_generic), do: nil

  defp pointer_document(config, target) do
    """
    ---
    name: elixir-agent-kit
    description: "Use first, before opening source files to change behavior or review code in this Elixir project, when the task matches a shared workflow: screens and accessibility, data and migrations, provider calls, asynchronous or process state, performance, tests, code review, debugging, build or delivery. Routes to the versioned Elixir Agent Kit read from the Mix dependency."
    ---

    """ <> entry(config, target)
  end

  defp start_document(config, target), do: entry(config, target)

  # START.md and the pointer skills share one body: five steps that end in a named
  # workflow choice, then the enabled catalog with links into the dependency, so a
  # session that opens either file leaves it with one SKILL.md path in hand.
  defp entry(config, target) do
    """
    # Elixir Agent Kit #{ElixirAgentKit.version()}

    Before opening any source file for a change or a review:

    1. Name the task's primary risk in one line, from the request alone: a screen,
       stored data or a provider call, code quality or process state, an operational
       domain, or delivery. Then name its size (small, medium or large), revising it
       after the first inspection when the code shows otherwise.
    2. Pick one workflow from the tables below. When two neighbors fit, the
       [routing guide](#{target}/ROUTING.md) separates them. A bounded, fully specified
       edit picks NONE.
    3. Read that workflow's SKILL.md from the dependency together with the
       [shared contract](#{target}/CONTRACT.md); copy neither into this project.
    4. State the workflow ID or NONE and the size in your reply or report, with the
       reason in one line and the workflow's `Start at` input as the first thing you
       open; then investigate the way the workflow says, producing the artifact its
       first step asks for. The local contracts say what this project must do; the
       workflow says how to inspect, decide and prove it.
    5. For a large task, before the first edit, write the plan from the
       [task-plan template](#{target}/templates/task-plan.md) in
       `.elixir-agent-kit/plans/`, following the contract's
       [planning rules](#{target}/CONTRACT.md#plan-in-proportion-to-size), and reread
       it after any compaction.

    Project rules and the user's authorized scope govern the work. Use the
    [Elixir context](#{target}/ELIXIR.md) only for technologies present here; send
    reusable improvements upstream through [practice evolution](#{target}/EVOLUTION.md).
    If a link is missing, run `mix deps.get` in this checkout. If your client cannot read
    ignored dependency files, report that limitation instead of claiming the practices
    were loaded. Generated by `mix agent_kit.sync`; do not edit.
    """ <> area_tables(config, target)
  end

  defp area_tables(config, target) do
    enabled =
      Enum.filter(ElixirAgentKit.catalog(), &(config.skills == ["all"] or &1.id in config.skills))

    Enum.map_join(ElixirAgentKit.areas(), "", fn {area, title} ->
      case Enum.filter(enabled, &(&1.area == area)) do
        [] ->
          ""

        skills ->
          rows =
            Enum.map_join(skills, "", fn skill ->
              "| [#{skill.id}](#{target}/skills/#{skill.id}/SKILL.md) | #{skill.mode} | #{skill.description} |\n"
            end)

          "\n## #{title}\n\n| Workflow | Default mode | Use when |\n|---|---|---|\n" <> rows
      end
    end)
  end

  # Claude Code reads AGENTS.md only while no CLAUDE.md applies, so a Claude block
  # imports AGENTS.md whenever the kit manages it or the project already has one.
  # Otherwise creating CLAUDE.md would silently hide the project's instructions.
  defp block("claude", config, root) do
    others = Enum.any?(config.agents, &(&1 != "claude"))
    agents_md = read_text(root, "AGENTS.md") != nil

    cond do
      imports_agents?(root) and others -> wrap(imported_note())
      imports_agents?(root) -> wrap(reference())
      others -> wrap(import_agents())
      agents_md -> wrap(import_agents() <> "\n" <> reference())
      true -> wrap(reference())
    end
  end

  defp block(_agent, _config, _root), do: wrap(reference())

  # A CLAUDE.md that already imports AGENTS.md outside the managed block must not
  # receive a second import.
  defp imports_agents?(root) do
    case read_text(root, "CLAUDE.md") do
      nil ->
        false

      contents ->
        outside = remove_block(contents, extract_block(contents, "CLAUDE.md")) || ""
        Regex.match?(~r/^@AGENTS\.md[ \t]*$/m, outside)
    end
  end

  defp imported_note do
    "This file already imports AGENTS.md, which carries the kit entry and governs the work.\n"
  end

  defp wrap(body), do: @start <> "## Elixir Agent Kit\n\n" <> body <> @finish

  defp reference do
    "Before opening any source file for a change or a review, select one workflow from\n" <>
      "[.elixir-agent-kit/START.md](.elixir-agent-kit/START.md) and name it, or NONE for a bounded,\n" <>
      "fully specified edit; then read the workflow with its shared contract alongside this project's\n" <>
      "own contracts, and investigate the way the workflow says. This project's rules keep precedence.\n" <>
      "If the files are missing, run `mix deps.get`; if you cannot read them, report that instead of\n" <>
      "claiming the practices were applied.\n"
  end

  defp import_agents do
    "Claude Code reads AGENTS.md only when no CLAUDE.md applies, so this block imports it.\n" <>
      "This project's instructions in AGENTS.md govern the work.\n\n@AGENTS.md\n"
  end

  defp plan(root, desired, previous, action) do
    paths = (Map.keys(desired) ++ Map.keys(previous)) |> Enum.uniq() |> Enum.sort()

    Enum.reduce(paths, [], fn path, changes ->
      safe_path!(root, path)
      raw = read(root, path)
      current = normalize_text(raw)
      old = previous[path]
      new = desired[path]
      kind = if new, do: elem(new, 0), else: elem(old, 0)
      owned = if kind == :block, do: extract_block(current, path), else: current

      if action != :check do
        cond do
          old == nil and owned != nil ->
            fail!("unmanaged content at #{path}; nothing was written")

          old != nil and owned != nil and not recorded?(owned, elem(old, 1)) ->
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
              else: (current || "") <> separator(current) <> value
        end

      # A block keeps the line endings of the file it lives in; owned files are
      # compared after normalization, so a checkout that converted them is not drift.
      if kind == :block and crlf?(raw),
        do: put_change(changes, path, raw, to_crlf(contents)),
        else: put_change(changes, path, current, contents)
    end)
  end

  # Installs before 0.6 hashed the block together with the two newlines that
  # preceded it, so an upgrade from such a state must still recognize the block.
  defp recorded?(owned, hash), do: digest(owned) == hash or digest("\n\n" <> owned) == hash

  # The blank line between the user's text and the block belongs to the user's
  # text, so the block is found and hashed from marker to marker whatever
  # surrounds it, and the file gains no leading or repeated blank lines.
  defp separator(nil), do: ""
  defp separator(""), do: ""

  defp separator(contents) do
    cond do
      String.ends_with?(contents, "\n\n") -> ""
      String.ends_with?(contents, "\n") -> "\n"
      true -> "\n\n"
    end
  end

  defp crlf?(nil), do: false
  defp crlf?(contents), do: String.contains?(contents, "\r\n")

  defp to_crlf(nil), do: nil

  defp to_crlf(contents),
    do: contents |> String.replace("\r\n", "\n") |> String.replace("\n", "\r\n")

  # Managed text is compared with LF endings and a final newline before the end
  # marker, so an editor that converts endings or strips the last newline leaves
  # the block recognizable instead of "malformed".
  defp normalize_text(nil), do: nil

  defp normalize_text(contents) do
    contents = String.replace(contents, "\r\n", "\n")

    if String.ends_with?(contents, "<!-- elixir-agent-kit:end -->"),
      do: contents <> "\n",
      else: contents
  end

  defp read_text(root, path), do: normalize_text(read(root, path))

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
    [before, rest] = String.split(contents, block, parts: 2)
    # Drop the blank line the installer added before the block, never the user's own newline.
    before = String.replace(before, ~r/\n{2,}\z/, "\n")

    case before <> rest do
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
    case read_text(root, @state) do
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
                path == @plans_ignore or
                path in [pointer_path("claude"), pointer_path("codex")] or
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

  defp write(root, path, nil) do
    File.rm!(Path.join(root, path))
    prune_empty_dirs(root, Path.dirname(path))
  end

  defp write(root, path, contents) do
    full = Path.join(root, path)
    File.mkdir_p!(Path.dirname(full))
    File.write!(full, contents)
  end

  # Only directories left empty by a removal go away; anything with content stays.
  defp prune_empty_dirs(_root, "."), do: :ok

  defp prune_empty_dirs(root, dir) do
    case File.rmdir(Path.join(root, dir)) do
      :ok -> prune_empty_dirs(root, Path.dirname(dir))
      {:error, _reason} -> :ok
    end
  end

  defp digest(contents), do: :crypto.hash(:sha256, contents) |> Base.encode16(case: :lower)
  defp fail!(message), do: raise(ArgumentError, message)
end
