---
name: data-contracts
description: "Use when layers disagree about data, rules are duplicated or a write leaves records inconsistent."
---

# Data Contracts

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a LiveView form accepts a value the changeset later rejects, or renders a field the schema no longer stores; when the same rule ("a draft has no published_at") is written in a `handle_event`, a context function and a changeset and they disagree on nullability, unit or default; when a context writes two records and a failure between them leaves one behind; when a PubSub payload, cached assign or denormalized counter shows a value different from the row it came from; or when an unknown value reaches the database as `0` or `""`.

This workflow answers "who owns this field and does every layer agree with the owner". When the disagreement is between two versions of the shape (a column rename, a changed job argument, an enum value that old rows still carry) hand it to [migration-compatibility](../migration-compatibility/SKILL.md). When the disagreement is about which actor may read or write the data, hand it to [security-boundaries](../security-boundaries/SKILL.md). When the disagreement is between messages in time (a stale result overwriting a newer one) use [async-state](../async-state/SKILL.md). One function mixing a rule with transport mechanics, without any ownership conflict, is [abstraction-layers](../abstraction-layers/SKILL.md).

## Size

- **Small**: give one field one owner and one test through the owning boundary; skip the full ownership table for the other fields.
- **Medium**: run the workflow as written for one field or one flow: the ownership table, the mismatch reproduction and the owning-boundary test.
- **Large**: several fields or a whole context disagree; slice per field, and hand a stored shape that must survive a version change to migration-compatibility as a later slice.

## Inputs to inspect

- Start at: the field named in the report or in the failing test, then `grep -rn "field_name" lib/ test/` to list every module that reads or writes it.
- The Ecto schema and every changeset that casts or validates the field, and the migration that created the column with its constraints and default. See [Ecto and migrations](../../elixir/ecto.md).
- The context functions that write it and the `Ecto.Multi` or `Repo.transact/2` around them, including what runs after commit.
- The LiveView assigns, form and `handle_event` clauses that pass the value in and out, and what the view shows when the value is missing. See [Phoenix and LiveView](../../elixir/phoenix-liveview.md).
- Derived copies: denormalized columns, ETS or assign caches, PubSub payloads, Oban job args and outward API responses that carry the same value. See [Oban](../../elixir/oban.md).
- Tests that touch the field, and which layer each one exercises; note whether any test feeds form params through to the row.

## Workflow

1. Write the ownership table for the chosen field, one row per field, invariant or state transition in scope: field, owner (the module and function allowed to decide its value), consumers (every reader with its path), invariant (type, nullability, unit, allowed transitions). This table is the artifact every later step reports against. Done when every grep hit is in a row and each row has exactly one owner or is marked "contested".

2. Compare the actual value at each hop of a contested row: type, nullable, identifier form, unit, default, error shape. Record each mismatch in the table, for example string in the form, integer in the schema, `0` in the view when the row holds `nil`. Done when every contested row has a named mismatch or is cleared.

3. Reproduce one mismatch with a failing test at the owning boundary, not in the view: feed form params through the context to the row and assert what was persisted. Done when the test fails for the stated reason.

4. Move the rule to its owner: validation in the owning changeset, a database constraint behind it when concurrent writers can race, presentation guesses removed from persisted writes, and each derived copy given an explicit refresh or recompute path. Keep related writes in the atomic unit and the external-effect ordering the decision point defines. Done when the rule exists once and the test from step 3 passes.

5. Update the consumers listed in the table: assigns, payloads, job args, cache keys and responses. Done when every consumer reads the owner's value or a copy whose origin and version are recorded.

6. Run the focused tests, add a partial failure inside the transaction and a concurrent write against the constraint, then run the project gate. Done when the ownership table matches the code and the report lists what was not exercised.

## Decision points

- One owner per field; a derived copy carries its origin and version or is recomputed, and is never edited in place.
- Changeset validation for useful errors; database constraints for anything that must survive concurrent writers; both when the constraint message must reach the user.
- Unknown stays unknown: `nil` or an explicit status, never `0`, `""` or a value guessed in the view.
- Related local writes in one transaction; an external effect after commit with an idempotency key, or a written compensation step, because a rollback cannot undo it.
- A change to a stored shape that old rows, queued jobs or a running release still read stops here and goes to [migration-compatibility](../migration-compatibility/SKILL.md) before any write.

## Quality criteria

- Every in-scope field has exactly one owner in the table and the code matches the table.
- A rule is written once; other layers delegate to it or display its result, and no two layers can disagree about nullability, unit or default.
- Related local writes remain atomic; external effects have explicit idempotency or compensation.
- Consumers agree on identifiers, units, optionality and state transitions, including old records and missing fields.
- Caches, payloads and events carry a known origin and version so a stale or out-of-order copy cannot become authoritative.

## Validation and evidence

- Minimum: one test through the owning boundary that feeds form params to the row, asserting the persisted value and the rendered value for one valid and one invalid input.
- When turns allow: a partial failure inside the `Ecto.Multi` asserting no orphan record, and a concurrent write against the database constraint under `Ecto.Adapters.SQL.Sandbox`. See [ExUnit and diagnostics](../../elixir/exunit.md).
- When a PubSub payload or Oban job argument changed: a consumer test with the new shape and one with an old-shaped message still in flight.
- When the field reaches a browser: a reload after the write showing the stored value, not the last assign.

## Avoid

- Do not fix the mismatch in the view or template; the view is a consumer, not the owner.
- Do not turn `nil` into `0`, `""` or `false` to make a render or a sum work.
- Do not add a second validation layer "for safety" that can drift from the first.
- Do not make one giant schema module the owner of unrelated business decisions.
- Do not change a persisted shape in this workflow when old rows or a running release still read it.

## Completion

An ownership table that matches the code, one owner per field, duplicated rules collapsed into the owning changeset or context, derived copies with a known origin, and a test through the owning boundary for a valid, an invalid and a partially failing write. For a shape change that must survive a version use [migration-compatibility](../migration-compatibility/SKILL.md); for a boundary that leaks data across actors use [security-boundaries](../security-boundaries/SKILL.md); for results arriving out of order use [async-state](../async-state/SKILL.md); for coverage gaps the table revealed use [test-strategy](../test-strategy/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
