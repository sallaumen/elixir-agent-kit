---
name: test-strategy
description: "Use when a passing suite misses important bugs or the required regression coverage is unclear."
---

# Test Strategy

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a passing suite misses important bugs or the required regression coverage is unclear.

## Inputs to inspect

- Changed behavior, public contract, likely failure modes and existing suite boundaries.
- Available test environments, external dependencies, data isolation and expected execution cost.

## Workflow

1. List the behaviors and boundaries that can fail in the selected change. Rank risks by consequence and likelihood using actual incidents and code paths.

2. Choose the smallest test that crosses the boundary responsible for each risk. Use integration tests when isolated mocks would hide contract mismatches.

3. Control time, concurrency, persistence and external responses so failures are reproducible. Include an adverse condition when that is where the risk lives.

4. Prove a regression test reaches the intended behavior, preferably by observing it fail before the fix. Do not pursue coverage percentage through redundant assertions.

## Decision points

- Choose the cheapest boundary that can observe the failure, then add integration coverage only for interactions it cannot prove.
- Use deterministic fakes for unavailable external effects, while keeping one real contract check where feasible and authorized.

## Quality criteria

- Each test has a concrete input, expected observable result and reason the boundary matters.
- Success, denial, failure and retry cases are selected by risk rather than a fixed quota.
- Fixtures use the production contract and avoid coupling to private implementation details.
- The test can run repeatedly without leaking state, relying on timing guesses or paying for outside services.

## Validation and evidence

- Run the focused suite and report skips, fixtures or dependencies that limit confidence.
- Trace at least one new assertion to the user-visible or public behavior it protects.

## Avoid

- Do not mirror the implementation line for line.
- Do not call a mock expectation proof of a provider’s actual behavior.

## Completion

A justified test plan and meaningful coverage for the selected risks, with remaining gaps stated.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
