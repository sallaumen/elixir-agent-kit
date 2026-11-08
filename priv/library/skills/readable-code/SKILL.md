---
name: readable-code
description: "Use when a module works and is tested but is hard to read: vague names, long or deeply nested functions, comments that restate the code or a tangled error flow."
---

# Readable Code

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a reviewer must hold four nested `case` and `if` levels in mind to follow one `handle_event/3`; when a private `process/2` binds results named `res2` and `tmp`; when `mix credo --strict` reports complexity or nesting for functions nobody wants to touch; when every other line carries a comment that repeats the code below it; when errors travel through `{:ok, _}` and `{:error, _}` matches repeated at each step instead of one `with`; or when the user asks to make a module readable or clean without changing what it does.

The separating rule among the code workflows: working, tested code that is hard to read inside its function bodies is this workflow; a module's name, location or public API is [module-design](../module-design/SKILL.md); hidden inputs and effects interleaved across a module are [functional-refactoring](../functional-refactoring/SKILL.md), which runs first when both symptoms appear; one function mixing a decision with effects is [abstraction-layers](../abstraction-layers/SKILL.md); drift from a pattern the project already chose is [house-patterns](../house-patterns/SKILL.md). Code whose behavior no test pins gets those tests first, as step 2 says.

## Size

- **Small**: resolve one reading obstacle in one function (one vague name or one nested level) and compare against the lint baseline; skip the full reading notes.
- **Medium**: run the workflow as written for one module: the reading notes, the pinned baseline and the renamed and reshaped functions.
- **Large**: several modules; slice per module, and hand a public name to module-design or hidden inputs and effects to functional-refactoring as later slices.

## Inputs to inspect

- Start at: the module named in the request and `mix credo --strict <path>` for it (or the project's lint command), whose complexity, nesting and naming findings seed the reading notes.
- The project's naming and style sources: `AGENTS.md` or a style guide, a glossary if one exists, `.credo.exs` and `.formatter.exs`. They win over the kit's defaults.
- The tests that pin the module's public behavior, and the callers of its public functions, so every rename stays private.
- [Module and function shape](../../elixir/code-shape.md) for the anti-pattern names (assertive code, naming, errors, documentation), and [Pipelines and control flow](../../elixir/pipelines.md#with-for-fallible-steps) for `with` and the pipe.

## Workflow

1. Write the reading notes: one row per function with each obstacle found (a vague or misleading name, nesting depth, length that mixes levels of detail, a comment that restates code, a repeated error match, non-assertive matching or map access), the `credo` finding or the [code-shape](../../elixir/code-shape.md) anti-pattern name it maps to, and the planned change. This table is the artifact every later step reports against. Done when every function the request covers has a row, including those with no obstacle.

2. Pin behavior and the lint baseline: the public functions' tests pass on the unchanged code, characterization tests are added where a function has none, and the current `credo` output is saved (when the project runs no linter, the reading notes are the baseline and steps 4 and 6 compare against them). Done when both exist.

3. Rename local variables and private functions to the domain's vocabulary, one name per concept, using the project's glossary when it exists. Public function and module names go to [module-design](../module-design/SKILL.md) as handoff rows. Done when no private name in the notes is still vague and `mix compile --warnings-as-errors` is clean.

4. Reshape control flow by meaning: branch with function heads and pattern matching instead of nested `case` and `if`, chain fallible steps with one `with` per [Pipelines and control flow](../../elixir/pipelines.md#with-for-fallible-steps), keeping every error value the function returned before (a step whose error needs reshaping gets a small private function, not a long `else`), use the pipe for successive transformations of one value, and split a function where its level of detail changes, not at a line count. Done when each function reads at one level and `credo` reports no nesting or complexity finding beyond those the baseline already accepted.

5. Clean up comments and docs: delete comments that restate the code, keep those that record a constraint, a reason or a measured fact, and make `@moduledoc` and `@doc` state promises per [code-shape](../../elixir/code-shape.md#documentation-and-types). Done when every remaining comment says something the code cannot.

6. Compare and close: the pinned tests pass unchanged, `credo` reports nothing new against the baseline, the diff changes no return value, error, effect or public name, and the project gate passes. Done when the handoff lists the notes table in its final state and any rows handed off.

## Decision points

- The project's naming and style rules beat the kit's defaults; the [code-shape](../../elixir/code-shape.md) anti-pattern names give a shared vocabulary, not new rules.
- Split by meaning, never by line count: a long function that reads at one level stays; a short one that mixes levels splits.
- Renames stay private here; a public rename changes a contract and belongs to [module-design](../module-design/SKILL.md).
- A comment is kept when it records a constraint, a reason or a measured fact the code cannot show.
- A readability change that would alter behavior (a lenient match made assertive on input that can really vary) is a separate, named decision with its own test, not part of the cleanup.
- Formatting is the formatter's job; do not hand-format or mix a formatter run with semantic changes in one step.

## Quality criteria

- A reader follows each function without holding more than one level of nesting or detail in mind.
- Names say what a value is or what a function decides, in the domain's words, consistently across the module.
- Error flow is visible in one place per function, and every error the function could return is still returned.
- Every remaining comment adds information the code does not carry.
- Tests, return values, errors, effects and public names are unchanged.

## Validation and evidence

- Minimum: the reading notes before and after, the pinned public tests passing on the unchanged code and on the head commit, and the `credo` output before and after showing no new finding.
- When turns allow: one before-and-after excerpt per obstacle kind in the handoff, named with its anti-pattern.
- When a public name was found vague: the handoff row for [module-design](../module-design/SKILL.md) instead of a rename.
- When a function had no test: the characterization test added in step 2. See [ExUnit and diagnostics](../../elixir/exunit.md).

## Avoid

- Do not treat shorter code, fewer lines or more functions as more readable by themselves.
- Do not rename public functions, modules or stored keys here.
- Do not change behavior, effects or error values while cleaning up, including obvious-looking fixes; report them as defects.
- Do not restate the code in new comments or add docs that only repeat the function name.
- Do not move effects between functions, read hidden inputs in a new place or layer the module; that is [functional-refactoring](../functional-refactoring/SKILL.md).

## Completion

Reading notes with every obstacle mapped to a `credo` finding or an anti-pattern name, private names in the domain's vocabulary, control flow reshaped by meaning, comments that carry information, tests and public names unchanged, no new `credo` finding, and the gate green on the head commit. For public names use [module-design](../module-design/SKILL.md); for hidden inputs and effects use [functional-refactoring](../functional-refactoring/SKILL.md); for one function mixing a decision with effects use [abstraction-layers](../abstraction-layers/SKILL.md); for a project pattern use [house-patterns](../house-patterns/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
