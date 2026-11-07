---
name: code-consolidation
description: "Use when unfinished features, abandoned paths or competing implementations make a codebase ambiguous."
---

# Code Consolidation

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when two `send_invitation` implementations exist, one in a context and one inside a LiveView; when a feature flag has been on for a year and its off branch still compiles; when an Oban worker has no `Oban.insert` or `new/1` call anywhere; when a route is in the router but no link, redirect or test reaches it; when a `_v2` module lives next to the original and both have callers; or when an adapter kept for a past migration never got its removal step.

The separating rule among the code workflows: a path that nothing reaches, or two paths doing the same job, is this workflow; one function mixing a decision with effects is [abstraction-layers](../abstraction-layers/SKILL.md); a module with the right content and the wrong name or location is [module-design](../module-design/SKILL.md); ownership unclear across many modules is [architecture-review](../architecture-review/SKILL.md); code that works but drifts from a pattern the project already chose is [house-patterns](../house-patterns/SKILL.md). Duplicated tests that protect nothing distinct are [test-strategy](../test-strategy/SKILL.md); a dead path left by a finished expand and contract sequence arrives here from [migration-compatibility](../migration-compatibility/SKILL.md). Restructuring or cleaning up the one implementation that stays is [functional-refactoring](../functional-refactoring/SKILL.md) or [readable-code](../readable-code/SKILL.md).

## Inputs to inspect

- Start at: the candidate named in the request, then `grep -rn "CandidateModule\|candidate_function" lib/ test/ config/ priv/` and `mix xref graph --sink lib/<path>.ex --only-nodes` for static references.
- Routes and entry points: `mix phx.routes` for the route, templates and `push_navigate` calls for links, `live_session` membership. See [Phoenix and LiveView](../../elixir/phoenix-liveview.md).
- Jobs and processes: `oban_jobs` rows by worker name, cron or scheduled entries in configuration, supervisor children and PubSub subscriptions. See [Oban](../../elixir/oban.md) and [OTP processes and supervision](../../elixir/otp.md).
- Dynamic references: `apply/3`, configuration keys, feature flags, behaviour callbacks, protocol implementations, serialized module names.
- The reason each variant exists: `git log` on the files, the issue or commit that introduced it, and the version, tenant, latency or user experience constraint it served.
- Tests, logs or telemetry that show the path running, and the coverage of the variant that would survive. See [Telemetry and observability](../../elixir/telemetry.md).

## Workflow

1. Write the evidence table: one row per candidate path with static callers, dynamic references, route or entry point, job or process, tests, runtime evidence (logs, telemetry, job rows) and product intent (commit or issue), each cell filled or marked "not found". This table is the artifact every later step reports against; a path is dead only when every column reads "not found". Done when every candidate has every column filled.

2. Classify each row as useful but incomplete, obsolete, duplicate of a named canonical path, or uncertain, and give each a disposition: finish, merge, remove, or defer with a specific question to the owner. Done when every row has one disposition and every uncertain row has its question written.

3. For each merge, compare the variants on inputs, outputs, side effects, error behavior, authorization, ordering and telemetry, and choose the canonical path. Done when the difference list is written and every meaningful difference is either kept visible at the call site or named as a deliberate loss.

4. Execute one bounded cleanup: redirect callers to the canonical path, delete the dead path with its tests, docs, routes and configuration, and keep historical records and data. Done when `mix compile --warnings-as-errors` passes and `mix xref` shows no reference to the removed path. See [Build, dependencies and releases](../../elixir/build-releases.md).

5. Validate the surviving path for a normal and a failure case per former caller, including authorization and the telemetry or job it emits. Done when the tests pass and the deliberate variants retained are listed.

6. Report the removed duplication, the variants kept and the rows deferred with their questions, then run the project gate. Done when the handoff names what remains uncertain rather than calling the codebase clean.

## Decision points

- Age, apparent inactivity and a missing static caller are not proof of death; the evidence table needs every column, and a persisted job row or a dynamic reference keeps a path alive.
- Consolidate only when semantics and change cadence align; two functions that share lines but change for different reasons stay separate.
- Keep a meaningful difference visible at the call site or as a named function; a Boolean switch that hides divergent business rules is a new duplicate.
- The canonical path lives in the lower layer; a shared module never imports the product-specific caller it serves.
- A removal with a persisted job, serialized name or external payload goes through [migration-compatibility](../migration-compatibility/SKILL.md) first.

## Quality criteria

- Every removed path has a filled evidence table with all columns "not found" or an explicit decision to remove a reachable path.
- The resulting API names the common concept and leaves meaningful differences visible at call sites.
- Error behavior, authorization, ordering and telemetry are unchanged for every former caller.
- Obsolete tests, docs, routes and configuration left with the removed path; independent behavioral coverage of the survivor remains.
- The new dependency direction does not make a lower layer depend on a product-specific caller.

## Validation and evidence

- Minimum: the evidence table for the removed or merged path, `mix compile --warnings-as-errors` clean, and the surviving path's normal and failure case tests passing for each former caller.
- When turns allow: a before-and-after comparison of one representative call per variant, asserting the same result, error and emitted telemetry or job.
- When a route or worker was removed: `mix phx.routes` and the `oban_jobs` worker query showing no remaining reference.
- When a row was deferred: the specific question and who can answer it.

## Avoid

- Do not extract a generic helper because two functions share a few lines.
- Do not hide divergent business rules behind Boolean switches or options maps.
- Do not delete a path on the strength of a text search alone; fill every column of the evidence table.
- Do not mix formatting, renames or broad rewrites into the cleanup.
- Do not describe the whole codebase as clean after one bounded consolidation.

## Completion

An evidence table with a disposition per candidate, one bounded cleanup executed with compile clean and no remaining reference, the canonical path validated for a normal and a failure case per former caller, and the deferred rows carrying their questions. For a persisted name in the removed path use [migration-compatibility](../migration-compatibility/SKILL.md); for naming the surviving module use [module-design](../module-design/SKILL.md); for a survivor that still mixes levels use [abstraction-layers](../abstraction-layers/SKILL.md); for duplicated tests use [test-strategy](../test-strategy/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
