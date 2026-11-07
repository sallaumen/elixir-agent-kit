---
name: pipeline-design
description: "Use when validation pipelines lack clear ownership, local/CI parity or predictable command effects."
---

# Pipeline Design

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when `mix test` passes locally but CI fails, or the reverse, and nobody can say which command CI actually runs; when the repository has `precommit`, `gate`, `ci` and `check` aliases and it is unclear which one a contributor must run; when a CI check resets the database, seeds it or publishes an artifact as a side effect of validation; when a required check cannot run on a fork or without a token and is skipped as if it passed; or when a new concern (assets, a native dependency, a release build) needs a place in the pipeline.

This workflow owns the shape of validation: which command checks what, where it runs, and what it is allowed to touch. A build or dependency resolution that fails or differs across environments (`mix.lock` drift, an OTP or Elixir version, a native dependency, a stale `_build`) is [build-dependencies](../build-dependencies/SKILL.md). Whether a delivery passed its criteria is [delivery-validation](../delivery-validation/SKILL.md). Which tests the suite should contain is [test-strategy](../test-strategy/SKILL.md). Sequencing the deliveries that the pipeline gates is [delivery-coordination](../delivery-coordination/SKILL.md).

## Inputs to inspect

- Start at: the CI configuration and the aliases in `mix.exs`, then run the alias CI uses locally and compare its output with the last CI log. See [Build, dependencies and releases](../../ELIXIR.md#build-dependencies-and-releases).
- Every command a contributor is told to run (README, contributing guide, hooks) and what each actually executes: format, compile with warnings as errors, static analysis if present, tests, assets.
- Services and secrets each check needs (database, a headless browser for integration tests, provider keys) and which jobs receive them.
- Side effects per command: database reset, seeds, generated files, published packages, release builds.
- Cache configuration and its key inputs (`mix.lock`, Elixir and OTP versions, `MIX_ENV`), and what a stale cache would hide.
- Runners available locally and remotely, and the project's documented fallback when remote CI cannot run.

## Workflow

1. Write the pipeline inventory: check, command, where it runs (local, CI, both), what it protects (format, compile, tests, assets, release), side effects, secrets needed, and whether local output matches CI. Done when every CI job and every documented local command has a row.

2. Mark the parity gaps: rows that run in one place only, rows whose local command differs from the CI command, rows whose result depends on a cache or a service that one side lacks. Done when each gap has a cause written next to it.

3. Define one canonical command per concern and point both the local aliases and CI at it. Put deterministic checks (format, compile with warnings as errors) before database-backed tests, and keep anything that resets, seeds or publishes out of the validation alias. Done when the inventory has no row with two commands for one concern.

4. Give each check a prerequisite list and a failure signal: what it needs, what a nonzero exit means, and whether a skip is allowed and how it is reported. A skipped required check reports as skipped, never as green. Done when no row has an undefined skip state.

5. Run the canonical commands locally in order and, when the environment permits, through a safe test change in CI. Record which gates ran, which could not, and the fallback used from the project's policy. Done when each row has an observed result or a stated reason it was not observed.

6. Update the project documentation that names the commands so there is one source, and remove duplicated instructions. Done when the documented command list matches the inventory.

## Decision points

- Deterministic before expensive: format and compile precede tests; tests precede browser and release checks.
- One canonical command per concern; an alias wraps it, never replaces it with a variant.
- Secrets go only to the jobs that need them; code from an untrusted branch never runs with privileged credentials.
- A check that cannot run in the repository's real environment is not made required.
- When remote CI cannot run, follow the documented fallback and report local evidence as local; never describe it as a CI pass.
- Caches speed setup only; a cache key that omits `mix.lock` or the runtime version is a parity bug.

## Quality criteria

- Each pipeline step has a purpose, one reproducible command and a clear failure signal.
- Local and CI run the same command for each concern, and the inventory shows it.
- Validation commands have no side effects on data or published artifacts; effectful steps are explicit and gated.
- Matrix dimensions cover the supported Elixir and OTP contracts without redundant jobs.
- Documentation names the canonical commands once.

## Validation and evidence

- Minimum: the pipeline inventory with parity gaps closed and the canonical commands run locally with their exit codes.
- When turns allow: a safe test change pushed through CI with the job results recorded per row.
- When a cache was changed: a run with the cache cleared compared with a cached run, both green.
- When CI cannot run: the documented fallback followed and the missing remote evidence named in the handoff.

## Avoid

- Do not add a required gate that cannot run in the repository's environment.
- Do not treat a skipped job as a passing test, or local output as CI output.
- Do not let a validation alias reset, seed or publish.
- Do not fix a dependency or version failure here; route it with the failing command.
- Do not leave two documents naming different commands for the same check.

## Completion

A pipeline inventory where every concern has one canonical command that runs the same way locally and in CI, deterministic checks come first, side effects are explicit, skips are reported as skips, and the documentation names the commands once. For a build that fails or differs by environment use [build-dependencies](../build-dependencies/SKILL.md); for checking a delivery against its criteria use [delivery-validation](../delivery-validation/SKILL.md); for the tests the gate should run use [test-strategy](../test-strategy/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
