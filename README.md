# Elixir Agent Kit

**Shared coding practices for AI agents, versioned with your Elixir project.**

Install 33 focused workflows with Mix. Give Codex, Claude Code and file-reading
agent harnesses a common contract for architecture, debugging, testing, review,
UI work and delivery—without starting a service or calling a model.

[Quick start](#quick-start) · [Workflow catalog](priv/library/CATALOG.md) ·
[Install with an AI agent](docs/INSTALL_WITH_AI.md) ·
[Português](docs/README.pt-BR.md) · [Contributing](CONTRIBUTING.md)

## What you get

- 33 English workflows with clear triggers, modes and completion criteria.
- A shared execution contract and conditional Elixir/Phoenix/Ecto/Oban guidance.
- Native `SKILL.md` entry points for Codex and Claude Code; `AGENTS.md` routing for other harnesses.
- Project-local install, sync, read-only drift checks and conservative uninstall.
- SHA-256 ownership records, conflict detection and preservation of local instructions.
- Zero third-party Elixir dependencies. No API keys, model calls, telemetry or application startup.

This is a development tool. It does not execute skills, enforce model behavior,
or orchestrate agents. Installing files is not proof that a client loaded them.
See [compatibility and verification](docs/compatibility.md).

## Quick start

Requires Elixir 1.15+ and its supported Erlang/OTP runtime. Git is needed to fetch
the dependency. Version 0.1.1 is distributed through GitHub; it is **not published
to Hex**. The repository is public, so downloading it does not require a token.

Add to your existing `deps/0` in `mix.exs`:

```elixir
{:elixir_agent_kit,
 git: "https://github.com/sallaumen/elixir-agent-kit.git",
 tag: "v0.1.1",
 only: [:dev, :test],
 runtime: false}
```

Add this key to the keyword list returned by your existing `project/0`:

```elixir
elixir_agent_kit: [
  agents: [:codex, :claude, :generic],
  skills: :all
]
```

Choose only the clients you use. `:generic` writes an `AGENTS.md` entry;
`:codex` writes that entry plus `.agents/skills/eak-*/SKILL.md`;
`:claude` writes `CLAUDE.md` plus `.claude/skills/eak-*/SKILL.md`.
Selecting both `:codex` and `:generic` does not duplicate the entry.

Run from the project's Mix root:

```sh
mix deps.get
mix agent_kit.install --dry-run
mix agent_kit.install
mix agent_kit.check
```

No `mix setup`, database setup or application server is required by the kit.
A consuming project may define its own command aliases with additional effects;
inspect those before running them.

Review and commit the dependency, `mix.lock`, the managed sections of your agent
instructions, `.elixir-agent-kit/`, and the selected client skill files. Committing
the snapshot makes guidance available in fresh worktrees before dependencies are
fetched. Do not edit generated content: put local additions outside the managed
sections or in separate project documents.

Start a new client session in that checkout and ask it to select a workflow from
`.elixir-agent-kit/START.md`, read the contract, and explain which files it read.
For example: “Use eak-code-review to review this diff; remain read-only.”

## Choose a smaller set

The full library is a self-contained reference snapshot. Selection controls the
entry points and the enabled list, not an access-control boundary:

```elixir
elixir_agent_kit: [
  agents: [:codex, :claude],
  skills: ["architecture-review", "debugging", "code-review", "delivery-validation"]
]
```

Discover IDs with `mix agent_kit.list`. Run `mix agent_kit.sync` after changing
configuration. Without project configuration, the default is `:generic` and all
skills; later invocations reuse the saved selection. CLI flags override project
configuration for that invocation; prefer persistent project configuration for teams.

## Commands

| Command | Effect |
|---|---|
| `mix agent_kit.list` | Prints workflow IDs, default modes and triggers. |
| `mix agent_kit.install` | Creates or synchronizes managed guidance after checking every planned path. |
| `mix agent_kit.sync` | Same reconciliation as install, including removal of stale owned entry points. |
| `mix agent_kit.check` | Read-only comparison against the package and configuration; exits nonzero on drift. |
| `mix agent_kit.uninstall` | Removes unmodified managed content and its state record; retains unrelated content. |

Mutation tasks accept `--dry-run`. All reconciliation tasks accept
`--agents codex,claude,generic` and `--skills debugging,code-review`.
Unknown arguments are errors. Run uninstall **before** removing the dependency.
Empty generated directories may remain; existing empty instruction files are preserved.

## Update and recover

1. Read the target release's [changelog](CHANGELOG.md).
2. Change the tag in `mix.exs`, then run `mix deps.update elixir_agent_kit`.
3. Run `mix agent_kit.sync --dry-run`, inspect the plan, then run `mix agent_kit.sync`.
4. Run `mix agent_kit.check` and the project's required checks; review and commit the diff.

Unmanaged collisions and edited managed content stop mutations before any writes.
There is no `--force` overwrite switch. Move intentional additions into a local
project document, preserve your edits in version control, and restore the managed
file to its recorded version before syncing. For malformed or lost state, restore
the snapshot and `.elixir-agent-kit/state.tsv` together from version control;
do not delete the state file to bypass a conflict.

All output paths are project-relative. Symlinked output paths are refused.
Conflict preflight is not a filesystem transaction: do not run two installers
concurrently. An interrupted write or filesystem failure may require restoring
the previous committed snapshot before retrying.

## CI and isolated executors

After fetching dependencies, run `mix agent_kit.check` in `dev` or `test`.
Keep it read-only in CI; a stale snapshot should produce a reviewable change.
The dependency is excluded from production through `only: [:dev, :test]`.

Each isolated executor needs the committed snapshot or its own install step in
its checkout. For a DeepSeek-backed harness, use `:generic` and explicitly configure
the harness to read `AGENTS.md` or `.elixir-agent-kit/START.md`; the model name does
not determine its file-loading behavior. No global client configuration is changed.

## Why a separate package?

Practices should travel with a project revision and remain inspectable in Git.
The library is independent of any application, database, account or provider.
The installer owns only identified files and bounded instruction sections.
See [architecture](docs/architecture.md) for the design and the relationship to
[`usage_rules`](https://usage-rules.hexdocs.pm/readme.html).

## Community and status

This is an initial `0.1.1` release. Filesystem and packaging behavior are tested;
model compliance and live client execution are not certified. Contributions that
improve workflow clarity, portability and reproducible client evaluations are welcome.

- [Contributing and local checks](CONTRIBUTING.md)
- [Compatibility and evaluation procedure](docs/compatibility.md)
- [Security reporting](SECURITY.md)
- [Workflow provenance](docs/provenance.md)
- [MIT license](LICENSE)
