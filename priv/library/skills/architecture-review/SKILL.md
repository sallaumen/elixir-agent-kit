---
name: architecture-review
description: "Use when changes cross many modules, rules repeat, dependencies cycle or domain ownership is unclear."
---

# Architecture Review

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when one feature change touches two contexts that call each other in both directions (`Accounts` calls `Billing`, which calls `Accounts`); when the same rule ("a draft cannot be published") is written in a LiveView, a context and an Oban worker; when a module under the web namespace builds Ecto queries or calls `Repo` directly; when nobody can say which context owns a table that three contexts write; or when `mix xref graph --format cycles` reports cycles among the modules in the change.

The separating rule among the code workflows: many modules, cycles or unclear ownership is this workflow; one module whose name, location or public API is wrong while its responsibility is already understood is [module-design](../module-design/SKILL.md); one function that mixes a business decision with transport, persistence or effects is [abstraction-layers](../abstraction-layers/SKILL.md); two implementations of the same thing, or a path nothing reaches, is [code-consolidation](../code-consolidation/SKILL.md). This workflow produces the ownership decision those three assume.

## Inputs to inspect

- Start at: the requested change (diff, issue or failing test), then `mix xref graph --format cycles` and `mix xref graph --sink <file> --only-nodes` for each touched module to see who depends on it.
- The `lib/` layout: contexts, web modules, workers and their namespaces, compared with the boundaries the README or docs claim.
- Each schema in the change, the table it maps, and every module outside its context that inserts or updates it. See [Ecto and migrations](../../ELIXIR.md#ecto-and-migrations).
- The entry points of one representative operation: router or `live_session`, controller or LiveView, context, job, PubSub broadcast, and the processes it starts. See [Phoenix and LiveView](../../ELIXIR.md#phoenix-and-liveview) and [OTP processes and supervision](../../ELIXIR.md#otp-processes-and-supervision).
- Existing decisions: ADRs, module docs, and the tests that encode a boundary (a context test that goes through the public API versus one that reaches into another context).

## Workflow

1. Write the ownership map: one row per table, schema or domain concept the change touches, with its owning context, the modules outside the owner that write it, the dependency edges between touched modules with their direction, and any cycle from `mix xref`. This map is the artifact every later step reports against. Done when every module in the diff appears in at least one row.

2. Trace one representative operation from entry point to persisted effect and output, including its failure and retry path, and compare the modules it crosses with the map. Record each finding as path or symbol plus the consequence for a real use case (a rule that can diverge, a write with two owners, a compile-time cycle that slows every change). Done when every finding has a named consequence.

3. Classify each finding as a structural risk visible in this change or a hypothetical future need, and keep only the first class in scope. Done when every finding carries one tag and the hypothetical ones are listed for the handoff.

4. Propose the smallest boundary correction per in-scope finding: one accountable owner for the data, a dependency direction (web depends on context, context depends on schema, never back), a cycle broken by moving one function or publishing an event instead of a call. Done when the proposal is an ordered list of bounded steps, each with the callers, callbacks, configuration and persisted jobs it must update.

5. Within the authorized scope, apply one correction and check its consumers before moving a public boundary: aliases, behaviours, supervisor children, configuration and `oban_jobs` worker names. Done when `mix compile --warnings-as-errors` passes and the cycle or duplicate owner no longer appears in `mix xref`.

6. Validate the affected contract with the existing tests of the traced operation and its failure path, then run the project gate. Done when the map is updated to the new state and the follow-ups are written with evidence.

## Decision points

- An owner is the context that writes the table; any other writer is a finding unless the project's documented decision says otherwise.
- Dependency direction is one way: web to context, context to schema and repo, jobs to context; a reverse edge is repaired by an event, a callback registered by the lower layer, or a function move.
- A rule repeated in two layers is collapsed into the owner; the other layer calls it.
- Repair now only when the risk is in the change and the fix is bounded; otherwise record the follow-up with the map and the consequence.
- Pages are not domains, line counts are not quality, and moving folders without changing dependencies is not an architectural improvement.

## Quality criteria

- Each finding names the owner of the behavior, the dependency crossing it and the consequence for a real use case.
- The recommendation keeps one accountable source for each table and creates no new cyclic or bidirectional dependency.
- The review covers runtime processes, async messages, database effects and public contracts the operation crosses.
- The proposed shape can be introduced in bounded steps without silently changing unrelated behavior.
- The ownership map after the change matches `mix xref` output and the tests encode the boundary.

## Validation and evidence

- Minimum: the ownership map and the `mix xref graph --format cycles` output before and after, plus the trace of one real operation from entry point to effect naming each module crossed.
- When turns allow: the existing tests of the traced operation and its failure path, run after the correction.
- When a public boundary moved: the list of callers, callbacks, configuration and persisted job names checked, with the search used.
- When a correction was only proposed: the migration cost and a verification path per recommendation.

## Avoid

- Do not turn a small change into a speculative rewrite or a new directory layout.
- Do not label a module "bad architecture" without a path, a symbol and a concrete failure or maintenance cost.
- Do not break a cycle by adding a third module both sides depend on without moving the ownership of the data.
- Do not equate a LiveView, a page or a folder with a domain.
- Do not rename or relocate modules here; hand an understood ownership decision to [module-design](../module-design/SKILL.md).

## Completion

An ownership map backed by `mix xref` and one traced operation, findings with owner, crossing and consequence, and either one bounded correction applied with compile and tests green or an ordered proposal with its cost. With ownership decided, use [module-design](../module-design/SKILL.md) for names and public APIs, [abstraction-layers](../abstraction-layers/SKILL.md) for a function mixing levels, [code-consolidation](../code-consolidation/SKILL.md) for a competing or dead path, and [migration-compatibility](../migration-compatibility/SKILL.md) when a moved boundary changes a persisted name.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
