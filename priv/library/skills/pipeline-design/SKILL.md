---
name: pipeline-design
description: "Use when validation pipelines lack clear ownership, local/CI parity or predictable command effects."
---

# Pipeline Design

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when validation pipelines lack clear ownership, local/CI parity or predictable command effects.

## Inputs to inspect

- Repository-required commands, secrets, services, platforms and available local/remote runners.
- Change type, risks, CI costs and known constraints such as billing or unavailable tokens.

## Workflow

1. Inventory the existing checks, commands, environments and side effects. Identify which checks protect backend, frontend, library integrity and release assembly.

2. Define a canonical command for each concern and keep local execution equivalent to CI. Distinguish source checks from commands that format, seed, reset data or publish artifacts.

3. Document prerequisites, outputs and failure semantics. Keep release validation explicit when it is more effectful than a normal change gate.

4. Test command contracts and representative execution. If remote CI cannot run, follow the consuming project's documented fallback and report the missing remote evidence; do not silently turn a failed check green.

## Decision points

- Put fast deterministic checks before slower integration checks and make required gates match repository policy.
- When CI cannot run, follow the project’s documented fallback with exact evidence rather than claiming green CI.

## Quality criteria

- Each pipeline step has a purpose, reproducible command and clear failure signal.
- Secrets are provided only to jobs that need them; untrusted PR code cannot access privileged credentials.
- Matrix dimensions cover supported runtime or platform contracts without redundant work.
- Caching speeds setup without allowing stale results to masquerade as a clean build.

## Validation and evidence

- Exercise the workflow locally or through a safe test PR where possible.
- Report which gates ran, which were unavailable and the exact fallback used.

## Avoid

- Do not add a required gate that cannot run in the repository’s real environment.
- Do not treat a skipped job as a passing test.

## Completion

A reproducible pipeline map with working commands, clear effects and no duplicated normative instructions.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
