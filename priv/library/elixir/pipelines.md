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
  `Credo.Check.Refactor.PipeIntoAnonymousFunctions` by default; `SinglePipe`,
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
- Steps that cannot fail use `=` inside the `with` or before it; `with` with a
  single clause is a `case` (Credo's `WithSingleClause`).

## Token pipelines

- When one struct travels through every step and any step can stop the run,
  follow the token's own protocol instead of inventing one: `Plug.Conn` with
  `halt/1`, a Req step that returns `{request, response}` or calls
  `Req.Request.halt/2`, an `Ecto.Changeset` that accumulates validation errors
  without the database and checks constraints only at `Repo.insert/2`.
- Three fixed steps do not need a token struct; `with` is clearer.

## Transactions as pipelines

- `Repo.transact/2` (Ecto 3.13+) runs a function returning `{:ok, value}` or
  `{:error, reason}` and rolls back on the error: wrap a `with` in it for a fixed
  sequence of writes. `Repo.transaction/2` is soft-deprecated since 3.13; keep it
  only where the locked Ecto version predates `transact/2`.
- `Ecto.Multi` names each step, lets `Ecto.Multi.run/3` read earlier results,
  answers a failure with `{:error, step, value, changes_so_far}`, and can be
  inspected without a database with `Ecto.Multi.to_list/1`. Use it when the set
  of operations is built dynamically or each step's name matters to the caller.
- An external effect (an email, a paid call, a message) does not belong inside
  the transaction: commit, then act, or record the intent in the same
  transaction and let a job send it.

## Query composition

- Query helpers take a queryable and return one, so a context composes them:
  `Post |> published() |> by_author(id) |> Repo.all()`.
- Name joins with `as:` and reuse them with `with_named_binding/3` so two helpers
  do not join the same table twice; build optional filters with `dynamic/2` from
  an allowlist of fields (see [Security](security.md)).

## Collections: Enum, Stream, comprehensions

- `Enum` is eager and builds each intermediate list; it is the default for
  in-memory data. `Stream` is lazy: use it for large, unbounded or I/O-backed
  sources (a file, a paginated API, `Repo.stream/2` inside a transaction), and
  `Stream.resource/3` when a resource must be opened and closed even on failure.
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
  stage per business step is an anti-pattern. `Flow` parallelizes large
  collections in batches and is not worth its partitioning cost for small ones.
- `Broadway` consumes external queues (SQS, RabbitMQ, Kafka and others) with
  batching, concurrency and acknowledgement. It does not retry a failed
  message; the producer decides what happens to it:
  - SQS delivers an unacknowledged message again after its visibility timeout;
  - RabbitMQ's default `on_failure: :reject_and_requeue` redelivers a message
    that can never succeed forever; prefer `:reject_and_requeue_once`, or
    `:reject` with a dead-letter exchange;
  - Kafka commits the offset even for failed messages, so divert failures in
    `handle_failed/2` before they are lost.
- Every handler is idempotent, because delivery is at least once. Work that
  originates in the application's own database is an Oban job, not a Broadway
  pipeline.

Verify: a test per step's error in a `with` chain asserting the normalized
reason; `Ecto.Multi.to_list/1` or a transaction test asserting rollback on the
failing step; a stream test with a source larger than memory would allow at the
test's scale; for Broadway, `Broadway.test_message/3` (or `test_batch/3`) with
the `Broadway.DummyProducer`, asserting `assert_receive {:ack, ref, successful,
failed}` and the failure path for a poisoned message.
