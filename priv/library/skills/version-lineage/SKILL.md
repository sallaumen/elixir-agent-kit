---
name: version-lineage
description: "Use when revisions, previews, selections or generated artifacts are associated with the wrong version."
---

# Version Lineage

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when revisions, previews, selections or generated artifacts are associated with the wrong version.

## Inputs to inspect

- The exact user-visible behavior or artifact, its source commit, branch, release or deployed version.
- Generated files, dependency locks, caches, persisted records and any other layer that can show a different revision.

## Workflow

1. Identify stable entity identity, immutable revision identity and the mutable selected or published pointer. Trace creation, selection, preview and publication separately.

2. Inspect how asynchronous results and assets record their parent revision, inputs and provenance. A late result must not silently replace a newer selection.

3. Make browsing read-only with respect to selection unless the product explicitly defines otherwise. Distinguish available, selected and published versions in both storage and presentation.

4. Exercise refresh, concurrent creation, stale completion and rollback. Preserve historical associations during a migration.

## Decision points

- Identify whether the question is about current checkout, remote main, a tagged package, a running deployment or an older stored result.
- Prefer immutable identifiers and explicit timestamps over words such as latest or current when evidence differs.

## Quality criteria

- Every claim about “the version” names the layer it describes and the identifier used to verify it.
- A dependency pin, installed code and generated index are checked as separate states.
- User-visible content is traced to the actual source or build artifact, including a stale-cache possibility.
- A fix that updates source also updates its distribution and migration path when required.

## Validation and evidence

- Show the relevant commit/tag or package reference and one runtime or generated artifact check.
- Record mismatches and exactly which refresh or rollout will reconcile them.

## Avoid

- Do not infer deployed behavior from local main.
- Do not call a cache refresh a source change.

## Completion

A consistent version lifecycle with traceable artifacts and independent viewing/selection. This workflow concerns product revisions, not dependency upgrades.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
