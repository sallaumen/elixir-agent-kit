---
name: simulation-isolation
description: "Use when simulation, training or demo flows share code and data paths with real operations."
---

# Simulation Isolation

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when simulation, training or demo flows share code and data paths with real operations.

## Inputs to inspect

- Mode selection, data sources, credentials, providers, database scopes, jobs and write APIs for the selected flow.
- Shared domain rules that should behave the same in simulation and production, plus effects that must differ.

## Workflow

1. Map environment identity and the boundaries around data, credentials, jobs and external effects. Confirm the mode at the effect boundary, not only in a visual label.

2. Define what is simulated and what remains real. Keep scenarios reproducible and distinguish training outcomes from production metrics.

3. Trace reset, replay and cleanup operations to their exact storage scope. Preserve unrelated history and require explicit authority for destructive operations.

4. Test that a simulated path cannot invoke the production effect and that production does not consume simulated records. Include queued work and stale configuration.

## Decision points

- Share pure business rules when their meaning matches; route side effects through distinct boundaries based on verified context.
- If a visual mode label is the only isolation, treat the boundary as unproven.

## Quality criteria

- Simulation cannot reach real orders, payments, messages or provider writes through a hidden common code path.
- Context (world, account, environment or run) is carried through storage, queues, cache and reconnect behavior.
- Test data remains identifiable and cannot be promoted into a real account by a stale job or URL.
- Representative rules match production semantics where needed; knowingly simplified behavior is documented as such.

## Validation and evidence

- Use safe fakes to trace a simulated action to the effect boundary and assert absence of real calls.
- Test mode switching and replay of a persisted job where these can cross the boundary; report fidelity limits.

## Avoid

- Do not rely on color or copy to enforce isolation.
- Do not duplicate the whole domain merely to keep simulation separate.

## Completion

Demonstrated isolation and coherent scenario lifecycle, with any mixed real/simulated effects explicitly documented.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
