---
name: migration-compatibility
description: "Use when stored schemas, identifiers, jobs or public payloads must survive a version change."
---

# Migration Compatibility

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when stored schemas, identifiers, jobs or public payloads must survive a version change.

## Inputs to inspect

- Existing schemas, persisted jobs, serialized IDs/module names, public payloads, old records and active reader/writer versions.
- Deployment order, migration policy, backup/restore procedure and concurrent operations.

## Workflow

1. Inventory readers, writers and persisted representations, including queued jobs and serialized module names. Determine which old and new versions may coexist.

2. Plan an expand/migrate/contract sequence when immediate replacement would break live consumers. Specify backfill, validation and recovery behavior.

3. Assess locks, data volume, duplicate processing and irreversible operations before running a migration. Planning does not authorize destructive production changes.

4. Test representative old data and mixed-version interactions. Document the supported rollback boundary and verify post-migration invariants.

## Decision points

- When old and new binaries may coexist, choose an expand/read-both/write-compatible/contract sequence appropriate to the real contract.
- Separate schema evolution from data repair or destructive cleanup where project policy requires distinct authorization.

## Quality criteria

- Old records remain readable and new writes do not break active old readers during the coexistence window.
- Persisted worker names, arguments, event keys and URLs are included; a source rename alone is not a complete migration.
- Compatibility adapters have an explicit removal condition after all relevant consumers have moved.
- Rollback limits account for irreversible data shape changes and external effects; code rollback alone is not a recovery plan.

## Validation and evidence

- Exercise representative new, legacy, incomplete and interrupted records against both supported reader/writer versions when possible.
- Provide an ordered rollout, data check, cleanup criterion and what was actually verified versus assumed.

## Avoid

- Do not rename a persisted worker by search-and-replace.
- Do not treat an untested backup as proof that a destructive migration is reversible.

## Completion

A compatible transition with evidence for historical data and a practical rollout/recovery plan.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
