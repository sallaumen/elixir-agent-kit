---
name: process-lifecycle
description: "Use when a GenServer, Task, poller or supervised process holds state, leaks, blocks callers, duplicates work or behaves differently after a restart."
---

# Process Lifecycle

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a process is the suspect: a poller that broadcasts the same thing twice, a mailbox that grows, a `GenServer.call` that times out under load, state that vanishes or doubles after a crash or deploy, a `Task` nobody awaits, or a new feature that someone wants to "make a GenServer". Use it before writing the process as well as when one misbehaves.

The user-visible side of asynchronous work (what the interface shows after reconnect, stale results) belongs to [async-state](../async-state/SKILL.md); this workflow is about the BEAM runtime: ownership, supervision, backpressure and restart. A flow of many items (an import, a stream, a queue consumer) and its delivery guarantees is [data-pipelines](../data-pipelines/SKILL.md).

## Size

- **Small**: fix one blocking callback or one duplicate in one process with one test; skip the full tree review.
- **Medium**: run the workflow as written for one suspect process: the reason, the owner, the rebuild path and the restart, duplicate and burst tests.
- **Large**: many processes in the tree; slice per process, and route the interface's view of async to async-state or a flow of many items to data-pipelines as later slices.

## Inputs to inspect

- Start at: the suspect GenServer (or Task, poller) module and its place in the supervision tree: `Application.start/2`, child specs, restart strategies, and which processes are started on demand (`DynamicSupervisor`, `Task.Supervisor`).
- For each suspect process: what state it holds, who else holds a copy, what writes it to durable storage, and what rebuilds it after restart.
- Its message sources (timers, PubSub, monitors, callers) and the work it does per message; blocking calls inside callbacks; `call` timeouts on both sides.
- Mailbox and memory under load (`Process.info/2` with `:message_queue_len`, `:memory`), and the dedupe or sequencing applied before it broadcasts.
- Tests that start the process and what they assert. See [OTP processes and supervision](../../elixir/otp.md).

## Workflow

1. Decide whether a process is warranted: it owns state, a lifecycle or a concurrency limit. If it only groups functions, use functions. If several callers each need their own state, use one process per caller or none. Write one line per candidate process (state owned, lifecycle or limit, or none). Done when each candidate has a verdict.

2. Name the owner of each piece of state and the durable source it can be rebuilt from. State that exists only in a process is lost on restart; decide whether that is acceptable and say so. Done when each piece of state has an owner and a durable source it can be rebuilt from, or is declared acceptable to lose.

3. Trace one message from source to effect. Mark blocking work in `handle_call`/`handle_info` (external calls, database queries, broadcasts to many subscribers) and move it to `handle_continue/2`, a `Task` under a supervisor, or a separate process, keeping the owner single-writer. Done when each blocking point is moved off the callback and the owner stays single-writer.

4. Make repeated input idempotent at the process: dedupe by content hash or sequence number before broadcasting, ignore stale monitor or timer messages by reference, and bound the mailbox with backpressure (reply only when capacity allows, drop or coalesce when documented). Done when duplicate and stale messages produce no duplicate effect and the mailbox stays bounded under the expected burst.

5. Choose restart behavior for the failure actually expected: `:transient` for one-shot work, `:permanent` with a rebuild-from-storage `init/1` or `handle_continue` for owners, a max-restart budget that stops a crash loop instead of hiding it, and shutdown timeouts that let in-flight work finish. Done when each process has a restart strategy for the failure expected and a max-restart budget that stops a crash loop.

6. Test the lifecycle: start under a test supervisor, deliver a duplicate and an out-of-order message, kill the process and assert the rebuilt state, and measure the mailbox under a burst. Then run the project gate. Done when restart, duplicate, out-of-order and a burst pass in a test and the gate is green.

## Decision points

- Function unless state, lifecycle or a limit demands a process; a module with `start_link` and no state is a function wearing a costume.
- One writer per state; readers go to ETS, the database or a read model, never to a `call` on a hot path that can time out.
- `call` for a reply the caller needs now, with an explicit timeout the caller handles; `cast` or a message when it does not, with backpressure defined.
- Restart rebuilds from durable truth; a process that cannot be rebuilt is a bug waiting for a deploy.
- Timers and monitors are matched by reference; a stale `:tick` or `:DOWN` is dropped, not acted on.
- One module owns every message to a process; a `GenServer.call/3` on its registered name from another module is a finding (scattered process interface). Send the fields a process needs, not a whole conn, socket or large struct, because messages are copied.
- A periodic process reschedules inside its tick handler and survives a known flaky source (rescue that failure and keep the schedule); otherwise one bad read per tick spends the supervisor's restart budget and takes siblings down with it. Its interval is configuration, stretched in the test environment.

## Quality criteria

- Every process in the tree has a stated reason, an owner of its state, and a rebuild path after restart; the handoff names them.
- No callback blocks on external work; `call` timeouts are explicit on both sides and the caller survives `:timeout`.
- Duplicate or stale messages produce no duplicate effect or broadcast; the mailbox stays bounded under the project's expected burst.
- A crash restarts cleanly without losing committed state or replaying an irreversible effect, and a crash loop stops with a visible error.
- Tests exercise restart, duplicate delivery and a burst, not only the happy path.

## Validation and evidence

- Minimum: one test with `start_supervised!/1` that reproduces the reported failure (kill the process and assert rebuilt state, deliver a duplicate or out-of-order message, or send a burst with a mailbox assertion) and passes after the fix.
- When turns allow: the tree and ownership table (process, state, durable source, rebuild path, restart strategy).
- When turns allow: a trace of one message through the process with blocking points found and moved.
- When a leak or growth was suspected: measurements of `:message_queue_len`, `:memory`, `:observer` or `:recon` when available, before and after.

## Avoid

- Do not create a GenServer to namespace functions or to cache what the database answers in a millisecond.
- Do not block a callback on an external call or a broadcast to many subscribers.
- Do not tune `max_restarts` upward to silence a crash loop, or lengthen a `call` timeout to hide a slow owner.
- Do not keep state only in a process when a restart must preserve it.
- Do not rename a process module or registered name without checking child specs, `via` tuples, `:global` or `Registry` keys and persisted references.

## Completion

A supervision tree where every process has a reason, an owner, a rebuild path and bounded input, with tests for restart, duplicates and a burst. For the interface's view of the result use [async-state](../async-state/SKILL.md); for a measured slowness use [performance](../performance/SKILL.md); for a persisted job rather than a process use the Oban notes in the [Elixir context](../../elixir/oban.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
