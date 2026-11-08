# Public interface and versioning

This page is the contract for what changes between releases and what stays
compatible. It is the source for the [changelog](../CHANGELOG.md) and for the
[upgrade steps](#upgrade-guide). The architecture and reconciliation behavior are
described in [architecture](architecture.md); the client entry points in
[compatibility](compatibility.md).

## Public interface

Everything below is public and follows the [versioning policy](#versioning-policy).
Anything not listed here (internal module names, the installer implementation, the
generated pointer text) may change within a release without notice.

### Configuration keys

In `project/0` of `mix.exs`:

```elixir
elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all]
```

- `:agents` - a non-empty selection of `:codex`, `:claude`, `:generic`.
- `:skills` - the atom `:all` or a non-empty list of workflow IDs from
  [the stable IDs](#stable-workflow-ids).

When the `:elixir_agent_kit` entry exists it is the source of truth: a missing
`:agents` defaults to `[:generic]` and a missing `:skills` to `:all`. When the
entry is absent, the selection recorded in `.elixir-agent-kit/state.tsv` is kept.
An unknown configuration key fails every task.

### Mix tasks and flags

| Task | Effect | Flags |
|---|---|---|
| `mix agent_kit.list` | Print workflow IDs, modes and triggers grouped by area. | none |
| `mix agent_kit.install` | Create or synchronize references after a conflict preflight. | `--agents`, `--skills`, `--dry-run` |
| `mix agent_kit.sync` | The same reconciliation as `install`. | `--agents`, `--skills`, `--dry-run` |
| `mix agent_kit.check` | Offline drift comparison; fails on drift or a missing library file. | `--agents`, `--skills` |
| `mix agent_kit.outdated` | Query stable Git tags and report loaded versus latest. | `--check` |
| `mix agent_kit.uninstall` | Remove owned, unmodified references and state. | `--dry-run` |

`--agents` takes a comma-separated list of `codex`, `claude`, `generic`;
`--skills` takes a comma-separated list of workflow IDs. `check` refuses
`--dry-run` because it is already read-only; `uninstall` refuses `--agents` and
`--skills` because removal is not partial. No task starts the application or
calls a model.

### File layout

Installed library, read from the dependency, never copied into the project:

- `priv/library/CONTRACT.md`, `ROUTING.md`, `ELIXIR.md`, `EVOLUTION.md`,
  `HANDOFF.md`, `CATALOG.md`, `catalog.tsv`, `LICENSE`
- `priv/library/skills/<id>/SKILL.md` - one body per workflow ID
- `priv/library/elixir/*.md` - per-technology references
- `priv/library/templates/*.md` - decision, diagnosis, delivery-plan,
  practice-proposal, task-plan and validation templates

Generated in the consuming project:

- `.elixir-agent-kit/START.md` - the five steps and the enabled catalog
- `.elixir-agent-kit/state.tsv` - the ownership record
- `.elixir-agent-kit/plans/.gitignore` - ignores the plans folder's contents
- `AGENTS.md` and/or `CLAUDE.md` - bounded managed blocks
- `.claude/skills/elixir-agent-kit/SKILL.md` and
  `.agents/skills/elixir-agent-kit/SKILL.md` - generated pointer skills

### state.tsv format

```text
schema	1
version	<semver>
agents	codex,claude
skills	all
file	.elixir-agent-kit/START.md	<sha256>	created
block	AGENTS.md	<sha256>	existing
```

`schema` is `1`. `version` is the package version. `agents` and `skills` are the
comma-separated selection. Each following row is `kind`, `path`, lowercase
SHA-256 and `origin`; `kind` is `file` or `block`, `origin` is `created` or
`existing`. State is data, not code; the installer migrates earlier records.

### Managed-block markers

A managed block in `AGENTS.md` or `CLAUDE.md` is the text between
`<!-- elixir-agent-kit:start -->` and `<!-- elixir-agent-kit:end -->`. Text
outside the markers belongs to the project and survives every sync.

### Stable workflow IDs

The 38 workflow IDs are the only values a `skills:` selection may name, and they
are stable across compatible releases:

```text
ui-identity
layout-density
navigation-ux
responsive-layout
direct-interactions
accessibility
design-system
motion-design
data-contracts
migration-compatibility
security-boundaries
provider-calls
data-pipelines
architecture-review
abstraction-layers
module-design
code-consolidation
house-patterns
functional-refactoring
readable-code
test-strategy
code-review
debugging
performance
async-state
process-lifecycle
ai-orchestration
notifications
operational-alerts
integration-setup
metrics-costs
simulation-isolation
commercial-eligibility
revision-lineage
delivery-coordination
pipeline-design
build-dependencies
delivery-validation
```

## Versioning policy

Releases are public Git tags, never Hex. The version number follows semantic
versioning. The installed artifact is guidance plus a small installer, so the
meaning of a bump is stated in terms of what an agent reads and what a consumer
must do:

- **Pre-1.0 (current).** A minor release may add a workflow, change a workflow
  body, add an installer-owned file, or change the generated `START.md`. A patch
  release changes no agent-facing guidance: a bug fix in the installer or CLI, a
  documentation correction, or a check that does not alter what a workflow says.
- **1.0 and later.** Major is reserved for breaking changes: removing or renaming
  a workflow ID, changing a configuration key, the `state.tsv` schema or the
  block markers. Minor adds without breaking (a new workflow, a new flag, a new
  reference file). Patch fixes a defect while the interface is unchanged.

A change is breaking when a consumer who pinned an older tag and ran
`mix agent_kit.check` could now fail or read different guidance through the same
ID. The changelog states the bump and the reason for every release.

## Deprecation policy

A workflow rename or merge is a breaking change because a `skills:` selection
names IDs. The procedure, already followed in 0.5.0, is:

1. Land the rename or merge in a minor release pre-1.0, or a major release after
   1.0, together with the new workflow body.
2. List the mapping in the changelog, for example
   `asset-lineage`/`version-lineage` to `revision-lineage`,
   `test-consolidation` to `test-strategy`, `responsive-mobile` to
   `responsive-layout` (the 0.5.0 changes).
3. A `skills:` selection naming a removed ID fails `mix agent_kit.check` with the
   mapping, so the consumer updates the selection instead of silently losing the
   workflow.
4. Keep an alias only when a consumer needs time to migrate; an alias is a thin
   entry that points at the new workflow, recorded in the changelog with its
   removal condition and owner, and removed in the following compatible release.

No workflow ID is removed without this record, and no published tag is moved.

## Upgrade guide

1. Read the [changelog](../CHANGELOG.md); `mix agent_kit.outdated` tells whether a
   newer tag exists.
2. Change the tag in `mix.exs` and run `mix deps.update elixir_agent_kit`.
3. Run `mix agent_kit.sync --dry-run`, inspect the paths and removals, then
   `mix agent_kit.sync`.
4. Run `mix agent_kit.check` and the project's own gates; commit the diff.

A rename or merge in the release shows up at step 3 as a failing `skills:` ID;
replace it using the changelog mapping before syncing. Keep tags pinned; following
`main` makes identical project revisions behave differently.
