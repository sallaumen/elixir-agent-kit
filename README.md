# Elixir Agent Kit

**Shared coding practices for AI agents, versioned with your Elixir project.**

34 focused workflows grouped into frontend, backend, cross-cutting engineering
and delivery. Each names inputs, decisions, quality criteria and verification.
Install with Mix; agents read the library directly from the dependency. No copied
skill library, service, model calls or production dependency.

[Quick start](#quick-start) · [Choose a workflow](priv/library/ROUTING.md) ·
[Catalog](priv/library/CATALOG.md) · [Documentation map](docs/README.md) ·
[Install with an AI agent](docs/INSTALL_WITH_AI.md) ·
[Português](docs/README.pt-BR.md) · [Contributing](CONTRIBUTING.md)

## Quick start

Requires Elixir 1.15+, compatible Erlang/OTP and Git. Version 0.4.0 is distributed
through public GitHub tags, **not Hex**. No token is required.

Add to your existing `deps/0`:

```elixir
{:elixir_agent_kit,
 git: "https://github.com/sallaumen/elixir-agent-kit.git",
 tag: "v0.4.0",
 only: [:dev, :test],
 runtime: false}
```

Add to the keyword list returned by your existing `project/0`:

```elixir
elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all]
```

Run from the Mix project root, after checking for project aliases with extra effects:

```sh
mix deps.get
mix agent_kit.install --dry-run
mix agent_kit.install
mix agent_kit.check
```

The kit needs no database, app server or `mix setup`. Commit `mix.exs`, `mix.lock`,
the generated index/state and instruction blocks. Do not commit `deps/`.

## What remains in your project

| Path | Purpose |
|---|---|
| `.elixir-agent-kit/START.md` | Small index pointing to the dependency's contract and catalog. |
| `.elixir-agent-kit/state.tsv` | Version, selection and checksums of files/blocks owned by the installer. |
| `AGENTS.md` | A bounded reference block for Codex and generic harnesses. |
| `CLAUDE.md` | A bounded block for Claude Code. When the kit also manages `AGENTS.md`, or the project already has one, the block imports it with `@AGENTS.md` instead of repeating the reference. |
| `.claude/skills/elixir-agent-kit/SKILL.md` | One generated skill for Claude Code's native discovery (`:claude`): a description, the catalog filtered by your selection and links into the dependency. |
| `.agents/skills/elixir-agent-kit/SKILL.md` | The same generated skill for Codex (`:codex`). |

Existing project instructions outside those blocks remain unchanged. No workflow
bodies are copied into the project: the two generated skills hold only the
catalog and links, so a client that scans its native skill directory finds the
kit without a second copy of any practice. The library stays in
`deps/elixir_agent_kit/priv/library/` for a standard Git dependency. Custom
dependency paths are resolved by Mix; external local path dependencies produce
local absolute links and need resync after moving.

`:codex` and `:generic` share the same `AGENTS.md` block; `:claude` selects
`CLAUDE.md`. Claude Code reads `AGENTS.md` only while no `CLAUDE.md` applies, so
the Claude block imports `AGENTS.md` whenever that file is managed or already
exists; adding `AGENTS.md` later shows as drift until you sync. `:claude` and
`:codex` also generate one pointer skill each in the client's native skill
directory; `:generic` relies on `AGENTS.md` alone. These are instruction-file
adapters, not model integrations: no per-workflow skills or slash commands are
registered, and a pre-existing skill named `elixir-agent-kit` blocks installation
until you rename it.

A fresh checkout must run `mix deps.get` before reading the practices. A client
must be able to read ignored dependency files. Ask a fresh session to read
`AGENTS.md` or `CLAUDE.md`, follow the index, select a workflow and name the files
it actually read. A DeepSeek-backed harness must load these files in its actual
checkout; the model name alone does not establish support. See
[compatibility](docs/compatibility.md).

## Selection and commands

Start from the [area routing guide](priv/library/ROUTING.md), select the
narrowest applicable workflow from the [catalog](priv/library/CATALOG.md), and
read its quality and validation sections. Categories describe the primary work,
not ownership of an application directory. The default is `:generic` with all
skills. To narrow discovery, set
`skills: ["debugging", "code-review"]` in project configuration and sync.
Selection is guidance in the index, not an access-control boundary. With no
project configuration, subsequent commands reuse the recorded selection.

| Command | Effect |
|---|---|
| `mix agent_kit.list` | Prints workflow IDs, modes and triggers grouped by area. |
| `mix agent_kit.install` | Creates or synchronizes references after conflict preflight. |
| `mix agent_kit.sync` | Same reconciliation, including removal of unmodified legacy generated files. |
| `mix agent_kit.check` | Offline, read-only comparison against the loaded package and configuration; fails on drift. |
| `mix agent_kit.outdated` | Queries public stable Git tags; reports the loaded and latest versions without changing files. |
| `mix agent_kit.outdated --check` | Also fails when a newer stable tag exists; network failures always fail. |
| `mix agent_kit.uninstall` | Removes owned unmodified references and state, preserving local content. |

Reconciliation tasks accept `--agents codex,claude,generic` and `--skills ID,ID`;
mutation tasks also accept `--dry-run`. Unknown arguments fail. Prefer persistent
project configuration over invocation-only flags. Run uninstall before removing
the dependency. No task starts your application or calls a model.

## Upgrade from 0.1 or adopt a later release

1. Read the release's [changelog](CHANGELOG.md). Optionally query `mix agent_kit.outdated`.
2. Change the pinned tag in `mix.exs`; run `mix deps.update elixir_agent_kit`.
3. Run `mix agent_kit.sync --dry-run` and inspect the plan, then `mix agent_kit.sync`.
4. Run `mix agent_kit.check` and project-required checks; review and commit the diff.

For a 0.1 installation, sync removes the recorded `.elixir-agent-kit/library/`
files and `.agents/skills/eak-*` / `.claude/skills/eak-*` wrappers. This is a
migration to dependency references, not a second installation. Unowned files
survive; empty directories may remain. Do not remove similarly named user files
by glob or discard the ownership state before migrating.

Modified managed files, unknown collisions, malformed markers/state and symlinked
outputs block mutation before any writes. Preserve edits as local instructions or
an upstream proposal, restore their recorded originals from Git, then retry.
There is no force switch. Restore the state and generated files together after
an interrupted write; preflight is not a filesystem transaction. Use one writer.

## Keep one shared source

Reusable improvements belong in this repository's `priv/library/`. Product rules
stay in the consuming project. Use the [evolution policy](priv/library/EVOLUTION.md)
and [proposal template](priv/library/templates/practice-proposal.md) to send a
sanitized lesson upstream, release it, and adopt it in each application through a
pinned update PR. Do not edit `deps/` or generated files as a source.

Use `mix agent_kit.check` in development/CI after fetching dependencies. It checks
installation consistency, **not** latest-release freshness. Use `outdated` in an
explicit dependency-maintenance routine; no scheduler or silent auto-update is
installed. All consumers can share an editable source while adopting versions at
different times. See [architecture](docs/architecture.md).

## Community and validation

Zero third-party Elixir dependencies. No telemetry, global client configuration
or credential requirements. This tool supplies guidance; it does not enforce
model behavior. Structural tests and consumer smoke tests do not certify that a
live client followed the practices.

- [Contribution process and checks](CONTRIBUTING.md)
- [Compatibility and live evaluation](docs/compatibility.md)
- [Security reporting](SECURITY.md)
- [Workflow provenance](docs/provenance.md)
- [MIT license](LICENSE)
