# Architecture

## Distribution boundary

One Mix project contains CLI tasks, an installer and a self-contained `priv/library`
payload. There is no application callback, supervision tree, database, model client
or third-party runtime dependency. `:crypto` supplies SHA-256 checksums.

Consumers pin a Git tag and commit `mix.lock`. The installed snapshot is checked
in so guidance can be read before running Mix. Each package version owns its
payload; there is no runtime download of prompts and no background update.

The current public workflows are an English community adaptation. They are not
live mirrors of an application repository; changes are reviewed here. See
[provenance](provenance.md) for the original-to-public mapping.

## Source and generated content

Canonical workflow bodies live in `priv/library/skills/`; `catalog.tsv` stores
selection metadata. `CATALOG.md` is the human index. Tests validate unique IDs,
required sections and installed local links. Keep catalog metadata and skill
frontmatter aligned when contributing.

The installer copies the whole library and generates a selected `START.md`,
short native skill entry points and managed instruction blocks. It stores schema,
version, adapter selection, skill selection, ownership and SHA-256 checksums in
`.elixir-agent-kit/state.tsv`. The manifest is parsed as data, never evaluated.
Selection is a discovery preference, not a confidentiality boundary.

## Reconciliation and preservation

`install` and `sync` share one reconciliation path. Desired and previous inventory
are compared before writes. Unknown collisions, modified owned content, malformed
markers, unsafe paths and symlinked outputs cause an error. Unchanged files are
not rewritten. Removing an adapter or selection prunes only its unmodified owned
entry points. Local text before and after instruction blocks is preserved exactly.

`check` compares current content with the configured package without writing.
`uninstall` removes recorded content only after preflight. Unrelated files and
pre-existing empty instruction files remain. Empty directories may remain.

This is a single-writer development tool, not an adversarial concurrent filesystem
transaction. Filesystem errors or interruption during writes can leave partial
output; restore the last committed snapshot and state before retrying. Ownership
records detect drift, not malicious changes to both content and the manifest.

## Relationship to usage_rules

[UsageRules](https://usage-rules.hexdocs.pm/readme.html) is an existing Elixir tool
for distributing dependency rules and skills. This initial implementation uses a
small direct installer to keep one ownership manifest across multiple client
locations and the shared library snapshot, with no third-party dependencies.
It does not replace UsageRules' dependency documentation or search capabilities.

Both tools can coexist if they own separate files/sections. Do not configure
another tool to overwrite this kit's managed entries. A future adapter can use
UsageRules' package-skills interface once shared-contract paths and ownership
semantics are covered by integration tests.
