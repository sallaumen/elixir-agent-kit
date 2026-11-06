# Elixir context

Apply only the sections whose technology the consuming project actually uses;
`mix.lock` and `mix.exs` are the evidence, not the project's name. A plain Elixir
library inherits none of the Phoenix, Ecto or Oban items. Each section lists what
to inspect, what to do and how to verify, so a workflow can point here instead of
repeating mechanics.

## OTP processes and supervision

Inspect: the supervision tree (`Application.start/2`, child specs), which process
owns each piece of state, every `GenServer.call/3` timeout, and what happens on
restart.

- Use a process for state ownership, lifecycle or concurrency control, not to
  organize functions. Keep pure calculations as functions.
- Pick the restart strategy for the failure you expect; a crash that loses state
  the user depends on needs persistence or a recovery read, not a tighter restart.
- Give long `call`s an explicit timeout and a caller that survives `:timeout`.
  Move blocking work out of callbacks with `Task.Supervisor` or `handle_continue/2`.
- Watch mailbox growth on pollers and broadcasters: dedupe by content hash or
  sequence before broadcasting; `Process.info(pid, :message_queue_len)` measures it.
- Before renaming a module, search behaviours, callbacks, configuration, child
  specs, dynamic dispatch (`apply/3`, `String.to_existing_atom/1`), serialized
  references and persisted jobs. A direct-call search proves nothing.
- Never expose a private function only for tests.

Verify: `start_supervised!/1` in tests, a restart scenario, `:sys.get_state/1` for
inspection, `assert_receive` with a bounded timeout instead of `Process.sleep`.

## Phoenix and LiveView

Inspect: `mount/3` versus `handle_params/3`, whether a subscription runs only when
`connected?(socket)`, how navigation is done (`push_patch` keeps the process,
`push_navigate` remounts, `redirect` leaves LiveView), `live_session` and
`on_mount` hooks, and where asynchronous work starts.

- Authorize and scope by tenant in `on_mount` and `handle_params`, not only in
  templates. Hiding a control is not authorization.
- Run asynchronous work with `assign_async/3`, `start_async/3` and
  `handle_async/3`, keyed by the entity and revision that requested it; drop a
  late result whose key no longer matches the current selection.
- Push state from the server (PubSub subscribe in connected mount, `handle_info`),
  never poll the database from the browser.
- Use streams (`stream/4`, `stream_insert/4`) for large or growing collections;
  assigns re-render whole lists.
- Forms: `to_form/2`, `phx-change` for validation, `phx-submit` for the write,
  `phx-disable-with` on the submit control; optimistic UI is the exception, not
  the default round-trip.
- Focus and announcements after a patch: `phx-mounted` with `JS.focus/1` or
  `JS.focus_first/1`, `aria-live` regions outside `phx-update="ignore"`, flash
  rendered where a screen reader reaches it. Keyboard access survives
  `JS` commands only when the control is a real button or link.
- CSRF protection and `put_secure_browser_headers` are on by default; do not
  weaken the CSP to make a hook work.
- Interface motion belongs to the `motion-design` workflow; reduced motion is a
  state to design, not an afterthought.

Verify: `Phoenix.LiveViewTest` (`live/2`, `render_click/2`, `render_submit/2`,
`assert_patch/2`, `assert_redirect/2`, `assert_push_event/3`), a reconnect
(stop the view process and mount it again), and a real browser pass at the
project's viewports for anything the test cannot observe.

## Ecto and migrations

Inspect: which changeset owns each invariant, which guarantees live in database
constraints, transaction boundaries, preloads on the hot path, and how the schema
coexists with running code during deploy.

- Put domain validation in the context's changeset; use `unique_constraint/3`,
  `foreign_key_constraint/3` and `check_constraint/3` backed by real database
  constraints for races and invariants that must survive concurrent writers.
- Group related local writes in `Ecto.Multi` or `Repo.transaction/2`; a database
  rollback does not undo an external effect, so send effects after commit or make
  them idempotent.
