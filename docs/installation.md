# Install Elixir Agent Kit

[Português](instalacao.md)

In an Elixir 1.15+ Mix project, add this entry to the list in `deps/0`:

```elixir
{:elixir_agent_kit, "~> 1.2", only: [:dev, :test], runtime: false}
```

For Codex and Claude Code, add this entry to the keyword list in `project/0`:

```elixir
elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all]
```

From the project root, run:

```sh
mix deps.get
mix agent_kit.install
mix agent_kit.check
```

When the check reports **no changes needed**, commit `mix.exs`, `mix.lock` and
the paths printed by the installer. Open a fresh agent session and ask it to
follow `.elixir-agent-kit/START.md` for a task in your project.

With no agent configuration, the default is `:generic` with all workflows.
To preview file changes, run `mix agent_kit.install --dry-run` before installing.
Keep the generated references in Git and leave `deps/` out. On a fresh checkout,
run `mix deps.get`; CI can then run `mix agent_kit.check` to detect drift.

## Update or switch from Git to Hex

Keep a single dependency entry. If migrating from Git, replace that entry with
the Hex example above and keep your existing agent and workflow selection.

```sh
mix deps.update elixir_agent_kit
mix agent_kit.sync --dry-run
mix agent_kit.sync
mix agent_kit.check
```

Review the diff and commit the lockfile and generated changes together.
`~> 1.2` allows releases from 1.2 up to (but excluding) 2.0. The lockfile
keeps ordinary installs reproducible; upgrading is an explicit dependency update.

## Install from Git instead

If you need an exact Git release, use this entry **instead of** the Hex entry,
then follow the same installation steps:

```elixir
{:elixir_agent_kit, git: "https://github.com/sallaumen/elixir-agent-kit.git",
 tag: "v1.2.2", only: [:dev, :test], runtime: false}
```
