# Architecture

## Distribution and ownership

One Mix project contains CLI tasks, an installer and canonical `priv/library/`
guidance. No application callback, supervision tree, database, model client or
third-party dependency is installed. `:crypto` supplies ownership checksums.

Consumers pin an immutable tag and commit the lockfile. Mix downloads the source;
agents read it directly from the dependency. `catalog.tsv` owns workflow metadata
(ID, mode, trigger and primary area), `ROUTING.md` explains area choice,
`CATALOG.md` is the grouped human index, `skills/` contains the workflow bodies, and
`ELIXIR.md` indexes the per-technology references in `elixir/`. Shared
improvements go upstream through [the evolution policy](../priv/library/EVOLUTION.md).
Product-specific contracts stay with their applications.

## Reference-only installation

The installer writes a small `START.md`, a state file, and bounded blocks in
`AGENTS.md` and/or `CLAUDE.md`. A Claude block imports `AGENTS.md` when the kit
manages that file or the project already has one, because Claude Code stops
reading `AGENTS.md` as soon as a `CLAUDE.md` applies; a Claude-only install
without `AGENTS.md` carries the reference itself. For `:claude` and `:codex` it
also writes one pointer skill in the client's native skill directory, holding a
discovery description, the selected catalog and relative links into the
dependency; it creates no library copies and no per-workflow wrappers, and
removal prunes only directories the kit itself emptied.
It also owns `.elixir-agent-kit/plans/.gitignore`, which ignores the folder's
contents so large tasks can keep a plan there across compaction without the
installer editing the project's `.gitignore`; uninstall removes that file and
keeps any plan beside it. A block is found and
hashed from its start marker to its end marker; the blank line between the user's
text and the block belongs to the user's text, and the block keeps the line
endings of the file it lives in, so a CRLF checkout, a linter that trims blank
lines or a stripped final newline is not drift.
Configuration selects instruction adapters and workflow IDs for routing. It does
not prevent reading other workflows. Clients must load project instructions and
be able to read the ignored dependency directory after `mix deps.get`.

Mix resolves custom dependency paths. Git dependencies normally generate relative,
portable links; an external local path dependency needs a machine-local absolute
link and resync after relocation. Markdown destinations encode special characters.

`outdated` is an explicit network read using Git to list official stable version
tags; it never updates files. `check` remains offline. Neither command is a
background monitor. A failed remote query means freshness is unknown.

## Reconciliation and migration

`install` and `sync` reconcile desired and previously owned paths before writing.
Schema 1 state stores package version, adapter/skill selection, path, kind,
SHA-256 and origin. It remains compatible with 0.1 ownership records so migration
can remove obsolete copied payload and wrappers safely. State is data, not code.

Unknown collisions, modified owned content, malformed markers/state, unsafe paths
or symlinked outputs cause an error. Local text outside managed blocks survives.
Unmodified obsolete owned files are removed; unowned files and pre-existing empty
instruction files survive. `uninstall` uses the same preflight; `check` reports
drift without writes.

This is a single-writer development tool, not a concurrent filesystem transaction.
Interrupted writes require restoring the previous state and generated content
from version control. Checksums detect accidental drift, not an attacker changing
both files and ownership records.

## Other rule installers

[UsageRules](https://usage-rules.hexdocs.pm/readme.html) and project-specific skill
installers can coexist when they own separate files or blocks. Do not configure
another installer to overwrite this kit's managed references. The kit does not
replace dependency API documentation or a client's search tools.
