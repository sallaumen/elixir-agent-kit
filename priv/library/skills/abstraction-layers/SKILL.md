---
name: abstraction-layers
description: "Use when functions mix business decisions, low-level details and effects at incompatible levels."
---

# Abstraction Layers

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when functions mix business decisions, low-level details and effects at incompatible levels.

## Inputs to inspect

- A real public entry point and immediate collaborators that mix domain decisions, calculations, data access or effects.
- The callers, effect ordering, transaction boundaries and tests protecting current observable behavior.

## Workflow

1. Choose one real operation and read its public entry point and immediate collaborators. Describe the vocabulary a reader must understand at each level.

2. Identify business decisions obscured by transport, persistence, parsing or UI mechanics. Separate actions, calculations and data when this makes effects and dependencies visible.

3. Extract cohesive operations with names from the domain. Keep small calculations as functions; a new abstraction does not imply a new process, context or framework.

4. Compare the before and after call paths. The caller should express a coherent operation without forcing the reader to chase a chain of trivial wrappers. Test observable behavior and effect boundaries.

Preserve effect order, count, error handling and transaction boundaries while extracting calculations. Actions, calculations and data are analytical lenses, not three mandatory directories. Do not create sprawling parameter bundles just to claim purity; keep co-changing details together.

## Decision points

- Extract an abstraction only when it shields a detail likely to change or makes the caller express a coherent domain operation.
- Keep co-changing logic close; use actions, calculations and data as lenses, not three mandatory folders.

## Quality criteria

- A reader can follow the business intent without chasing a chain of one-line wrappers or decoding transport mechanics.
- Function names describe an operation at a consistent level of meaning; stable rules depend on lower-level details in a deliberate direction.
- A pure calculation may be extracted, but effect count, order, error propagation and transaction semantics stay intact.
- Inputs remain understandable; avoid a sprawling parameter bundle created only to claim functional purity.

## Validation and evidence

- Compare the before/after call path for one complete slice and exercise success and failure cases around effects.
- Explain the old mixing point, the new boundary, why it earns its cost and any consumers not yet migrated.

## Avoid

- Do not use line count or new directories as proof of improved abstraction.
- Do not split a flow into layers that force readers to jump across files for every simple decision.

## Completion

A clearer operation with justified abstraction boundaries and preserved behavior. Whole-system domain ownership belongs to architecture-review.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
