---
name: build-dependencies
description: "Use when dependencies, builds or CI fail or behave differently across environments."
---

# Build Dependencies

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when dependencies, builds or CI fail or behave differently across environments.

## Inputs to inspect

- Runtime/toolchain versions, dependency manifests and lockfiles, build environment and cache key inputs.
- The failing or inconsistent build path, including network and credential constraints.

## Workflow

1. Reproduce the exact failing command with its language/runtime versions, lockfile and environment. Distinguish infrastructure unavailability from code failure.

2. Inspect compatibility requirements and dependency usage before upgrading or removing anything. Preserve reproducibility and change only the relevant dependency boundary.

3. Compare local and CI commands, caches, permissions and service prerequisites. Never disable a meaningful check or swallow a nonzero exit merely to obtain green output.

4. Verify the repaired command and required project gates. Report residual infrastructure limits and avoid incidental publishing or deployment.

## Decision points

- Determine whether the problem is source, dependency resolution, stale artifacts or environment mismatch before clearing caches.
- Pin and update dependency versions through the package manager, considering all supported runtimes and consumers.

## Quality criteria

- A fresh install resolves the same dependency graph from committed manifests.
- Generated artifacts and caches have explicit invalidation inputs and can be regenerated without hidden local state.
- Private credentials are not embedded in tracked manifests or logs.
- Dependency upgrades include compatibility and transitive effects relevant to the package’s public contract.

## Validation and evidence

- Reproduce with a clean or isolated build and compare it with the existing cache path.
- Record resolved versions and the command/environment that produced the verified build.

## Avoid

- Do not delete another process’s shared build artifacts during active work.
- Do not call a successful cached build proof of reproducibility.

## Completion

A grounded build failure diagnosis and reproducible repair. Use pipeline-design for reorganizing validation responsibilities.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
