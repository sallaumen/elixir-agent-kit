---
status: approved
date: 2026-11-08
tags: [versioning, semver, deprecation, docs, public-interface]
---

# Public interface, semantic versioning and deprecation

## Problem

The kit has no written definition of what is public interface and therefore under
semantic versioning. A consumer cannot tell, from the changelog alone, what a
minor bump may change and what it never will. Renaming or merging a workflow
already happened in 0.5.0 (the `version-lineage` and `asset-lineage` merge into
`revision-lineage`, `test-consolidation` folded into `test-strategy`,
`responsive-mobile` renamed to `responsive-layout`), and the only record is a
changelog bullet and an implicit rule that a `skills:` selection naming a removed
ID fails `mix agent_kit.check`. The upgrade path is scattered across README and
EVOLUTION. Nothing machine-checks that documentation of the public interface
stays in sync with the code.

This is the 1.0 stability front. It changes no workflow text and no installer
behavior; it documents the contract and makes part of it machine-checked.

## Decisions

1. One document, `docs/versioning.md`, holds four parts: the public interface
   inventory, the semantic-versioning policy, the deprecation policy, and the
   upgrade guide. `docs/README.md` and the README documentation section link it.
2. The public interface under semver is: the `project/0` configuration keys
   (`:elixir_agent_kit` with `:agents` and `:skills`); the Mix task names and
   flags; the installed and generated file layout; the `state.tsv` format; the
   managed-block markers; and the workflow IDs.
3. Versioning: pre-1.0, a minor release may add a workflow, change a workflow
   body or the generated `START.md`, or add an installer-owned file, and a patch
   release changes no agent-facing guidance. Post-1.0, major is reserved for
   breaking changes (removing or renaming a workflow ID, changing a config key,
   the `state.tsv` schema or the block markers), minor for additive changes, and
   patch for bug fixes that leave the interface intact.
4. Deprecation: a workflow rename or merge is a breaking change to `skills:`
   selections. It lands in a minor (pre-1.0) or major (post-1.0) release with a
   changelog mapping old IDs to new IDs, and the removed ID makes
   `mix agent_kit.check` fail with the mapping in its message. No silent alias; a
   one-release alias is allowed only when a consumer needs time to migrate and is
   recorded with its removal condition.
5. Machine check: `scripts/check_library.py` extracts the "Stable workflow IDs"
   block from `docs/versioning.md` and asserts it equals the `catalog.tsv` IDs,
   so the documentation cannot drift from the catalog.

## Verification

- `python3 scripts/check_library.py` (new ID-drift check), `python3 -m pyflakes
  scripts/`, `mix check`.
- No installer or workflow change; the smoke and migration tests are unaffected
  but run as part of the full gate.

## Delivery

One pull request. No release of its own: `docs/` ships in the next 0.x that also
carries a code or library change.

## Out of scope

Frentes 1 and 2, live evaluations, and any change to installer, CLI or workflow
behavior beyond the machine check in `scripts/check_library.py`.
