---
name: migration-compatibility
description: "Use when stored schemas, identifiers, jobs or public payloads must survive a version change."
---

# Migration Compatibility

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a column or schema field is renamed while a running release still reads the old name; when an Oban worker module is renamed and `oban_jobs` still holds rows with the old `worker` value; when an `Ecto.Enum` value or an atom inside a serialized term or jsonb column changes; when a new `NOT NULL` column needs a backfill on a large table; when a PubSub, webhook or API payload changes shape while an old node or client still consumes it; or whenever two versions of the application run at once during a rolling deploy.

This workflow moves a persisted representation from one shape to another with both versions live. Which layer owns the field and what its shape should be is decided first in [data-contracts](../data-contracts/SKILL.md); the release and deploy mechanics themselves belong to [build-dependencies](../build-dependencies/SKILL.md); the rollout gate is [delivery-validation](../delivery-validation/SKILL.md); and once the contract step has removed the old path, deleting the dead code and its tests is [code-consolidation](../code-consolidation/SKILL.md).

## Size

- **Small**: run only the expand step for one additive change (a new column or enum value) with a legacy-row test; skip the full expand, migrate, contract sequence.
- **Medium**: run the workflow as written for one persisted representation: the inventory, the coexistence window and the expand, migrate, contract sequence with its rollback boundary.
- **Large**: several representations or a whole schema and job rename; slice per representation, and decide the target shape in data-contracts first, the release mechanics in build-dependencies, and the dead-path removal in code-consolidation as later slices.

## Inputs to inspect

- Start at: the newest files in `priv/repo/migrations/` and the diff of schemas and workers, then `grep -rn "use Oban.Worker\|Ecto.Enum\|embedded_schema\|term_to_binary\|Jason.Encoder" lib/` to list every persisted name and shape.
- Each changed schema with its current column names, types, defaults and constraints, and the rows that already exist with the old shape. See [Ecto and migrations](../../elixir/ecto.md).
- Oban workers: which module names and argument keys are persisted in `oban_jobs`, including scheduled and retrying jobs that will run after the deploy. See [Oban](../../elixir/oban.md).
- Public payloads: PubSub messages, webhooks, API responses and exports, with the consumers that read them and their deploy timing.
- The deploy procedure: rolling or all-at-once, whether migrations run before or after the new release starts, and the backup and restore policy. See [Build, dependencies and releases](../../elixir/build-releases.md).
- Existing tests that insert legacy-shaped data, and whether any test runs `mix ecto.rollback`.

## Workflow

1. Write the inventory table: representation (column, enum value, worker name, job argument key, payload key, serialized module), where it is persisted, writers by version, readers by version, and whether jobs or rows with the old shape exist. This table is the artifact every later step reports against. Done when every renamed or reshaped name in the diff is a row.

2. Define the coexistence window: which version pairs run at the same time (old release reading new rows, new release reading old rows, jobs enqueued by the old release performed by the new one). Done when each row says yes or no to "old reads new" and "new reads old".

3. Plan an expand, migrate, contract sequence per row that answered no: expand (add the column or enum value, keep the old worker module as an alias that delegates), migrate (batched backfill, dual write, read both), contract (drop the old path once no reader remains). Done when the sequence is written with its own migration file per step, the rollback boundary of each step, and a named condition for contract.

4. Assess each migration before running it: `concurrently: true` with the DDL transaction and migration lock disabled for indexes, a `lock_timeout` for `ALTER TABLE` on busy tables, batch size for the backfill, duplicate processing if the backfill is retried, and which step is irreversible. Done when destructive or irreversible steps are flagged for separate authorization and the rest have their options chosen.

5. Implement the expand and migrate steps with a test that inserts a legacy-shaped row (raw SQL or the old struct) and reads it with the new code, and, when the window requires it, a test that the new writer still produces what the old reader expects. Done when `mix ecto.migrate` and `mix ecto.rollback` succeed on representative data.

6. For persisted jobs, enqueue a job with the old worker name and old argument keys and perform it with the new code using `Oban.Testing`. Done when the old-shaped job succeeds exactly once.

7. Write the ordered rollout: migration, deploy, data check, contract criterion, and what was verified versus assumed. Done when the handoff names who removes the compatibility code and when.

## Decision points

- When old and new binaries coexist, expand first; a direct rename is allowed only when no running reader and no persisted row or job uses the old name.
- Separate schema change, data backfill and destructive cleanup into distinct migrations so an older release can still run against the expanded schema.
- A renamed worker keeps the old module as an alias until the queue drains or the `worker` column is migrated; a search-and-replace is not a migration.
- An enum or atom change is additive in the read path first: read both values, write the new one, remove the old reader last.
- Code rollback is not a recovery plan for a contracted schema; the rollback boundary is the last step whose data shape both versions read.

## Quality criteria

- Old rows remain readable and new writes do not break the old reader during the whole coexistence window.
- Persisted worker names, job arguments, event keys, URLs and serialized terms are in the inventory; nothing is renamed by text search alone.
- Every compatibility adapter has a written removal condition and an owner.
- Each migration states its lock behavior, batch size and reversibility; irreversible steps are explicitly authorized.
- The rollout order and rollback boundary are written where the deployer will read them.

## Validation and evidence

- Minimum: a test that reads a legacy-shaped row or performs an old-shaped job with the new code, plus `mix ecto.migrate` and `mix ecto.rollback` on representative data.
- When turns allow: a mixed-version test that the new writer's output is accepted by the old reader (old struct or old payload decoder) for every row that said yes to coexistence.
- When the backfill touches a busy table: a timed run of one batch on a copy with the chosen `lock_timeout`, and the observed duration recorded.
- When the session has no production data access: the statement of what was verified on fixtures versus assumed about volume.

## Avoid

- Do not rename a persisted worker, column or enum value by search-and-replace and ship it as one release.
- Do not run backfill and schema change in one migration, or inside the DDL transaction on a large table.
- Do not treat an untested backup as proof that a destructive migration is reversible.
- Do not drop the old path in the same deploy that introduces the new one.
- Do not decide the target shape here; that is a [data-contracts](../data-contracts/SKILL.md) decision made before this workflow starts.

## Completion

An inventory of every persisted representation touched, a coexistence window with an expand, migrate, contract sequence per row, migrations with explicit lock and reversibility decisions, a legacy-row and old-job test passing on the new code, and a written rollout with its rollback boundary and contract condition. For the release mechanics use [build-dependencies](../build-dependencies/SKILL.md); for the deploy gate use [delivery-validation](../delivery-validation/SKILL.md); for removing the old path after contract use [code-consolidation](../code-consolidation/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
