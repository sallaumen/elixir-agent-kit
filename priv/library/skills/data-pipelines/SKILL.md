---
name: data-pipelines
description: "Use when a flow of many items (an import, a stream, a fan-out or a queue consumer) loses, duplicates, stalls or runs out of memory, or its back-pressure, batching or acknowledgement is unclear."
---

# Data Pipelines

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a CSV import of a few gigabytes exhausts memory or inserts some rows twice; when a Broadway consumer on RabbitMQ redelivers the same poisoned message forever and every other message waits behind it; when a Kafka consumer commits offsets for messages that failed and they vanish; when `Task.async_stream` over thousands of URLs times out the caller or hammers a provider; when a `Repo.stream/2` export holds a transaction open for an hour; or when a new feature needs to process a large or unbounded flow and nobody has decided how items are acknowledged, retried, batched or bounded.

The separating rule: the flow of many items and its delivery guarantees is this workflow; CI and validation pipelines are [pipeline-design](../pipeline-design/SKILL.md); one GenServer's state, mailbox or restart is [process-lifecycle](../process-lifecycle/SKILL.md); a single paid call inside the flow is [provider-calls](../provider-calls/SKILL.md); capacity shared across agent workers and queues is [ai-orchestration](../ai-orchestration/SKILL.md); a measured slow path that returns correct results is [performance](../performance/SKILL.md). Background work that starts in the application's own database and must be retried is usually an Oban job; see [Oban](../../elixir/oban.md).

## Inputs to inspect

- Start at: the entry point of the flow (the Broadway module and its producer options, the function that opens the file or stream, the `Task.async_stream/3` call, the GenStage producer), then its last effect (the insert, the outbound call, the acknowledgement).
- Delivery semantics of the source: what happens to an unacknowledged or failed item (redelivery after a visibility timeout, requeue, offset commit, nothing), and whether the source can deliver the same item twice.
- The identity of an item that survives redelivery (message id, row key, file line plus file checksum) and where the effect is made idempotent by it.
- Bounds: concurrency per stage, batch size and timeout, `max_concurrency` and `timeout` of fan-outs, memory per item, and the capacity of the downstream system (database pool, provider rate limit).
- Failure handling: `handle_failed/2`, dead-letter configuration, logs and telemetry per failed item, and what an operator can replay. See [Pipelines and control flow](../../elixir/pipelines.md) and [Telemetry and observability](../../elixir/telemetry.md).
- Tests that drive the flow, and whether any of them sends a poisoned item or a duplicate.

## Workflow

1. Write the flow card: source and its delivery semantics, item identity, each stage with its concurrency and batching, the effect at the end, how success and failure are acknowledged, and the bound on memory and on downstream load. This card is the artifact every later step reports against. Done when every stage has its bound and the source's behavior for a failed item is written from its documentation, not assumed.

2. Reproduce the reported symptom with a controlled input: a poisoned item, a duplicate delivery, an input larger than memory at test scale, a slow downstream, a crash mid-batch. Done when the symptom appears in a test or a recorded local run.

3. Make the effect idempotent by item identity (a unique key with `on_conflict`, a processed-items table claimed before acting, an idempotency key on the outbound call), so redelivery cannot duplicate. Done when the duplicate-delivery test shows one effect.

4. Decide the failure path per item: acknowledge-and-record, retry a bounded number of times, or send to a dead-letter destination an operator can replay. For Broadway, configure the producer's failure option instead of relying on defaults that redeliver forever or commit failures away. Done when the poisoned-item test shows the item leaving the flow with a record and the rest proceeding.

5. Bound the flow: stream instead of loading (`Stream`, `Repo.stream/2` in short transactions or keyset pages), fan out with explicit `max_concurrency` and `timeout`, size batches to the downstream capacity, and keep the caller alive when one item times out. Done when the large-input test stays within the stated memory bound and the downstream sees no more than the stated concurrency.

6. Make the flow observable: count processed, failed, retried and dead-lettered items with telemetry or logs that carry the item identity, then run the focused tests and the project gate. Done when the handoff states the card, the tests and the remaining unbounded parts.

## Decision points

- At-least-once is the default assumption for any queue or retrying source; idempotency at the effect is the only defense against duplicates.
- A failure path that redelivers without limit is a stall, not a retry policy.
- Work that originates in the application's own database and must survive restarts is an Oban job; Broadway is for external queues; `Task.async_stream` is for bounded in-memory fan-out within one request or job.
- Bounds come from the downstream capacity (pool size, provider rate limit), not from the number of schedulers alone.
- GenStage stages model runtime concerns (buffering, concurrency), never one stage per business step.

## Quality criteria

- Every stage has a stated concurrency, batch and timeout, and the memory per item is bounded.
- A duplicate delivery produces one effect, proven by a test.
- A poisoned item leaves the flow with a record and does not block the others.
- The acknowledgement semantics of the source are written with their documentation source and version.
- Processed, failed and dead-lettered counts are observable with item identity.

## Validation and evidence

- Minimum: the flow card plus a test that delivers a poisoned item and a duplicate, asserting one effect for the duplicate, a recorded failure for the poisoned item, and the remaining items processed.
- When turns allow: a large-input run at test scale with memory or row counts recorded before and after.
- When Broadway is used: `Broadway.test_message/3` or `test_batch/3` with `Broadway.DummyProducer`, asserting the `{:ack, ref, successful, failed}` message.
- When a fan-out was bounded: a test or local run showing `max_concurrency` and the timeout path keeping the caller alive.

## Avoid

- Do not raise the concurrency until the error disappears; bound it by the downstream capacity.
- Do not load a whole file or table into memory to process it item by item.
- Do not rely on a producer's default failure behavior without reading what it does.
- Do not hold one database transaction open across a long stream.
- Do not split business steps into GenStage stages.

## Completion

A flow card with every stage bounded and the source's semantics written, idempotent effects proven against a duplicate, a poisoned item that leaves the flow with a record, a large input within its memory bound, and observable counts, with the project gate green. For a GenServer inside the flow use [process-lifecycle](../process-lifecycle/SKILL.md); for a paid call inside it use [provider-calls](../provider-calls/SKILL.md); for CI pipelines use [pipeline-design](../pipeline-design/SKILL.md); for a measured slow but correct flow use [performance](../performance/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
