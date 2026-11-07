# Ecto and migrations

Part of the [Elixir context](../ELIXIR.md). Applies when `mix.lock` lists `ecto_sql`.

Inspect: which changeset owns each invariant, which guarantees live in database
constraints, transaction boundaries, preloads on the hot path, and how the schema
coexists with running code during deploy.

- Put domain validation in the context's changeset; use `unique_constraint/3`,
  `foreign_key_constraint/3` and `check_constraint/3` backed by real database
  constraints for races and invariants that must survive concurrent writers.
- Group related local writes in `Repo.transact/2` (Ecto 3.13+, which
  soft-deprecated `Repo.transaction/2`) or `Ecto.Multi`; a database rollback does
  not undo an external effect, so send effects after commit or make them
  idempotent. [Pipelines and control flow](pipelines.md) says which to pick and
  how to compose queries.
- Read a changeset's current value with `get_field/2` (change or data) and its
  pending change with `get_change/2`; never read `changeset.changes` directly for a
  rule that must also hold on update.
- Decompose composite results at the call site and let the changeset be the second
  opinion; a tuple written into a string column fails every row silently until a
  test feeds the whole path.
- Claim before an effect that must happen once: insert a claim row behind a
  unique index with `on_conflict: :nothing` and act only when the returned struct
  has an id (with a database-generated key, a skipped insert still answers
  `{:ok, struct}`, with `id: nil`); or move a status with a conditional
  `Repo.update_all/3` (`where: r.id == ^id and r.status == "proposed"`) and act
  only on `{1, _}`. A double click, a second tab or a second node then cannot run
  the effect twice.
- Creation from user input is idempotent by key: hash the owner, the kind of
  request and the normalized text into a stored key with a unique index, and
  answer a repeat with the existing record (`{:ok, record, :existing}`) instead of
  creating another.
- An upsert names the fields it replaces (`on_conflict: {:replace, [...]}` with
  `conflict_target:`); a field another writer owns, such as a state set by a
  separate process, stays out of the list so a periodic sync does not reset it.
- Preload what a loop reads (`Repo.preload/3`, `preload:` in the query); look for
  N+1 in logs before blaming the framework.
- Migrations: add indexes with `concurrently: true` plus
  `@disable_ddl_transaction true` and `@disable_migration_lock true`; set a
  `lock_timeout` for `ALTER TABLE` on busy tables; separate schema change
  (expand), backfill and cleanup (contract) into migrations that an older release
  can run against; never rename a column that a running release still reads.
- Renaming a schema module or field is a migration-compatibility task when the
  name is persisted anywhere (jobs, serialized terms, external payloads).

Verify: `Ecto.Adapters.SQL.Sandbox` with `async: true` where the test touches no
shared global state; one test through the persistence boundary with an invalid
input and one with a concurrent write (two claims of the same row, asserting one
effect); `mix ecto.migrate` and `mix ecto.rollback` on representative data before
claiming the migration is reversible.
