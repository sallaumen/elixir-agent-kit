---
name: architecture-review
description: "Use when changes cross many modules, rules repeat, dependencies cycle or domain ownership is unclear."
---

# Architecture Review

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when changes cross many modules, rules repeat, dependencies cycle or domain ownership is unclear.

## Inputs to inspect

- Requested change and the current module, data, process and deployment boundaries that it touches.
- Callers, consumers, persisted contracts, existing decisions and the smallest representative path through the system.

## Workflow

1. Trace representative operations from entry point to data changes and output. Include failure, repetition and recovery where they affect responsibilities. Compare documented boundaries with the code that actually runs.

2. Identify data owners, public contracts, dependency direction and effects. Support each finding with a path, symbol or observed flow and a concrete maintenance or correctness consequence.

3. Prefer a small boundary correction that improves the selected operation. Do not equate pages with domains, line counts with quality, or a folder rearrangement with architectural improvement.

4. Check callers, callbacks, configuration, serialization and persisted jobs before changing a public boundary. Validate the affected contracts and failure paths.

## Decision points

- Distinguish a structural risk visible in the actual change from a hypothetical future need.
- Choose whether to repair the boundary now, record a follow-up with evidence, or leave an established pattern intact.

## Quality criteria

- Each finding names the owner of the behavior, the dependency crossing it and the consequence for a real use case.
- Recommendations keep one accountable source for data and avoid new cyclic or bidirectional dependencies.
- The review considers runtime processes, async messages, database effects and public contracts where present.
- The proposed shape can be introduced in bounded steps without silently changing unrelated behavior.

## Validation and evidence

- Trace at least one real call or data path from entry point to effect and a consumer of its result.
- For each significant recommendation, show the affected boundary, migration cost and a verification path.

## Avoid

- Do not turn a small change into a speculative rewrite.
- Do not label a module “bad architecture” without a concrete failure or maintenance cost.

## Completion

An evidence-backed boundary assessment and, only when authorized, a bounded correction. Use abstraction-layers for meaning within a module and module-design for an already-understood organizational change.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
