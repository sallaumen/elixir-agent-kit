---
status: approved
date: 2026-11-07
tags: [workflows, refactoring, routing, evals]
---

# Refactoring workflows: functional-refactoring and readable-code

## Problem

The owner wants workflows that deliver a finished refactoring "in the style of"
functional thinking (the ideas of *Grokking Simplicity*) and of readable code
(the ideas of *Clean Code*), adapted to Elixir.

After 0.7.0 the kit covers part of this:

- `elixir/code-shape.md` and `elixir/pipelines.md` hold Elixir conventions for
  names, function shape, assertive code, errors, docs, `|>` and `with`. They are
  references a workflow reads, not entry points.
- `house-patterns` refactors code to a pattern the project already chose,
  behavior-preserving, with characterization tests first. It needs an existing
  pattern.
- `abstraction-layers` separates actions and calculations, but for one function.

Missing: an entry point for "refactor module X in the functional style" when no
project pattern exists, covering implicit inputs and outputs, layers across a
module and functions passed as arguments; and an entry point for "make this
readable" that delivers the change instead of only citing a reference.

This is the second of three fronts. The first (size-proportional planning) shipped
in 0.7.0; the third (an evaluation matrix by workflow and size) is out of scope.

## Decisions

1. Two workflows, `functional-refactoring` (structure: effects, implicit inputs,
   layers) and `readable-code` (reading: names, function shape, control flow,
   comments). A single workflow with a readability pass and extending
   `abstraction-layers` were the alternatives; the owner chose two named entry
   points.
2. A request that only says "refactor module X" routes by symptom: hard to test
   or hidden dependencies (clock, configuration, database) go to
   `functional-refactoring`; hard to read goes to `readable-code`; with both
   symptoms, `functional-refactoring` first and `readable-code` after, as slices
   of the same plan.
3. The books contribute concepts only, in the kit's own words; no passage is
   reproduced. `docs/provenance.md` records both as conceptual references.

## The two workflows

Both live in the `code` area with default mode **analyze-and-fix**, preserve
behavior and deliver the change. Scope is one module or a small cluster around
one entry point; anything larger follows the contract's size-proportional plan.
Both follow the workflow template that `scripts/check_library.py` enforces.

### functional-refactoring

Catalog sentence: "Use when a module is hard to test or change because decisions,
hidden inputs such as the clock, configuration or the database, and effects are
interleaved across its functions."

Workflow:

1. Module inventory, the first-step artifact: every function tagged action,
   calculation or data shaping, with its implicit inputs (`DateTime.utc_now/0`,
   `Application.get_env/2`, `Repo` reads, ETS, the process dictionary) and
   implicit outputs (writes, broadcasts, Oban inserts, logs, telemetry, sent
   messages).
2. Pin behavior: a test at the public seam for what each action returns and
   produces, adding characterization tests where none exist.
3. Make implicit inputs explicit at the edge: the public action reads the clock or
   configuration once and passes the value down; calculations take everything as
   arguments. Public signatures do not change.
4. Extract calculations into pure functions tested without stubs (in the module
   or a pure module named for the decision, per `code-shape.md`).
5. Stratify: each function calls only its own layer or lower ones, and no
   calculation calls an action. Two bodies that differ in one step become one
   function taking that step as an argument.
6. Compare the effect inventory before and after (count, order, transaction
   boundary), run the project gate, and hand readability-only rows to
   `readable-code`.

Decision points include: extract only when the new function names a decision or
shields a detail likely to change; implicit inputs are read once, at the edge;
no new process or GenServer is introduced to hold state; concurrency timelines
belong to `async-state` or `process-lifecycle`.

### readable-code

Catalog sentence: "Use when a module works and is tested but is hard to read:
vague names, long or deeply nested functions, comments that restate the code or a
tangled error flow."

Workflow:

1. Reading notes, the first-step artifact: per function, the obstacles (name,
   nesting and complexity from `mix credo`, mixed levels of detail, comment noise,
   error flow, non-assertive matching), each with its `code-shape.md`
   anti-pattern name.
2. Pin behavior and the `credo` baseline.
3. Rename locals and private functions to the domain vocabulary; a public name is
   handed to `module-design`.
4. Reshape control flow: function heads and pattern matching for branching,
   `with` for the happy path, pipelines per `pipelines.md`; split by meaning, not
   by line count.
5. Comments: delete those that restate the code, keep those that record a
   constraint; `@moduledoc` and `@doc` per `code-shape.md`.
6. Compare: tests pass unchanged, `credo` reports nothing new, and the diff
   changes no behavior.

## Boundaries

| Situation | Workflow |
|---|---|
| One function mixes a decision with effects | `abstraction-layers` |
| A whole module with effects and implicit inputs | `functional-refactoring` |
| Working code that is hard to read | `readable-code` |
| A module's name, location or public API | `module-design` |
| A pattern the project already chose | `house-patterns` |
| Two implementations of the same job | `code-consolidation` |

## Integration

- `catalog.tsv`, `CATALOG.md`, and the README catalog grid with its pt-BR mirror
  gain both rows; the workflow count goes from 36 to 38.
- `ROUTING.md` gains the symptom rule for vague requests, the
  functional-then-readable order, and the neighbor pairs above.
- `ELIXIR.md` and `elixir/code-shape.md` point to the two workflows where they
  mention refactoring.
- `abstraction-layers`, `module-design`, `house-patterns` and `code-consolidation`
  each gain one line in their separating rule naming the new workflows. No other
  existing workflow text changes.

## Evaluation cases

Four new cases, E63-E66 (E62 is the last case on main), each with
`expected_size`:

- An explicit "functional style" request on a module mixing the clock and `Repo`
  with decisions: `functional-refactoring`, medium.
- A "make it readable, Clean Code" request on a module with long, nested
  functions: `readable-code`, medium.
- A vague "refactor module X" with both symptoms: `functional-refactoring` first,
  then `readable-code` as a later slice of the plan; large.
- Renaming a public function: `module-design`, a negative case for
  `readable-code`.

## Provenance

`docs/provenance.md` lists *Grokking Simplicity* (Eric Normand) and *Clean Code*
(Robert C. Martin) as concept-only references with no textual reuse, beside the
existing stratified-design reference. `docs/source-review.md` gains both rows.
Before committing, both workflow texts pass an 8-word overlap scan against any
consulted excerpt; the result is recorded in the pull request.

## Verification

- `python3 scripts/check_library.py`: template headings, `Start at` and `Minimum`
  lines, no em dash, provenance entry, a routing case per workflow, case count.
- `mix check`, `python3 scripts/smoke_install.py --git-url "$(pwd)" --ref
  "$(git rev-parse HEAD)"`, `python3 scripts/smoke_migration.py`, `mix hex.build`.
- The installer does not change; the generated pointer skill picks up the new
  catalog rows.
- No live client evaluation runs automatically; it is reported separately.

## Delivery

One pull request, then release 0.8.0 with the owner's approval, then updating
pokex and Colmex in separate pull requests.

## Out of scope

The workflow-by-size evaluation matrix, live evaluations, installer changes, and
changes to existing workflows beyond the one separating line each.
