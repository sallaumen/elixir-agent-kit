# Pipelines and control flow

Part of the [Elixir context](../ELIXIR.md). Applies to any Elixir code that
transforms data step by step, from a `|>` chain to a queue consumer. CI and
validation pipelines are a different subject: the `pipeline-design` workflow.

Inspect: the project's `.credo.exs` (which pipe and `with` checks are enabled),
how existing contexts chain fallible steps, whether multi-step writes use
`Ecto.Multi` or a transaction function, and where large or external collections
enter the system.

## The pipe operator

- Start a chain with the data being transformed, then one call per line with
  parentheses on every call. A single call needs no pipe. A builder that
  naturally starts with a call (`Req.new(...) |> Req.get()`) is fine.
- Do not pipe into `case`, `if`, a block or an anonymous function; bind the
  value and branch on it. `then/2` exists for the rare step whose value is not
  the first argument, and `tap/2` for a side effect (a log, a telemetry event)
  that must return its input unchanged. Credo enables
  `Credo.Check.Readability.PipeIntoAnonymousFunctions` by default; `SinglePipe`,
  `PipeChainStart` and `BlockPipe` are opt-in, so follow the project's config.
- A chain reads as one level of meaning: each step's name says what happens to
  the data. A step that needs a comment to explain why it is there wants its own
  named private function.

## `with` for fallible steps

- Chain steps that return `{:ok, value}` or `{:error, reason}` with `with`, not
  nested `case`. A `<-` that does not match returns the unmatched value as-is;
  an `else` clause that matches nothing raises `WithClauseError`.
- Normalize each step's error in a small private function, so `with` needs no
  `else` or a single clause. A long `else` that pattern-matches every step's
  failure hides which step failed (the "complex `else` clauses in `with`"
  anti-pattern in the Elixir docs).
- Steps that cannot fail use `=` inside the `with` or before it. A one-clause
  `with` that also needs an `else` is a `case`
  (`Credo.Check.Readability.WithSingleClause`); without an `else` it is fine.

## Token pipelines

- When one struct travels through every step and any step can stop the run,
  follow the token's own protocol instead of inventing one: `Plug.Conn` with
  `halt/1`, a Req step that returns `{request, response}` or calls
  `Req.Request.halt/2`, an `Ecto.Changeset` that accumulates validation errors
  without the database, while database constraints are checked only when the
  repo writes it (insert, update or delete).
- Three fixed steps do not need a token struct; `with` is clearer.

## Transactions as pipelines

- `Repo.transact/2` (Ecto 3.13+) runs a function returning `{:ok, value}` or
  `{:error, reason}`, rolls back on the error and raises `ArgumentError` on any
  other return: wrap a `with` in it for a fixed sequence of writes. New code uses
  it; `Repo.transaction/2` is soft-deprecated since 3.13.
- Moving existing code from `transaction/2` to `transact/2` is not a mechanical
  swap: `transaction(fun)` commits and wraps whatever the function returns in
  `{:ok, result}`, so a function returning `{:error, reason}` commits under it and
  rolls back under `transact/2`, and an untagged return raises. Migrate a call
  site only when the task asks, one at a time, with its rollback behavior pinned
  by a test first.
- After a constraint error PostgreSQL aborts the rest of the transaction; insert
  with `on_conflict:` or `mode: :savepoint` when a conflict is an expected
  outcome rather than the end of the work.
- Writes across two contexts that must succeed together go in one
  `Repo.transact/2` owned by the coordinating context, or each context exposes a
  function that returns an `Ecto.Multi` and the coordinator composes them; a
  context never opens a transaction inside another's.
- `Ecto.Multi` names each step, lets `Ecto.Multi.run/3` read earlier results,
  answers a failure with `{:error, step, value, changes_so_far}`, and can be
  inspected without a database with `Ecto.Multi.to_list/1`. Use it when the set
  of operations is built dynamically or each step's name matters to the caller.
- An external effect (an email, a paid call, a message) does not belong inside
  the transaction: commit, then act, or record the intent in the same
  transaction and let a job send it. Tasks started inside a transaction run on
  other connections, outside it; under the SQL sandbox they can deadlock, so keep
  their `max_concurrency` below the pool size.
