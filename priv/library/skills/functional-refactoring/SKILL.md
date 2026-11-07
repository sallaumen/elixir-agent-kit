---
name: functional-refactoring
description: "Use when a module is hard to test or change because decisions, hidden inputs such as the clock, configuration or the database, and effects are interleaved across its functions."
---

# Functional Refactoring

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when testing one rule of a module needs the database, a frozen clock and an `Application.put_env/3` that the test must restore; when private functions call `DateTime.utc_now/0`, `Application.get_env/2` or `Repo.get!/2` deep inside a calculation; when a pricing or eligibility decision cannot be reused because it also inserts a row or broadcasts; when two functions repeat the same body except for one step; or when the user asks to refactor a module in a functional style and the project has no written pattern for it.

The separating rule among the code workflows: a whole module whose functions interleave hidden inputs, decisions and effects is this workflow; one function mixing a decision with effects is [abstraction-layers](../abstraction-layers/SKILL.md); code drifting from a pattern the project already chose is [house-patterns](../house-patterns/SKILL.md); working code that is only hard to read is [readable-code](../readable-code/SKILL.md); a misleading module name or public API is [module-design](../module-design/SKILL.md). When a request only says "refactor this module", hidden dependencies or rules that are hard to test point here and reading obstacles alone point to readable-code; with both, this workflow runs first and readable-code follows as a later slice of the same plan.

## Inputs to inspect

- Start at: the module named in the request, with `grep -n "def \|defp " lib/<path>.ex` to list its functions, then a search for implicit inputs inside it: `grep -n "utc_\|_env\|System\.\|:rand\.\|Repo\.\|:ets\.\|:persistent_term\|Process\.get" lib/<path>.ex`.
- Each public function's callers (`mix xref graph --sink lib/<path>.ex --only-nodes` lists the files that depend on the module) and what they observe: return shapes, error tuples, raises, rows written, broadcasts, jobs, telemetry.
- The tests that reach the module today and what each one stubs, freezes or configures to get there.
- The effects and their transaction boundaries: `Repo` writes, `Ecto.Multi`, `Oban.insert`, `Phoenix.PubSub.broadcast`, `send/2`, `Logger`, `:telemetry.execute`. See [Ecto](../../elixir/ecto.md) and [Oban](../../elixir/oban.md) when the project uses them.
- [Module and function shape](../../elixir/code-shape.md#decisions-and-effects) for where pure decisions live, and [Pipelines and control flow](../../elixir/pipelines.md) for chaining the reshaped steps.

## Workflow

1. Write the module inventory: one row per function with its kind (action: its result or effect depends on when or how often it runs; calculation: the same output for the same input; data shaping: builds or reads a struct or map), its implicit inputs (clock, configuration, database reads, ETS, process dictionary, messages received) and its implicit outputs (writes, broadcasts, jobs, logs, telemetry, messages sent). A function that calls an action is an action. This table is the artifact every later step reports against. Done when every function has a row and every implicit input and output the search found is attributed to one.

2. Pin current behavior at the public seam: for each public action, a test asserting what callers observe (result, error, raise, rows, broadcast, job), adding a characterization test where none exists. Record the effect inventory: count, order and transaction of each effect. Done when the pinned tests pass on the unchanged code.

3. Make implicit inputs explicit at the edge: the public action reads the clock, the configuration or the database once and passes plain values down; the functions it calls take those values as arguments. Public signatures and return shapes stay as they are: a value only the tests needed to control reaches the extracted calculation as an argument, so the public action keeps its arity; adding an option to a public function is a public-contract change and needs the user's approval. Done when no calculation row in the inventory still has an implicit input.

4. Extract calculations into pure functions that take data and return data, in the module or in a pure module named for the decision when several functions share it, each with a unit test that needs no database, stub or frozen clock. Done when every decision the inventory names can be called and tested without an effect.

5. Stratify the module: arrange the functions so each calls only its own layer or lower ones (public actions, then domain operations, then calculations, then data shaping), no calculation calls an action, and two bodies that differ in a single step become one function that receives that step as a function argument. Done when the inventory's call graph has no upward edge and no duplicated body that changes for the same reason remains.

6. Compare the effect inventory with step 2's, rerun the pinned tests and the project gate, and list the reading obstacles left for [readable-code](../readable-code/SKILL.md). Done when effects match in count, order and transaction, the gate passes on the head commit, and the handoff names each moved decision and its new test.

## Decision points

- Extract only when the new function names a business decision or shields a detail likely to change; a one-line wrapper that only forwards arguments is not a calculation.
- Implicit inputs are read once, at the edge, in the public action; never pass the repo, a client module or the whole configuration down to make a function look pure.
- Moving a read changes when it happens: a read inside a transaction, a read that depends on an earlier write in the same action, or a read only one branch made (a `Repo` query, an `Application.fetch_env!/2` that can raise) moves with its transaction or its condition, never ahead of them; several clock reads collapsed into one are recorded in the inventory as a decision; a runtime `Application.get_env/2` never becomes a module attribute or `Application.compile_env/2`.
- Data over behavior: prefer plain maps, structs and tagged tuples flowing between functions over callbacks threaded through layers; pass a function argument only to remove a duplicated body.
- Effect count, order, error propagation and transaction boundary are frozen by step 2; changing any of them is a separate, named decision.
- Do not introduce a GenServer, Agent or ETS table to hold state the refactor exposed; a process is a [process-lifecycle](../process-lifecycle/SKILL.md) decision, and timing between concurrent effects is [async-state](../async-state/SKILL.md).
- A change that would alter a public signature, a stored shape or a message other processes rely on needs the user's approval under the contract's planning rule (a public contract or persisted data changes).

## Quality criteria

- Every decision in the module can be called and tested with plain values, and its test needs no database, stub, frozen clock or configuration change.
- Each public action reads at one level: read inputs, decide, perform effects in the recorded order.
- No function calls one of a higher layer, and no calculation reaches the clock, configuration, database or a process.
- The effect inventory before and after is identical, and callers observe the same results and errors.
- No parameter bundle or callback exists only to claim purity.

## Validation and evidence

- Minimum: the module inventory before and after, a test of each extracted calculation that uses no stub, frozen clock or database, and the pinned public-seam tests passing on the unchanged code and on the head commit.
- When turns allow: the effect inventory before and after for one complete public action, listing each effect, its order and its transaction.
- When a test previously stubbed or froze something to reach a rule: the same rule now tested directly, with the stub or freeze kept only in the action's test.
- When reading obstacles remain: their list handed to [readable-code](../readable-code/SKILL.md), not fixed in the same step. See [ExUnit and diagnostics](../../elixir/exunit.md).

## Avoid

- Do not count new modules, files or lines as progress; a module whose rules became testable is the result.
- Do not move an effect into or out of a transaction, reorder effects or change their count while extracting.
- Do not change a public signature or return shape to make a function pure; read the input at the edge instead.
- Do not rename public functions or move the module here; that is [module-design](../module-design/SKILL.md).
- Do not mix readability sweeps (local renames, comment cleanup, formatting) into a structural step.

## Completion

A module inventory with every function classified and every implicit input and output attributed, calculations extracted as pure functions with stub-free tests, implicit inputs read once in the public actions, no upward call in the layering, effects unchanged in count, order and transaction, and the gate green on the head commit. For a single function use [abstraction-layers](../abstraction-layers/SKILL.md); for a pattern the project already chose use [house-patterns](../house-patterns/SKILL.md); for reading obstacles left behind use [readable-code](../readable-code/SKILL.md); for the coverage the stubs were hiding use [test-strategy](../test-strategy/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
