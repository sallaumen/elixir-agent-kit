---
name: build-dependencies
description: "Use when dependencies, builds or CI fail or behave differently across environments."
---

# Build Dependencies

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when `mix deps.get` or `mix compile` succeeds on one machine and fails on another; when CI reports a dependency resolution or `mix.lock` mismatch that local runs do not; when a native dependency (a NIF, a port, a C or Rust build) fails to compile on one platform or OTP version; when a test passes locally against a stale `_build` and fails on a clean checkout; or when an upgrade of one dependency pulls transitive changes nobody expected.

This workflow treats a build or dependency that fails or differs across environments. How the validation pipeline is organized, which command gates what, and whether local and CI run the same commands is [pipeline-design](../pipeline-design/SKILL.md). A test that still fails for a code reason once the build is reproducible is [debugging](../debugging/SKILL.md). A release that builds but does not satisfy its acceptance criteria where it is deployed is [delivery-validation](../delivery-validation/SKILL.md) for the acceptance question and this workflow for the build question.

## Inputs to inspect

- Start at: the exact failing command and its full output, then `elixir --version`, `.tool-versions` (or the equivalent) and `MIX_ENV` in both the failing and the passing environment. See [Build, dependencies and releases](../../ELIXIR.md#build-dependencies-and-releases).
- `mix.lock` and `mix.exs` on both sides: `git diff` on the lockfile between the two revisions, and `mix deps.unlock --check-unused`.
- The `_build/<env>` and `deps/` state: age, which revision built it, and whether the failing side used a cache.
- Native build prerequisites: compilers, headers, system libraries, and the environment variables the dependency's build reads.
- Network and credential constraints: a private package source, a proxy, a token present on one side only.
- The CI cache key and its inputs, when CI is one of the environments.

## Workflow

1. Write the environment table: for each environment (local, CI, the other machine), Elixir version, OTP version, `MIX_ENV`, lockfile revision, cache used, native toolchain, and the observed outcome of the failing command. Done when the table has a row per environment and the differing columns are marked.

2. Reproduce the failure in a clean checkout in a temporary directory with the failing side's versions and lockfile; do not touch another process's `_build` or `deps/`. Done when the clean checkout fails the same way, or passes and the cache is named as the difference.

3. Classify the cause from the table and the reproduction: source (the code does not compile), resolution (the lockfile or manifest), stale artifact (cache or `_build`), environment (runtime version, native toolchain, network). Done when one class is confirmed by the reproduction.

4. Change one boundary for that class: `mix deps.update <dep>` for one dependency, a version constraint in `mix.exs`, a pinned runtime in `.tool-versions`, a cache key that includes the lockfile and the runtime, a documented native prerequisite. Done when the change is a single reviewable diff.

5. Verify in the clean checkout and in the previously passing environment, then run the project gate. Record the resolved versions (`mix deps` output or the lockfile diff). Done when both environments produce the same resolution and the gate is green.

6. Report residual limits: an environment that could not be reproduced, a native prerequisite that must be installed by hand, a private source. Do not publish or deploy as part of the repair. Done when the handoff names each limit.

## Decision points

- Classify before clearing a cache; a cleared cache that fixes the symptom hides the cause.
- Pin and update through the package manager, one dependency at a time, considering every consumer and supported runtime.
- A green cached build is not reproducibility; the clean checkout is.
- Never disable a check or swallow a nonzero exit to obtain green output.
- If the build is reproducible and the test still fails, stop and route to [debugging](../debugging/SKILL.md).

## Quality criteria

- A fresh checkout resolves the same dependency graph from the committed manifest and lockfile on every supported runtime.
- Caches have explicit key inputs (lockfile, Elixir and OTP versions, `MIX_ENV`) and can be regenerated without hidden local state.
- No credential appears in a tracked manifest, lockfile or log.
- A dependency upgrade lists its transitive effects on the project's public contract.
- The environment table in the handoff lets the next person reproduce the verified build.

## Validation and evidence

- Minimum: the failing command run in a clean checkout before the change (failing) and after (passing), with the resolved versions recorded.
- When turns allow: the project gate in the clean checkout and in the original environment.
- When CI was one environment: the CI run after the change, or the documented fallback with the missing remote evidence named.
- When a native dependency was involved: the toolchain prerequisite written into the project's setup documentation.

## Avoid

- Do not delete another process's `_build` or `deps/` during active work.
- Do not call a successful cached build proof of reproducibility.
- Do not upgrade several dependencies in one change to make a build pass.
- Do not reorganize the pipeline while repairing a build; route that separately.
- Do not run database reset, seeds or `mix release` unless the task asks.

## Completion

An environment table that explains the difference, a reproduction in a clean checkout, one boundary changed, the resolved versions recorded, and both environments producing the same build with the gate green; or a named infrastructure limit with the exact command that could not run. For reorganizing which commands gate what use [pipeline-design](../pipeline-design/SKILL.md); for a test that fails on a reproducible build use [debugging](../debugging/SKILL.md); for whether the release meets its acceptance criteria use [delivery-validation](../delivery-validation/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
