---
name: performance
description: "Use when measured latency, freezes, excessive work or rendering cost affects a real workflow."
---

# Performance

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when measured latency, freezes, excessive work or rendering cost affects a real workflow.

## Inputs to inspect

- A measured symptom with environment, workload, scale, baseline and target for the affected path.
- Instrumentation, query traces, process/queue metrics, render profiles or benchmark data relevant to that symptom.

## Workflow

1. Reproduce the slow operation and record a baseline under stated data, device and workload conditions. Choose a measurement that reflects user impact.

2. Trace expensive database queries, repeated work, blocking calls, rendering and resource lifecycles. Use a profiler or targeted instrumentation before attributing the issue to a framework.

3. Change one supported cause and compare under equivalent conditions. Preserve correctness, cancellation, cleanup and observability.

4. Report improvement with its measurement limits. An asynchronous state bug belongs to async-state even if it appears as a spinner.

## Decision points

- Prioritize the dominant measured cost and distinguish latency, throughput, memory and user-perceived responsiveness.
- Choose the smallest change that addresses the mechanism; an unmeasured optimization remains a hypothesis.

## Quality criteria

- Before/after measurements use comparable inputs, warmup, configuration and statistical summary.
- Correctness, ordering and authorization survive caching, batching or concurrency changes.
- The performance budget includes queueing, database, network and client rendering where those dominate.
- Tradeoffs in resource use, freshness and complexity are stated for the actual workload.

## Validation and evidence

- Capture a baseline and rerun the same representative workload after the change.
- Report units, sample size or repeat count, environment and remaining bottleneck.

## Avoid

- Do not claim a speedup from a single unmatched run.
- Do not add a cache without invalidation and scope rules.

## Completion

A measured diagnosis and improvement, or a narrowed hypothesis with the next discriminating measurement.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
