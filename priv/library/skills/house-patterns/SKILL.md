---
name: house-patterns
description: "Use when existing code drifts from patterns the project has already established and must be refactored to them without changing behavior."
---

# House Patterns

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when the project's contract says network clients return a reason instead of raising and three older clients still call `Req.get!/2` and let the exception reach a LiveView; when every newer LiveView loads its data in `handle_params/3` and two older ones read it in `mount/3` as well; when the tests of one module call `Application.put_env/3` without restoring it while the rest of the suite saves and restores; when a new job was written without the per-item isolation every other sync job has; or when a reviewer keeps leaving the same "do it like the others" comment. The pattern already exists and is written or exemplified; the work is to bring the stragglers to it, one verifiable step at a time, while callers see the same behavior.

The separating rule among the code workflows: code that drifts from a pattern the project already chose is this workflow; two implementations of the same job, one of which should go, is [code-consolidation](../code-consolidation/SKILL.md); one function mixing a decision with effects is [abstraction-layers](../abstraction-layers/SKILL.md); a name or location that misleads is [module-design](../module-design/SKILL.md); no agreed pattern, or ownership in dispute across modules, is [architecture-review](../architecture-review/SKILL.md) first. A diff to judge before merge is [code-review](../code-review/SKILL.md), which may cite the pattern card this workflow writes. A rename of a persisted worker or serialized module along the way is [migration-compatibility](../migration-compatibility/SKILL.md).

## Inputs to inspect

- Start at: the written source of the pattern (the project's contract section, an architecture decision record, `AGENTS.md`, a style guide) or, when only code shows it, the exemplar modules the request or the owner names; then one search that finds the deviations, such as `grep -rn "Req\.\(get\|post\|put\|patch\|delete\)!" lib/` or `grep -rln "def mount" lib/*_web/live/`.
- The [Elixir context](../../ELIXIR.md) reference for the technology involved, read as a default the project's own rule overrides, never as the project's rule.
- For each deviating site: its public callers (`mix xref callers Module.fun/arity`), what they observe today (return shapes, raises, messages, broadcasts, rows written, telemetry), and the tests that reach it.
- The project's gate and lint configuration (`mix precommit` or `mix gate`, `.credo.exs`, formatter), and generated framework files the project keeps out of its own patterns.
- Documented exceptions: a contract line, a comment or a decision record that keeps a site deliberately different.

## Workflow

1. Write the pattern card: the rule in one sentence, where it is written or which two exemplars show it, the search that detects a deviation, the documented exceptions, and the observable behavior the rule must preserve. This card is the artifact every later step reports against. Done when the rule has a source an owner would recognize; if it has none, stop here and record the choice with the [decision template](../../templates/decision.md) instead of inventing one.

2. Write the deviation table: one row per site with the file and function, which part of the card it breaks, what callers observe today, the tests that reach it, and a disposition: conform, keep with the documented reason, or hand off to the neighbor workflow that owns it. Done when every hit of the detecting search has a row and a disposition.

3. Pin current behavior before touching a site: for each row marked conform, make sure a test at the public seam asserts what callers observe today (result, error, raise, message, broadcast, row), adding a characterization test where none exists. Done when those tests pass on the unchanged code.

4. Refactor one rule at one site per step, with no renames, formatting sweeps or drive-by fixes in the same step. When conforming changes what a caller observes (a raise becomes `{:error, reason}`), update every caller in the same step, record the change in the table, and keep the user-visible outcome unchanged. Done when `mix compile --warnings-as-errors` is clean and the pinned tests for that site pass.

5. When a deviation turns out to be a defect (a raise that crashes a view, an effect that can run twice), fix it as its own step with a regression test that fails before the fix, and report it apart from the refactor. Done when each defect has its own test and line in the table.

6. Rerun the detecting search, the focused tests and the project gate, then update the table to its final state. Done when the search shows only rows kept with a documented reason, the gate passes on the head commit, and the handoff lists what conformed, what stayed and why, and any rule worth writing into the project's contract.

## Decision points

- A pattern is established when it is written in the project or shown by at least two exemplars an owner confirms; one recent module is a proposal, not a pattern.
- The project's written rule beats the kit's Elixir context, and a documented exception beats both.
- Behavior first: the refactor keeps what callers and users observe; a change in shape is made at every caller in the same step, never left for later.
- One rule, one site, one step: a reviewer can verify each step against the card, and a failure points at one change.
- A defect found on the way is reported and fixed as a defect, not hidden inside a refactor commit.
- A site that would need a migration, a public API change or a coordinated redesign is handed off with its row, not forced into shape.

## Quality criteria

- The pattern card names a source an owner recognizes and a search anyone can rerun.
- Every hit of the search has a disposition, and every kept deviation has a written reason.
- Each changed site has a test at its public seam that passed before and after the change.
- Commits or steps change one rule at one site, with no unrelated renames or formatting.
- Defects found along the way have their own regression tests and are listed separately.
- The gate passed on the final commit, and the handoff names that commit.

## Validation and evidence

- Minimum: the pattern card and the deviation table, plus for each conformed site a public-seam test that passes on the code before the change and after it, and the project gate green on the head commit.
- When turns allow: the detecting search's output before and after, attached to the handoff.
- When a caller's observed shape changed: the list of updated callers and a test per caller kind (LiveView, controller, job) asserting the user-visible outcome.
- When a defect was fixed: its regression test shown failing before the fix.
- When the pattern was only implicit: the proposed contract line for the owner, not written into the project without authority.

## Avoid

- Do not invent a pattern from one module or from the kit's defaults and call it the house style.
- Do not mix renames, formatting or new features into a conformance step.
- Do not change what callers observe and leave some callers on the old shape.
- Do not rewrite generated framework files or documented exceptions to match.
- Do not claim the codebase conforms after one pass; report the rows that remain.

## Completion

A pattern card with a recognized source and a rerunnable search, a deviation table with a disposition per site, each conformed site refactored in its own step with a public-seam test passing before and after, defects reported separately with regression tests, and the gate green on the head commit. For two implementations of one job use [code-consolidation](../code-consolidation/SKILL.md); for a function mixing levels use [abstraction-layers](../abstraction-layers/SKILL.md); for names use [module-design](../module-design/SKILL.md); for a pattern nobody has chosen use [architecture-review](../architecture-review/SKILL.md); for a persisted name use [migration-compatibility](../migration-compatibility/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
