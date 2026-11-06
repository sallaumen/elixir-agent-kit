---
name: ai-orchestration
description: "Use when agent jobs, queues, workers and model capacity are conflated or incorrectly accounted for."
---

# AI Orchestration

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when agent jobs, queues, workers and model capacity are conflated or incorrectly accounted for.

## Inputs to inspect

- Queues, workers, calls to models, agents, provider limits, cost/budget rules and current capacity telemetry.
- Job metadata indicating no AI, conditional AI or mandatory AI use, including how a running call is identified.

## Workflow

1. Map requests, jobs, workers, agents and provider calls as distinct entities. Trace which execution paths actually invoke a model, including conditional calls and delegation.

2. Identify the owner of admission control, concurrency, cancellation, retries and budget checks. Queue concurrency and provider capacity are different constraints.

3. Record calls and outcomes with sufficient provenance to reconcile usage without exposing prompts or secrets unnecessarily. Avoid counting a delegated call twice.

4. Test saturation, cancellation and failure using controlled responses. Do not add retries to paid or effectful calls without an explicit policy and duplicate-effect analysis.

## Decision points

- Separate queued work, reserved capacity and a model call actually running; a job is not automatically a model slot.
- When provider capacity or price is unknown, represent uncertainty instead of inventing a utilization number.

## Quality criteria

- Acquisition, release, timeout, cancellation and crash recovery keep capacity counters consistent.
- Conditional workers reserve capacity only at the point they may actually call a model; non-AI jobs do not consume it.
- Retries and duplicate jobs cannot spend twice without an explicit idempotency/budget rule; paid-call effects stay recorded at the authoritative boundary.
- Operational displays distinguish available, reserved, active, unknown and stale capacity so they support a real scheduling decision.

## Validation and evidence

- Exercise the limit with concurrent jobs, one conditional no-call path, cancellation and a failed call using fixtures or authorized test environments.
- Compare displayed capacity with observed call records and report what could not be measured.

## Avoid

- Do not count every worker or queued job as an AI session.
- Do not infer that a model name determines which agent harness or skills were loaded.

## Completion

An explicit execution/capacity contract and accounting aligned with observed behavior. The single call's budget gate, audit row, retry rule and failure reasons belong to [provider-calls](../provider-calls/SKILL.md); visual style belongs to the project design context.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
