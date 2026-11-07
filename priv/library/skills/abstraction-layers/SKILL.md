---
name: abstraction-layers
description: "Use when functions mix business decisions, low-level details and effects at incompatible levels."
---

# Abstraction Layers

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when one context function builds an Ecto query, calls an HTTP client, decides a business rule and broadcasts in a single body; when a LiveView `handle_event/3` contains pricing or eligibility arithmetic next to socket assigns; when a "helper" needs the socket, the repo and a provider client to compute one number; when a rule can only be tested by stubbing three collaborators; or when reading one operation means chasing five one-line wrappers across files.

The separating rule among the code workflows: one function, or a small cluster around one entry point, mixing a business decision with transport, persistence or effects is this workflow; which context should own that function is [architecture-review](../architecture-review/SKILL.md); a module whose name or public API is wrong while its content is sound is [module-design](../module-design/SKILL.md); two implementations of the same operation is [code-consolidation](../code-consolidation/SKILL.md). Ownership is assumed settled here.

## Inputs to inspect

- Start at: the public function named in the request or called by the failing test, then its body and each immediate callee, with `grep -n "def " lib/<path>` to list what else the module exposes.
- The callers of that function and what each expects back: the result shape, the error tuples, the broadcast or job it waits for.
- The effect inventory of the body: `Repo` writes, `Ecto.Multi` steps, broadcasts, HTTP calls, Oban inserts, messages to processes, with their order and the transaction they run in. See [Ecto and migrations](../../ELIXIR.md#ecto-and-migrations) and [Oban](../../ELIXIR.md#oban).
- The business decisions in the body and the inputs each one actually needs, as opposed to the structs it receives.
- The tests that protect the observable behavior today, and which collaborators they stub to reach the rule.

## Workflow

1. Write the level table for the chosen function: each statement or callee tagged as decision (a business rule), calculation (pure transformation), data access, effect (broadcast, HTTP, job, message) or mechanics (params parsing, socket, transport), with the vocabulary a reader needs at that line. This table is the artifact every later step reports against. Done when every line is tagged and the lines where levels change are marked.

2. Record the effect inventory from the table: count, order, error handling and transaction boundary of every effect. Done when the inventory is written and matches what the existing tests assert.

3. Extract the decisions and calculations into named domain functions that take plain values or structs and return values, with no repo, socket or client inside. Done when each extracted function has a unit test that needs no stub.

4. Reshape the entry function so it reads as one coherent operation at one level: load, decide, persist, notify. Keep the effects at the edge in the recorded order and inside the recorded transaction. Done when a reader follows the intent in the entry function without opening the extracted modules.

5. Compare the before and after call paths for one complete slice: the same effects, in the same count and order, with the same error propagation. Done when the existing behavior tests pass unchanged and no new wrapper exists only to forward arguments.

6. List consumers not yet migrated and the mixing points left in neighboring functions, then run the project gate. Done when the handoff names the old mixing point, the new boundary and why it earns its cost.

## Decision points

- Extract only when the new function shields a detail likely to change or lets the caller express a coherent domain operation; otherwise leave the lines in place.
- Decisions and calculations take values and return values; effects stay at the edge, in the entry function or a thin action layer, never inside the calculation.
- Actions, calculations and data are lenses for reading the table, not three mandatory directories or a new context.
- Keep co-changing details together; a parameter bundle of eight fields created to claim purity is worse than the original mix.
- Effect count, order, error handling and transaction semantics are frozen by step 2; any change to them is a separate, named decision.

## Quality criteria

- A reader follows the business intent in the entry function without decoding transport mechanics or chasing one-line wrappers.
- Function names describe an operation at one consistent level, and stable rules depend on lower-level details in a deliberate direction only.
- Each extracted calculation is tested without stubs; each effect is still asserted by the operation's existing tests.
- The effect inventory before and after is identical in count, order and transaction boundary.
- Inputs remain understandable; no parameter bundle exists only to satisfy purity.

## Validation and evidence

- Minimum: a unit test of the extracted calculation that needs no stub, plus the existing test of the operation's success and failure paths passing unchanged with the effects asserted in order.
- When turns allow: a before-and-after trace of one slice listing each effect and the transaction it runs in.
- When the entry function is a LiveView event: a `Phoenix.LiveViewTest` run of the event asserting the rendered result and the broadcast or push. See [Phoenix and LiveView](../../ELIXIR.md#phoenix-and-liveview) and [ExUnit and diagnostics](../../ELIXIR.md#exunit-and-diagnostics).
- When a consumer was not migrated: its name and the mixing point it still contains.

## Avoid

- Do not use line count, file count or new directories as proof of a better abstraction.
- Do not split a flow into layers that force a reader to jump across files for every simple decision.
- Do not move an effect into or out of a transaction, or change its order, while extracting a calculation.
- Do not create a bundle of unrelated parameters so a function can be called pure.
- Do not relocate the function to another context here; that is an [architecture-review](../architecture-review/SKILL.md) decision.

## Completion

One operation whose entry function reads at a single level, decisions and calculations extracted as tested pure functions, effects unchanged in count, order and transaction, and a written note of the old mixing point and the consumers still to migrate. For whole-system ownership use [architecture-review](../architecture-review/SKILL.md); for the module's name and public API use [module-design](../module-design/SKILL.md); for a duplicate implementation revealed by the extraction use [code-consolidation](../code-consolidation/SKILL.md); for the coverage the stubs were hiding use [test-strategy](../test-strategy/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
