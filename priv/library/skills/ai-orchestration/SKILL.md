---
name: ai-orchestration
description: "Use when agent jobs, queues, workers and model capacity are conflated or incorrectly accounted for."
---

# AI Orchestration

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when the operations screen shows "8 agents running" while the provider console shows two requests in flight; when an Oban queue with `concurrency: 10` is treated as the model's rate limit, or the other way around; when a job that only sometimes calls a model is counted as a model slot from the moment it is enqueued; when a job that delegates to a second job is billed or counted twice; when a provider returns 429 and nobody can say which queue should slow down; or when a crashed worker leaves a capacity counter that never comes back down.

This workflow owns capacity and accounting across many jobs, queues, workers and providers. The single outbound call, its budget gate and its audit row belong to [provider-calls](../provider-calls/SKILL.md); the state of one worker process (init, timeout, crash, restart) belongs to [process-lifecycle](../process-lifecycle/SKILL.md); whether a stuck queue should page someone belongs to [operational-alerts](../operational-alerts/SKILL.md).

## Inputs to inspect

- Start at: the Oban configuration (`config :app, Oban, queues: ...`) and `grep -rn "queue:" lib/` for every worker, then the one screen or log line where the capacity number looked wrong.
- Every path that reaches a model: workers that always call, workers that call only on a condition, and workers that enqueue another worker which calls. Draw the delegation chain.
- The provider limits as documented today (requests per minute, tokens per minute, concurrent requests per key) and where the project stores them; note the date read.
- The counter or semaphore that claims to track active calls: who increments, who decrements, and what happens on timeout, cancellation and a crashed process.
- The telemetry and audit rows already emitted per job and per call, and whether a job id links them. See [Oban](../../ELIXIR.md#oban), [OTP processes and supervision](../../ELIXIR.md#otp-processes-and-supervision) and [Telemetry and observability](../../ELIXIR.md#telemetry-and-observability).

## Workflow

1. Write the capacity table: one row per queue and per provider key with columns for queue concurrency, provider limit, what reserves a slot, what releases it, and which workers may call a model (always, conditional, by delegation). Done when every worker that can reach a provider appears in exactly one row and the delegation chains are drawn.

2. Trace one job from enqueue to the provider and back, with its job id, through the counter, the client and the audit row. Done when you can state at which line the job became a model call and at which line the slot was released, or that one of those lines does not exist.

3. Put the model reservation at the point where the call actually happens, inside the worker, after the condition that decides whether a model is needed, and release it in an `after` block or from a monitoring process so timeout, cancellation and crash all release it. Done when a non-AI job can run to completion without touching the counter.

4. Separate the two constraints in code: Oban queue concurrency bounds workers; a per-provider limiter (rate limit or semaphore keyed by provider and key) bounds model calls, and a job that cannot acquire a provider slot snoozes or backs off instead of failing. Done when a 429 maps to one named limiter and one retry policy.

5. Attribute each call once: the audit row carries the job id and the delegating job id when there is one, and cost rollups count the leaf call only. Done when a delegated chain produces one row with cost and the parent rows carry a reference, not a copy.

6. Make the display tell the truth: available, reserved, active, unknown and stale are distinct values derived from the counter and the audit rows, never from the number of queued jobs. Done when an unknown provider limit renders as unknown rather than as a percentage.

7. Test saturation at the limiter with concurrent jobs, one conditional no-call path, a cancellation mid-call and a worker crash, asserting the counter returns to zero. Done when the tests pass with controlled provider responses and the project gate is green.

## Decision points

- A queued or running job is not a model slot; only an in-flight provider request is. Count at the call, not at the enqueue.
- Queue concurrency and provider capacity are two limits with two owners; never set one to express the other.
- Reserve as late as possible and release on every exit path, including crash; a counter without crash recovery is a counter that drifts.
- A delegated call is counted and billed once, at the leaf; parents reference it.
- Unknown limit or price is represented as unknown; a utilization number requires a known denominator.
- Retries of paid calls follow the idempotency rule in [provider-calls](../provider-calls/SKILL.md); orchestration never adds a retry on top of the client's.

## Quality criteria

- Acquire, release, timeout, cancellation and crash leave the capacity counter consistent, and a test proves it with a killed worker.
- Conditional workers reserve capacity only on the branch that calls a model; non-AI jobs never touch the limiter.
- A 429 or quota error slows exactly the limiter for that provider and key, with a named backoff, without blocking unrelated queues.
- Every audit row has a job id and every job that called a model has exactly one leaf row; rollups match the provider console on a small sample.
- Operational displays distinguish available, reserved, active, unknown and stale, and a reader can make a scheduling decision from them.

## Validation and evidence

- Minimum: a test that enqueues more jobs than the provider limiter allows with controlled responses, asserts the number of concurrent provider calls never exceeds the limit, and asserts the counter is zero afterwards, including one job that crashes mid-call (`Oban.Testing` with `perform_job/3` and a fake client).
- When turns allow: the conditional no-call path and a delegated chain, asserting one leaf audit row and no reservation on the no-call branch.
- When turns allow: a cancellation during an in-flight call, asserting release and a typed outcome on the job.
- When the session has console access: compare the displayed active count and a sample of audit rows against the provider's console, and report what could not be compared.

## Avoid

- Do not count every worker, queued job or open socket as an AI session.
- Do not express a provider rate limit as Oban queue concurrency, or the reverse.
- Do not add retries to paid calls at the orchestration layer; the client owns retry semantics.
- Do not infer the agent harness, prompt or skills loaded from the model name in a row.
- Do not reserve capacity in `init` or at enqueue time for a job that may never call a model.

## Completion

An explicit capacity contract: one table of queues, limiters and provider limits, reservation at the call with release on every exit path, one audit row per leaf call linked by job id, displays that distinguish unknown from zero, and tests for saturation, cancellation and crash. For the single call's budget gate and audit row use [provider-calls](../provider-calls/SKILL.md); for the cost rollup those rows feed use [metrics-costs](../metrics-costs/SKILL.md); for a worker that hangs or restarts use [process-lifecycle](../process-lifecycle/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