- `Repo.insert_all/3` skips changesets, `autogenerate` timestamps and generated
  ids; set them yourself, use `on_conflict:` with `conflict_target:` for upserts,
  and chunk rows so one statement stays under PostgreSQL's 65,535 bound
  parameters. With Oban's basic engine `Oban.insert_all/2` ignores `unique`; use
  `Oban.insert/2` when uniqueness matters, and put ids in job args, not payloads,
  since args return as string-keyed JSON.

## Query composition

- Query helpers take a queryable and return one, so a context composes them:
  `Post |> published() |> by_author(id) |> Repo.all()`.
- Name joins with `as:` and reuse them with `with_named_binding/3` so two helpers
  do not join the same table twice; build optional filters with `dynamic/2` from
  an allowlist of fields (see [Security](security.md)).

## Collections: Enum, Stream, comprehensions

- `Enum` is eager and builds each intermediate list; it is the default for
  in-memory data. `Stream` is lazy: use it for large, unbounded or I/O-backed
  sources (a file, a paginated API, `Repo.stream/2`), and `Stream.resource/3`
  when a resource must be opened and closed even on failure. `Repo.stream/2` runs
  inside a transaction bounded by its `:timeout` (15 s by default); a long export
  passes `timeout:` explicitly or reads keyset pages (`where: r.id > ^last_id`,
  `limit:`) in short transactions instead.
- Take a limit before the expensive step (`Stream.take/2` on a stream, not
  `Enum.take/2` after materializing everything).
- `for` comprehensions filter and map in one pass and take `:into`, `:reduce`
  and `:uniq`; `Enum.reduce_while/3` stops early when the function returns
  `{:halt, acc}` instead of `{:cont, acc}`.

## Concurrent fan-out

- `Task.async_stream/3` bounds parallel work. Defaults: `max_concurrency` equals
  `System.schedulers_online/0` (raise it for I/O-bound work), `timeout: 5000` per
  item, `ordered: true`. `on_timeout: :kill_task` yields `{:exit, :timeout}` for
  that item instead of exiting the caller; `ordered: false` saves memory when
  order does not matter; `zip_input_on_exit: true` names the input that failed.
- The tasks are linked to the caller; `Task.Supervisor.async_stream_nolink/6`
  keeps a crashing item from taking the caller down.
- Work that must survive a restart, be retried with backoff or be inspected
  later is an Oban job, not a stream (see [Oban](oban.md)).

## Demand-driven and queue-driven pipelines

- `GenStage` is for demand-driven back-pressure between producers and consumers.
  Stages model runtime concerns (concurrency, buffering), not domain steps; one
  stage per business step is an anti-pattern. `Flow` pays off on large inputs,
  which it processes in batches; partitioning is a separate cost, paid only when
  a step needs related items on the same stage.
- `Broadway` consumes external queues (SQS, RabbitMQ, Kafka and others) with
  batching, concurrency and acknowledgement. It does not retry a failed
  message; the producer decides what happens to it:
  - SQS delivers an unacknowledged message again after its visibility timeout;
    the dead-letter path is the queue's redrive policy (`maxReceiveCount`), set
    on the queue, not in Broadway;
  - RabbitMQ's default `on_failure: :reject_and_requeue` redelivers a message
    that can never succeed forever; prefer `:reject_and_requeue_once`, or
    `:reject` with a dead-letter exchange; `prefetch_count` (50 by default)
    bounds unacknowledged messages per consumer;
  - Kafka commits the offset even for failed messages, so divert failures in
    `handle_failed/2` before they are lost.
- Every handler is idempotent, because delivery is at least once. Work that
  originates in the application's own database is an Oban job, not a Broadway
  pipeline. `Phoenix.PubSub` broadcasts are fire-and-forget: a subscriber that is
  down misses them, so PubSub is a notification, never a stage that must not
  lose an item.

Verify: a test per step's error in a `with` chain asserting the normalized
reason; `Ecto.Multi.to_list/1` or a transaction test asserting rollback on the
failing step; a stream test with a source larger than memory would allow at the
test's scale; for Broadway, `Broadway.test_message/3` (or `test_batch/3`) with
the `Broadway.DummyProducer`, asserting `assert_receive {:ack, ref, successful,
failed}` and the failure path for a poisoned message.