- Decompose composite results at the call site and let the changeset be the second
  opinion; a tuple written into a string column fails every row silently until a
  test feeds the whole path.
- Preload what a loop reads (`Repo.preload/3`, `preload:` in the query); look for
  N+1 in logs before blaming the framework.
- Migrations: add indexes with `concurrently: true` plus
  `@disable_ddl_transaction true` and `@disable_migration_lock true`; set a
  `lock_timeout` for `ALTER TABLE` on busy tables; separate schema change
  (expand), backfill and cleanup (contract) into migrations that an older release
  can run against; never rename a column that a running release still reads.
- Renaming a schema module or field is a migration-compatibility task when the
  name is persisted anywhere (jobs, serialized terms, external payloads).

Verify: `Ecto.Adapters.SQL.Sandbox` with `async: true` where the test touches no
shared global state; one test through the persistence boundary with an invalid
input and one with a concurrent write; `mix ecto.migrate` and `mix ecto.rollback`
on representative data before claiming the migration is reversible.

## Oban

Inspect: queue concurrency, `unique` options, `max_attempts`, which worker names
are persisted in `oban_jobs`, and whether a job calls a paid or rate-limited
provider.

- Queue concurrency limits workers, not the provider; account for provider
  capacity and budget inside the job, before the network call.
- `unique` prevents duplicate enqueueing, not duplicate effects of a retried job;
  make the external effect idempotent or record it before acting.
- Renaming a worker leaves persisted jobs pointing at the old module: keep the
  old module as an alias until the queue drains, or migrate the `worker` column.
- Use `snooze` for backoff that depends on external state and `{:cancel, reason}`
  for permanent failures; do not retry a paid call by default.

Verify: `Oban.Testing` (`assert_enqueued/2`, `perform_job/3`) with `testing: :manual`
in the test config; a retry scenario asserting the effect happened once.

## ExUnit and diagnostics

Inspect: the project's own aliases (`mix test`, `precommit`, `gate`), test
isolation (sandbox, `async: true`), and what the suite can observe at the boundary
under test.

- Reproduce before fixing: `mix test path:line`, `--failed`, `--seed N` for
  order-dependent failures, `--trace` for a hanging case.
- Trace values with `dbg/1`, `IO.inspect(value, label: "...")`, `Logger.metadata/1`
  for request or job ids; remove them before committing.
- Fake external services behind a behaviour with `Mox`; keep one real contract
  check where authorized. A mock expectation is not proof of provider behavior.
- A regression test must fail before the fix; if that is impossible to show, say so.
- Avoid tautological assertions (the expected value computed the same way as the
  code) and implementation-coupled tests (private functions, side-channel reads).
- Measure before optimizing: `Benchee` with warmup for functions, `:timer.tc/1`
  for a quick read, `:observer`/`:recon` for process and memory shape when they are
  available, `Phoenix.LiveDashboard` for request and query timings in dev.

Verify: the focused test, then the project gate; report skips, fixtures and
anything that limits confidence.

## Build, dependencies and releases

Inspect: `mix.lock`, `mix deps.unlock --check-unused`, `_build/<env>` per
`MIX_ENV`, compiler warnings, and the release pipeline when one exists.

- Reproduce a build failure with the lockfile and runtime versions the failing
  environment uses; `elixir --version` and `.tool-versions` are evidence.
- Pin and update through the package manager; `mix hex.outdated` lists candidates,
  `mix deps.update <dep>` changes one boundary at a time.
- `mix compile --warnings-as-errors` and `mix format --check-formatted` are
  deterministic; put them before database-backed tests in any pipeline.
- Do not delete another process's `_build` or `deps/` during active work; a clean
  checkout in a temporary directory is the reproducibility check.
- Run database reset, seeds or `mix release` only when the task asks for them.

Verify: the repaired command in a clean checkout, the resolved versions recorded in
the handoff.
