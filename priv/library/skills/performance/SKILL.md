---
name: performance
description: "Use when measured latency, freezes, excessive work or rendering cost affects a real workflow."
---

# Performance

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a page or LiveView mount is measured slower than its budget; when a request or job shows a long database share in telemetry or the dev dashboard; when a LiveView sends a large diff on every event; when a worker's throughput drops as a table grows; or when a user reports a freeze and a measurement confirms it. The entry condition is a number: a latency, a query time, a diff size, a queue depth.

This workflow treats only measured cost on a path that returns the right result. A spinner that never ends or a result that lands on the wrong record is [async-state](../async-state/SKILL.md) (correctness, not speed). A slow call because a GenServer sits in a long `handle_call` or its mailbox is growing is [process-lifecycle](../process-lifecycle/SKILL.md). A slow paid provider call goes to [provider-calls](../provider-calls/SKILL.md) first, because retries there cost money. Without a measurement, the symptom goes to [debugging](../debugging/SKILL.md).

## Inputs to inspect

- Start at: the measurement that triggered the request (a telemetry event, a dashboard timing, a log line with a duration, a user-reported path), then reproduce it with `:timer.tc/1` or a Benchee run around the suspected function. See [Telemetry and observability](../../ELIXIR.md#telemetry-and-observability).
- The path under measurement: router or job, context function, the queries it issues (log them with their params), and the templates and assigns it renders.
- Data shape at the measured scale: row counts, association depth, payload sizes; a path that is fast on seeds and slow in production differs in data, not in code.
- For LiveView: the diff size per event, assigns that change on every render, streams versus lists, and the number of processes per connected user. See [Phoenix and LiveView](../../ELIXIR.md#phoenix-and-liveview).
- Existing instrumentation and its labels, so the before and after numbers come from the same probe.

## Workflow

1. Write the measurement table: what was measured, where in the path, how many times, with which tool (telemetry handler, `:timer.tc/1`, Benchee if present, LiveView diff size, query log), at which data scale, and the number observed. Done when the table has a baseline that a second run reproduces within a stated spread.

2. Split the baseline by stage: queue wait, database, application code, serialization, render, network. Use the query log and telemetry spans; do not guess. Done when one stage holds the dominant share and is named.

3. Name the mechanism in that stage: N+1 queries, an unindexed filter, a preload wider than the view uses, a list re-sent instead of a stream, a computation inside the render path, a synchronous call into a slow process. Confirm it with one observation (the query count, the plan, the diff bytes). Done when the mechanism is confirmed, not inferred.

4. Change one thing at the mechanism: a preload or join, an index with its migration, a stream, a precomputed assign, a `Task` for the slow part. Preserve ordering, authorization and cancellation. Done when the change compiles and the focused tests pass.

5. Re-measure with the same probe, the same data and the same repeat count, and write the after number next to the before number. Done when the improvement exceeds the spread of the baseline; otherwise revert and return to step 3.

6. Record the remaining bottleneck, the tradeoff taken (freshness, memory, complexity) and the budget the path now meets or misses. Done when the handoff has before, after, tool and data scale.

## Decision points

- The dominant stage first; a 10 percent gain in a stage that is 5 percent of the path is noise.
- A measurement without a repeat count and a data scale is a hypothesis.
- A cache needs an invalidation rule and a scope before it is written; without them it is a correctness bug waiting to be found.
- An index is a migration with live-data consequences; coordinate with [migration-compatibility](../migration-compatibility/SKILL.md) when the table is large.
- When the slow stage is a blocked process, stop and route to [process-lifecycle](../process-lifecycle/SKILL.md).

## Quality criteria

- Before and after numbers come from the same probe, data scale, warmup and repeat count, and the spread is stated.
- Correctness, ordering, authorization and tenant scoping survive the change; the focused tests prove it.
- The measured path's budget is stated and the result is compared against it.
- Each tradeoff (memory, staleness, complexity) is named for the actual workload.

## Validation and evidence

- Minimum: the measurement table with the before and after number from the same probe, the tool, the repeat count and the data scale.
- When turns allow: the query log or telemetry span count for the path before and after, showing the mechanism removed.
- When the change adds an index or a migration: the migration run against a representative row count, with its duration.
- When the path is a LiveView: the diff size per event before and after.

## Avoid

- Do not claim a speedup from a single unmatched run.
- Do not add a cache without invalidation and scope.
- Do not optimize a stage that was not measured as dominant.
- Do not treat a stuck spinner or a wrong record as a speed problem.
- Do not change two mechanisms between measurements.

## Completion

A measurement table with before and after from the same probe, the dominant stage named, one mechanism removed, and the remaining bottleneck and tradeoff recorded; or a narrowed hypothesis with the next discriminating measurement. For a correctness fault in the same flow use [async-state](../async-state/SKILL.md); for a blocked or leaking process use [process-lifecycle](../process-lifecycle/SKILL.md); for the dashboard that tracks the budget use [metrics-costs](../metrics-costs/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
