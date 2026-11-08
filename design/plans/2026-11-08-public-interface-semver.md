# Public interface and versioning: implementation plan

**Goal:** Write down what is public interface under semver, the versioning and
deprecation policy, and an upgrade guide, and machine-check the one part that can
drift (the documented workflow IDs).

**Architecture:** A new `docs/versioning.md` is the single source.
`scripts/check_library.py` gains one check that the doc's "Stable workflow IDs"
block matches `priv/library/catalog.tsv`.

Spec: [public interface and versioning](../specs/2026-11-08-public-interface-semver-design.md).

## Global constraints

- Specs and plans live in `design/`; the deliverable documentation lives in
  `docs/` (which ships in the package). No em dash in `priv/library/`.
- Do not change installer, CLI or workflow behavior.
- Stage files by name; squash on merge.

---

### Task 1: The public-interface and versioning document

**Files:** `docs/versioning.md` (create), `docs/README.md` (link), `README.md`
(documentation list).

Write `docs/versioning.md` with four sections:

1. **Public interface** - an inventory with the exact values: the `project/0`
   key `:elixir_agent_kit` and its `:agents` (`:codex`, `:claude`, `:generic`)
   and `:skills` (IDs or `:all`) keys; the six Mix tasks with their flags
   (`install`, `sync`, `check`, `outdated`, `uninstall`, `list`, and the shared
   `--agents`, `--skills`, `--dry-run`, `outdated --check`); the generated
   consumer layout and the `priv/library/` layout; the `state.tsv` schema
   (`schema`, `version`, `agents`, `skills` header lines and `kind path sha256
   origin` rows); the block markers
   `<!-- elixir-agent-kit:start -->` / `<!-- elixir-agent-kit:end -->`; and the
   stable workflow IDs (a fenced block of the 38 IDs in catalog order).
2. **Versioning policy** - pre-1.0 and post-1.0 rules as decided.
3. **Deprecation policy** - rename/merge procedure and the 0.5.0 precedent.
4. **Upgrade guide** - pin, `deps.update`, `sync --dry-run`, `sync`, `check`,
   project gates, in that order.

### Task 2: Machine-check the workflow IDs

**Files:** `scripts/check_library.py`.

Extract the fenced text block directly after the `## Stable workflow IDs` heading
in `docs/versioning.md` and assert its non-empty lines equal `catalog.tsv` IDs as
a set (and count), emitting one error on drift. Run it to confirm it passes with
the real IDs and fails on a synthetic mismatch during a quick self-check.

### Task 3: Changelog and verification

**Files:** `CHANGELOG.md` (new `## Unreleased` bullet), then run the full gate:
`mix check`, `python3 scripts/check_library.py`, `python3 -m pyflakes scripts/`,
`python3 scripts/smoke_install.py`, `python3 scripts/smoke_migration.py`,
`mix hex.build` (delete the `.tar`). Push and open a PR.
