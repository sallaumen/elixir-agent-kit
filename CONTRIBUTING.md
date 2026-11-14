# Contributing

Issues and focused pull requests are welcome. Describe the concrete problem,
expected behavior and evidence. Keep contribution examples free of credentials,
private product details and customer data.

## Development

Use Elixir 1.15+ with a compatible Erlang/OTP. No database or API key is needed.

```sh
mix check
python3 scripts/check_library.py
python3 scripts/smoke_install.py
python3 scripts/smoke_migration.py
mix hex.build --output elixir_agent_kit-local.tar
python3 scripts/check_package_links.py elixir_agent_kit-local.tar
```

`mix check` checks formatting, compiles with warnings as errors and runs ExUnit
in the test environment. The library check validates metadata, provenance coverage
and local Markdown references. The smoke test builds a disposable consuming Mix
project, installs from a local path, checks repeatability, and uninstalls. It cleans
up its temporary project. The migration smoke fetches public v0.1.1 over the
network and checks migration, conflict refusal and preservation in a disposable project. `mix hex.build` creates a local tarball; it does not publish.

Use branches and pull requests after initial repository bootstrap. Stage only the
files you changed. Avoid unrelated refactors and preserve other contributors' work.

## Source ownership

Edit reusable guidance only in `priv/library/`. Applications contribute sanitized,
evidence-backed improvements through [the evolution policy](priv/library/EVOLUTION.md).
Keep product rules in their application and never edit a downloaded dependency.

## Workflow changes

Start with a specific trigger and compare neighboring workflows in the
[routing guide](priv/library/ROUTING.md). Preserve the shared contract rather
than copying its rules into every skill. Use standard `name` and `description`
frontmatter, a clear mode, task-specific inputs and decisions, quality criteria,
validation evidence, pitfalls, workflow and completion test. Do not expand text
just for length or import universal style preferences from a reference skill.
Update the primary area in `priv/library/catalog.tsv`, `CATALOG.md`,
[the 38-workflow review](docs/source-review.md), provenance and relevant tests.
Keep routing cases in `evals/`; never ship evaluator answers as workflow context.
Do not add a skill merely for a synonym of an existing workflow.

For installer changes, cover preservation and failure behavior as well as the
happy path. No forced overwrite, hidden model calls or global client mutations.

## Validation and releases

CI runs the same local checks, plus the declared minimum/current runtime matrix.
It also installs the exact tested revision as a Git dependency in a disposable
consumer with a custom dependency directory containing spaces and parentheses,
moves the consumer to another path, and refetches dependencies. The committed
index must still resolve without being regenerated. To reproduce after committing:

```sh
python3 scripts/smoke_install.py --git-url "$(pwd)" --ref "$(git rev-parse HEAD)" --deps-path "vendor/deps (shared)"
```

This uses a local Git clone; the separate v0.1.1 migration smoke needs network access.

If Actions is unavailable due to account or runner problems, run every local gate,
record the exact environment and limitation, and do not claim remote validation.

The maintainer publishes a reviewed version by updating `mix.exs`, `CHANGELOG.md`
and the installation examples, running all checks, creating an immutable `vX.Y.Z`
tag and a GitHub release. Validate an actual Git dependency fetch from that tag.
Do not move a published tag. Hex publication is a separate step. Build the guides and Mix task reference with
a current Elixir toolchain (the documentation dependency is only loaded in the
`docs` environment):

```sh
MIX_ENV=docs mix deps.get
MIX_ENV=docs mix docs --warnings-as-errors
```

Open `doc/index.html` and check both installation guides. Before publishing,
set `export DOCS_SOURCE_REF=$(git rev-parse HEAD)` in the clean checkout so
source links point to the exact revision containing those guides. For a new package
release, use `MIX_ENV=docs mix hex.publish` from the reviewed release checkout.
To publish or correct **only** the docs for an existing package version, use
`MIX_ENV=docs mix hex.publish docs` against matching library code. Verify the
versioned guide on HexDocs; neither command requires editing a consumer project.
