---
name: async-state
description: "Use when progress stalls, success appears too early or stale asynchronous results overwrite current state."
---

# Async State

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when progress stalls, success appears too early or stale asynchronous results overwrite current state.

## Inputs to inspect

- Event and job lifecycle, stable IDs, persisted state, retries, cancellation and reconnect behavior.
- What each actor can observe, including a stale page, duplicate delivery and network outage.

## Workflow

1. Trace the command, queued or running work, persisted result and user-visible state. Identify which component owns each transition.

2. Model pending, running, completed, failed, canceled and unknown only as supported by actual evidence. A submitted request is not a completed operation.

3. Correlate results with their request, entity and version. Prevent late responses from replacing newer selections; define reconnect, refresh and subscription cleanup behavior.

4. Exercise out-of-order completion, partial failure and recovery. Keep the last valid state when a network failure prevents a fresh read.

## Decision points

- Define one durable state owner and distinguish request accepted, work queued, started, completed and observed.
- Choose idempotency and ordering semantics per effect rather than assuming events arrive once or in sequence.

## Quality criteria

- The UI and API can reconcile after reconnect or reload using persisted identifiers and a current-state read.
- Retries and duplicate messages do not repeat irreversible effects or falsely advance state.
- Cancellation and timeouts have explicit transitions, including races with a completed job.
- Failures surface a recoverable or terminal status with enough context for a user or operator to act.

## Validation and evidence

- Exercise duplicate, delayed and out-of-order delivery plus disconnect and reconnect on a representative flow.
- Show the durable state and what the user sees at each transition; identify untested external effects.

## Avoid

- Do not use a transient toast as the only record of completion.
- Do not equate HTTP success with background job success.

## Completion

A truthful state lifecycle that survives refresh, reconnection and stale responses without invented success.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
