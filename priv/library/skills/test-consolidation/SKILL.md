---
name: test-consolidation
description: "Use when duplicated tests slow maintenance without protecting distinct failure modes."
---

# Test Consolidation

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when duplicated tests slow maintenance without protecting distinct failure modes.

## Inputs to inspect

- Overlapping tests, covered public behavior, fixtures, failure modes and historical regressions.
- Test runtime and maintenance cost with examples of repeated assertions or brittle setup.

## Workflow

1. Map the behavior and risk each candidate test protects. Similar setup or assertions do not by themselves prove redundancy.

2. Identify overlap at unit, boundary and integration levels. Retain tests that detect different failure paths, concurrency conditions or contract violations.

3. Remove or combine one supported duplicate at a time and preserve readable fixtures. Avoid replacing meaningful behavior tests with implementation-shaped assertions.

4. Run the affected tests and the required project gate. Record any lost coverage intentionally and explain why remaining tests still detect the relevant regression.

## Decision points

- Remove duplication only where two tests detect the same regression at the same boundary.
- Retain independent coverage for distinct paths, roles, retries or failure mechanisms even if fixtures look alike.

## Quality criteria

- The consolidated test states its behavioral oracle and fails when the protected contract breaks.
- Helpers reduce repeated setup without hiding relevant preconditions or assertions.
- Deleting tests does not erase boundary, integration or migration cases represented only once.
- Test names and fixtures let a maintainer see what risk each case protects.

## Validation and evidence

- Map old tests to retained behavior and run the focused suite.
- Where uncertainty is material, introduce or simulate a small mutation of the contract to confirm the test detects it.

## Avoid

- Do not replace several assertions with one snapshot that misses the important condition.
- Do not optimize runtime by deleting the only failure-path check.

## Completion

A leaner suite with preserved risk coverage. Use test-strategy to discover missing protection.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
