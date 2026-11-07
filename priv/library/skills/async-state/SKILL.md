---
name: async-state
description: "Use when progress stalls, success appears too early or stale asynchronous results overwrite current state."
---

# Async State

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when the interface says "done" before the work finished, when a spinner never ends, when a late or duplicate message changes the wrong record, when a reload or reconnect shows a different state than before, or when a retry repeats an effect. Use it for a new asynchronous feature as well as for a reported symptom.

The question this workflow answers is: who owns each state transition, how is a result matched to the request that caused it, and what does every observer see after a disconnect, a duplicate or an out-of-order message.

## Inputs to inspect

- Start at: the LiveView or process whose assign or state is overwritten, and its `handle_async`, `handle_info` and `handle_event` clauses that write it.
- The command path: the user action or trigger, the request it sends, the job or process that runs, the persisted result, and the message that tells the interface.
- Identity: which stable identifier (entity id plus revision, job id, request id) travels through every step, and where a step uses something weaker (position, "latest", the socket).
- Durable state versus transient state: what is in the database, what lives in a process, what lives in socket assigns, and which one the interface reads after reload.
- Delivery semantics of each hop: PubSub broadcast, Oban retries, provider webhooks, HTTP responses. Assume at least-once and unordered unless the code proves otherwise.
- The user-visible states and what each actor can observe during a disconnect. See [Phoenix and LiveView](../../ELIXIR.md#phoenix-and-liveview) and [Oban](../../ELIXIR.md#oban).

## Workflow

1. Draw the lifecycle as transitions with an owner: accepted, queued, running, completed, failed, cancelled, unknown. Name the component that may perform each transition and the durable record it writes. If two components can both write "completed", that is the first finding.

2. Trace one real request end to end with its identifiers. Mark every hop where the result is matched to the request by something other than a stable key. A message keyed by "the current task" instead of the task's id is a stale-overwrite bug waiting for a delay.

3. Reproduce the symptom with a controlled ordering: delay the first result until after the second request, deliver a message twice, disconnect between request and result, reload mid-progress. In LiveView, `start_async` and `handle_async` make the ordering explicit; in tests, send the messages yourself.

4. Fix the owner and the key, not the symptom. Results carry the key they belong to and are dropped when the key no longer matches the current selection; the interface derives its state from the durable record after reconnect instead of trusting the last message; retries are idempotent at the effect, not only unique at the queue.

5. Define cancellation and timeout as transitions with their own races: a cancel that arrives after completion, a timeout that fires while the job is finishing. Decide which wins and write it down.

6. Exercise duplicate, delayed, out-of-order, disconnect and reload on the real flow, then run the focused tests and the project gate.

## Decision points

- One durable owner per state; the interface is a view of it, never the source. If the only record of completion is a flash or a toast, the state is lost on reload.
- Push, do not poll: subscribe once in the connected mount, dedupe broadcasts by content or sequence, and let the server tell the view. Polling the database from the browser is a last resort and must be justified.
- Match results by stable key (entity id plus revision or request id). "Most recent" is not a key.
- Accepted is not done: an HTTP 200 for the enqueue, a job inserted, or a message sent are each one transition, not success.
- Idempotency per effect: a retried job must not charge, send or publish twice; uniqueness at enqueue time does not provide this.
- On failure to read fresh state (network down, provider timeout), keep and label the last valid state; never invent a success or a zero.

## Quality criteria

- After a reload or reconnect, the interface reconstructs the same state from persisted identifiers and a current-state read; no transition depends on the socket having been alive.
- A delayed or duplicate message cannot advance state falsely or overwrite a newer selection; the test suite proves it with explicit orderings.
- Cancellation and timeout are explicit transitions with defined winners in their races with completion.
- Every failure surfaces as a recoverable or terminal status with enough context for the user or operator to act; "unknown" is a legitimate displayed state.
- Retries and duplicate deliveries never repeat an irreversible effect.

## Validation and evidence

- Minimum: one test that delivers the result out of order, twice or after a reconnect and asserts both the durable state and what the view renders. In LiveView, `Phoenix.LiveViewTest` with messages sent to the view process; for jobs, `Oban.Testing` with a retried `perform_job/3`.
- When turns allow: a written lifecycle table (transition, owner, durable record) for the flow, and the identifiers traced through one real request.
- When turns allow: a manual pass on the running application for the reported symptom and for a reload mid-progress, with what was observed at each step.
- When turns allow: any external effect that could not be exercised, named.

## Avoid

- Do not key results by position, "latest" or the socket; do not treat a broadcast as proof the record changed.
- Do not equate HTTP success, enqueue success or "message sent" with completion.
- Do not use a toast, flash or in-memory assign as the only record of a transition.
- Do not add `Process.sleep` or longer timeouts to make an ordering test pass; make the ordering explicit instead.
- Do not retry a paid or external effect to recover a stuck state without an idempotency key.

## Completion

A lifecycle with one durable owner per transition, results matched by stable keys, explicit cancellation and timeout races, and tests that deliver duplicate, delayed and out-of-order messages across a reconnect. For a slow but correct flow use [performance](../performance/SKILL.md); for a paid or rate-limited provider call use [provider-calls](../provider-calls/SKILL.md); for state lost or doubled after restart use [process-lifecycle](../process-lifecycle/SKILL.md); for the operational alert that a stuck job should raise use [operational-alerts](../operational-alerts/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
