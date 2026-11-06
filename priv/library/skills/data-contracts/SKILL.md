---
name: data-contracts
description: "Use when layers disagree about data, rules are duplicated or a write leaves records inconsistent."
---

# Data Contracts

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when layers disagree about data, rules are duplicated or a write leaves records inconsistent.

## Inputs to inspect

- The entry payload, domain rule, transformations, persisted schema, derived caches and outward response for a selected flow.
- Ownership decisions, existing constraints, callers, retries and partial-write history.

## Workflow

1. Trace a value across UI, API, domain logic, database and external services. Identify the authoritative owner for each field, invariant and state transition.

2. Compare actual types, nullable values, identifiers and error states. Do not turn unknown into zero or let presentation-layer guesses become persisted truth.

3. Move duplicated decisions to the appropriate boundary and validate inputs before effects. Use transactions for related local writes; describe external consistency and compensation explicitly.

4. Test the full affected flow, including an invalid input and a partial failure. If a schema or stored payload changes, apply the migration-compatibility workflow.

## Decision points

- Choose one canonical owner for a rule or value; derived copies need an explicit refresh or reconciliation path.
- Use application validation for useful errors and database constraints for races/invariants that must survive concurrent writers.

## Quality criteria

- Document accepted input, output, errors and side effects at each meaningful boundary without repeating the same rule in every layer.
- Related local writes remain atomic where required; external effects have explicit idempotency or compensation because a DB rollback cannot undo them.
- Consumers agree on identifiers, units, optionality and state transitions, including old records and missing fields.
- Caches and events have known origin/version so stale or out-of-order results cannot silently become authoritative.

## Validation and evidence

- Trace one valid record and one invalid or concurrent operation from entry to persisted and presented result.
- Test the boundary that owns the guarantee, plus a real consumer; explain any incomplete cross-system transaction.

## Avoid

- Do not choose the UI display as a substitute for stored integrity.
- Do not make a single giant schema module the owner of unrelated business decisions.

## Completion

Explicit ownership and consistent boundary behavior, supported by a representative integration test or reproducible evidence.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
