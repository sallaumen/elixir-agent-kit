---
name: simulation-isolation
description: "Use when simulation, training or demo flows share code and data paths with real operations."
---

# Simulation Isolation

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a demo or training run enqueues the same Oban worker as production and that worker calls a paid provider or sends a real message; when simulated orders, runs or accounts appear in the operator dashboard or in the monthly totals; when "reset the demo" deletes rows by a filter that also matches real history; when the only thing that distinguishes a sandbox session from a live one is a banner in the layout; or when a job inserted during a simulation is picked up after the mode is switched back and acts on real data.

This workflow owns the boundary between a simulated flow and real operations: which modules, tables, queues and providers both touch, and the flag or scope that separates them at the effect. The single provider call's budget and audit row belong to [provider-calls](../provider-calls/SKILL.md); tenant and credential boundaries in general belong to [security-boundaries](../security-boundaries/SKILL.md); totals that must exclude simulated rows belong to [metrics-costs](../metrics-costs/SKILL.md).

## Size

- **Small**: close one shared effect path with the context key and prove a simulated action reaches no real client; skip the full shared-path map.
- **Medium**: run the workflow as written for one flow: the shared-path map, the separating boundary and the end-to-end fake-client tests.
- **Large**: the whole simulation surface across modules and queues; slice per effect boundary, and route the fake client to provider-calls or tenant and credential boundaries to security-boundaries as later slices.

## Inputs to inspect

- Start at: how the mode is selected (`grep -rn "simulat\|sandbox\|demo\|training" lib/ config/`) and the one effect (a provider call, a send, a payment, a publish) the user fears the simulation could trigger.
- Every effect boundary the simulated flow can reach: provider clients, mailers and bots, payment and marketplace calls, file storage, external webhooks; and whether each reads the mode or trusts the caller.
- Storage scope: which tables hold simulated rows, the column or scope that marks them (world, account, environment, run id), and the queries, caches and PubSub topics that filter by it or do not.
- Jobs: which workers both flows enqueue, whether the job args carry the mode, and what happens to a queued simulated job after a restart or a mode switch. See [Oban](../../elixir/oban.md).
- Reset, replay and cleanup operations and the exact filter each deletes by. See [Ecto and migrations](../../elixir/ecto.md) and [Security](../../elixir/security.md).

## Workflow

1. Write the shared-path map: one row per module, table, queue, cache, topic and provider that both flows touch, with columns for how each flow reaches it, which context key (world, account, environment, run id) is present at that point, and whether the mode is checked there, upstream only, or not at all. Done when every effect boundary from the inputs appears as a row and each row's "checked" column is filled.

2. Pick the separating boundary: one context value carried from the entry point through assigns, job args, records and topics, checked at the effect, with the simulated branch routed to a fake or a sandbox client. Done when the value and its carrier at each hop are written next to the map.

3. Close the shared paths: effect modules read the context and refuse or redirect the simulated branch; queries, caches and topics are scoped by the same key; shared pure rules stay shared. Done when the map shows no row where a simulated flow reaches a real effect through an unchecked path.

4. Make jobs carry the mode in their args and check it in `perform/1`, so a job queued during a simulation and run later still takes the simulated branch; cancel or discard simulated jobs on reset. Done when a persisted simulated job executed after a mode switch produces no real effect in a test.

5. Scope reset, replay and cleanup to the run or world identifier only, require explicit authority for the destructive operation, and keep unrelated history. Done when a reset in a test deletes only rows with the target run id and real fixtures remain.

6. Keep simulated rows out of real views and totals, and label knowingly simplified rules as such where the simulation diverges from production semantics. Done when the operator dashboard and the metric queries filter by the context key and the divergences are listed.

7. Test a simulated action end to end to each effect boundary with fakes, asserting no real client was called, and test the reverse: a real flow never reads simulated rows. Then run the project gate. Done when the tests pass and the shared-path map has no open rows.

## Decision points

- Isolation is enforced at the effect boundary, never only by a label, a route or a banner.
- One context key travels the whole path (assigns, job args, records, topics); a hop that drops it is a finding.
- Pure business rules are shared when their meaning is identical; side effects are routed by verified context, not duplicated.
- A job's mode comes from its args, not from the application's current mode at execution time.
- Destructive reset requires an explicit scope and explicit authority; a filter that could match real rows is wrong even if it has not yet.
- Where fidelity is knowingly reduced, the divergence is documented next to the rule, not hidden.

## Quality criteria

- No path lets a simulated flow reach real orders, payments, messages, publishes or provider writes; the test suite proves it per effect boundary with fakes.
- The context key survives storage, queue, cache, PubSub and reconnect, and a test checks the persisted job case.
- Simulated rows are identifiable and excluded from real views, totals and exports by the same scope.
- Reset and replay touch only the targeted run and require authority; real history is unchanged after a reset in a test.
- Shared rules match production semantics or carry a documented, labeled divergence.

## Validation and evidence

- Minimum: a test that runs one simulated action through to every effect boundary in the map with fake clients and asserts the real client received zero calls, plus the persisted simulated job executed after a mode switch still producing no real effect (`Oban.Testing` with `perform_job/3`).
- When turns allow: a real flow asserting it reads zero simulated rows, and a reset asserting only the target run's rows are gone.
- When turns allow: the finished shared-path map with each row's checked column and the context carrier per hop.
- When the project has a sandbox provider: one simulated call reaching the sandbox and visible there; otherwise state that fidelity was asserted only with fakes.

## Avoid

- Do not rely on color, copy, a banner or a URL prefix to enforce isolation.
- Do not duplicate the whole domain to keep simulation separate; scope the effects and the data.
- Do not read the current application mode inside a job; the job's args say what it is.
- Do not reset or replay with a filter wider than the run or world identifier.
- Do not run a simulation against live credentials to check fidelity.

## Completion

A shared-path map with no open rows, one context key carried end to end and checked at each effect, jobs that carry their mode, scoped reset and replay with explicit authority, simulated rows excluded from real views and totals, and tests that prove no real effect from a simulated action. For the fake or sandbox client itself use [provider-calls](../provider-calls/SKILL.md); for tenant and credential boundaries use [security-boundaries](../security-boundaries/SKILL.md); for totals that must exclude simulated rows use [metrics-costs](../metrics-costs/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
