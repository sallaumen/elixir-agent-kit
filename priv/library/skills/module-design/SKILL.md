---
name: module-design
description: "Use when module names, locations or public APIs obscure responsibilities that are already understood."
---

# Module Design

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when `Accounts.Helpers` holds the invoice arithmetic that belongs under `Billing`; when a `MyApp.Utils` module exports forty functions and three of them have callers; when a context is named after a page (`DashboardContext`) instead of the concept it owns; when a function is `def` instead of `defp` only so a test can call it; or when the LiveView is the only caller of a context function that lives in the wrong context, and everyone already agrees where it belongs.

The separating rule among the code workflows: one module whose name, location or public API misleads while its responsibility is already understood is this workflow; when the responsibility itself is contested, or the change spans many modules with cycles, go to [architecture-review](../architecture-review/SKILL.md) first and come back with its ownership map; one function mixing a decision with effects is [abstraction-layers](../abstraction-layers/SKILL.md); two modules doing the same thing is [code-consolidation](../code-consolidation/SKILL.md); several modules that drift from a convention the project already chose is [house-patterns](../house-patterns/SKILL.md). A rename that touches a persisted worker name, serialized module or external payload is [migration-compatibility](../migration-compatibility/SKILL.md) work before it is a rename. Reading obstacles inside function bodies, including private names, are [readable-code](../readable-code/SKILL.md); public names stay here.

## Inputs to inspect

- Start at: the module named in the request, then `mix xref graph --sink lib/<path>.ex --only-nodes` for its static callers and `grep -rn "ModuleName" lib/ test/ config/ priv/` for aliases, strings and configuration.
- Its public functions with `grep -n "  def " lib/<path>.ex`, and for each one the number of callers outside the module and outside tests.
- The project naming conventions: how contexts, schemas, workers and web modules are named and placed, and the vocabulary the domain uses.
- Dynamic and persisted references: `apply/3`, `String.to_existing_atom/1`, behaviour callbacks, protocol implementations, supervisor children, `config :app, module: ...`, and `oban_jobs.worker` values. See [OTP processes and supervision](../../elixir/otp.md) and [Oban](../../elixir/oban.md).
- The ownership decision this rename rests on (a doc, an ADR or an [architecture-review](../architecture-review/SKILL.md) map) and the tests that exercise the module's public operations.

## Workflow

1. Write the rename map: one row per public function or module in scope with current name, target name or location, the one-sentence responsibility it should express, callers by kind (direct, alias, configuration, supervisor child, dynamic, persisted, test only). This map is the artifact every later step reports against. Done when every public function has a caller count per kind.

2. Mark each row keep, rename, move, make private or delete: misleading names, helpers under the wrong owner and public functions whose only caller is a test. Done when every row has one disposition and the target names describe behavior in domain vocabulary.

3. For every rename or move, search the persisted and dynamic kinds: `oban_jobs` worker names, serialized terms, configuration, children specs, `apply/3`, callback modules, protocol implementations. Done when each hit is either cleared or handed to [migration-compatibility](../migration-compatibility/SKILL.md) with the row noted.

4. Make the smallest coherent move and update all consumers in one change, adding a delegating alias with `@deprecated` only when a persisted or external reference requires it. Done when `mix compile --warnings-as-errors` passes with no undefined or deprecated call from inside the project. See [Build, dependencies and releases](../../elixir/build-releases.md).

5. Exercise one public operation of the moved module through its new API, including one failure path, and update module docs and configuration names. Done when the existing tests pass against the new names with no private function made public.

6. Record each compatibility alias with its removal condition and owner, then run the project gate. Done when the map is updated to the final state.

## Decision points

- If the responsibility is unclear, stop and use [architecture-review](../architecture-review/SKILL.md); naming cannot fix an ownership dispute.
- A public function with no consumer outside tests becomes private, and the test moves to the public operation that uses it.
- A name describes the behavior and domain concept, never the caller, the page or the moment it was written (`_v2`, `_new`), and follows Elixir's conventions: `?` for booleans, `is_` only for guard-safe checks, `!` for the raising variant, `get`/`fetch`/`fetch!`, `size` for O(1) and `length` for O(n). See [Module and function shape](../../elixir/code-shape.md).
- One name, one behavior: clauses that do unrelated things become separately named functions, and every message to a process goes through the one module that owns it.
- A package defines modules only under its own namespace; a module that reopens another library's namespace is moved, except protocol implementations, `Mix.Tasks.*` modules and modules the namespace's owner invites.
- A text search is not proof that dynamic or persisted references are absent; each kind in the map is checked by its own search.
- A persisted or external reference turns the rename into a migration step with an alias and a removal condition, never a direct replace.

## Quality criteria

- Each public module name predicts its responsibility and its exported functions form one coherent promise to consumers.
- Inputs, errors and side effects are discoverable at the public API; callers do not reach through a module to another owner's state.
- Internal helpers stay private; the public surface did not grow to make tests easier.
- Every caller kind in the map is updated in the same change, including docs, configuration and dynamic dispatch, without changing domain behavior.
- Each compatibility alias has a removal condition and an owner.

## Validation and evidence

- Minimum: `mix compile --warnings-as-errors` clean plus the existing test of one affected public operation and its failure path passing against the new names, with the persisted and dynamic reference searches reported by kind.
- When turns allow: a before-and-after caller trace for one representative consumer of each renamed function.
- When an alias was kept: a test that the old name still delegates, and the removal condition written where the alias lives.
- When a worker or serialized name was involved: the [migration-compatibility](../migration-compatibility/SKILL.md) handoff and the old-job test it requires.

## Avoid

- Do not move files because a directory looks crowded without knowing each consumer.
- Do not treat a text search as proof that dynamic or persisted references are absent.
- Do not expose a private function to make a test easier.
- Do not rename a persisted worker or serialized module by search-and-replace.
- Do not decide ownership here; a contested responsibility goes to [architecture-review](../architecture-review/SKILL.md) first.

## Completion

A rename map with a disposition per public function, modules and APIs whose names predict their responsibility, every caller kind updated in one change, compile clean and one public operation exercised with its failure path, and each alias recorded with its removal condition. For a contested responsibility use [architecture-review](../architecture-review/SKILL.md); for a function still mixing levels inside the renamed module use [abstraction-layers](../abstraction-layers/SKILL.md); for the duplicate the map revealed use [code-consolidation](../code-consolidation/SKILL.md); for a persisted name use [migration-compatibility](../migration-compatibility/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
