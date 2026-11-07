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
- Phoenix 1.8 scopes: `phx.gen.auth` assigns `current_scope` (configurable with
  `--assign-key`) in the browser pipeline and in `on_mount`; generated context
  functions take the scope struct as first argument and filter their queries by
  it (a `where` on the scope's key, or `Repo.all_by/3` in Ecto 3.13+). Read the
  scope struct and the context functions to learn the tenant and ownership
  rules; a context function that ignores its scope argument is a finding, not a
  style choice.
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
`assert_patch/2`, `assert_redirect/2`, `assert_push_event/3`), `render_async/2`
to await every pending `assign_async` and `start_async` task (and `stream_async`
in LiveView 1.1) and render the result, with an explicit timeout when the work
exceeds ExUnit's `assert_receive_timeout` (100 ms); assert on the rendered HTML
or the assigns the task set, since there is no dedicated async assertion. Also a
reconnect (stop the view process and mount it again), and a real browser pass at
the project's viewports for anything the test cannot observe.

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

- Reproduce before fixing: `mix test path:line`, `--failed` to rerun only the
  last failures, `--seed N` for order-dependent failures, `--trace` for a hanging
  case, `--slowest N` to list the slowest tests.
- Intermittent failures: `mix test --repeat-until-failure N` (Elixir 1.17+)
  reruns the suite in one VM until the first failure; combine with
  `--max-failures 1`. Leftover global state between runs produces unrelated
  failures, which is itself a finding.
- Trace values with `dbg/1`, `IO.inspect(value, label: "...")`, `Logger.metadata/1`
  for request or job ids; remove them before committing. Under `iex -S mix test`
  a `dbg/1` call stops in a pry session, and `--breakpoints` (Elixir 1.17+)
  stops at the start of every test (`n` next line, `c` next test) and sets
  `--trace`.
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

## HTTP clients and provider APIs

Inspect: which client the project uses (`Req` over `Finch` and `Mint`, or `Finch`
directly), the retry and timeout options on each paid or non-idempotent call,
how pools are sized per provider host, and how tests replace the transport.

- Req retries by default: `retry: :safe_transient` (the default since Req 0.4)
  retries GET and HEAD on HTTP 408, 429, 500, 502, 503 and 504 and on transport
  errors (`:timeout`, `:econnrefused`, `:closed`), up to `max_retries: 3` with
  exponential backoff or the `Retry-After` header. POST is not retried under the
  default, but `retry: :transient` or a custom retry function retries every
  method, so a paid POST sent that way can run several times. Set `retry: false`
  on a call with a cost or an effect unless the provider honors an idempotency
  key that the retry resends.
- Timeouts: `receive_timeout` (default 15 s) bounds the wait for a response;
  `connect_options: [timeout: ...]` (default 30 s) bounds the connection. In Req
  0.7+ pool options move under `finch: [name: ..., pool_timeout: ...]`; earlier
  versions take `finch: Name` and `pool_timeout:` at the top level.
- A timeout is not evidence that the provider did not do the work: the charge,
  message or job may have completed after the socket closed. Record the attempt
  with an id before the call, reconcile by that id before retrying, and treat
  the retry decision as a product rule, not a client default.
- Pools: `Finch` sizes pools per origin (`pools: %{"https://api.example.com" =>
  [size: 10, count: 2]}`; the default pool is `size: 50, count: 1`). `size` is
  the HTTP/1 connections per pool, `count` the number of pools for the same
  origin. A slow paid provider sharing the default pool starves other calls;
  give it its own pool and read `[:finch, :queue, :stop]` for wait time.
- Tests: `Req.Test.stub(name, plug)` and `Req.Test.expect(name, count, plug)`
  with `plug: {Req.Test, name}` on the request answer from a `Plug` function or
  module, so the response body, status and headers are explicit;
  `Req.Test.json/2` builds a JSON response and `Req.Test.transport_error/2`
  simulates `:timeout` or `:econnrefused`. Stubs are owned per test process and
  work with `async: true`. Keep one real contract check where authorized.

Verify: a test for the timeout path and for the retried path asserting the
effect count; the pool configuration named in the handoff when a provider was
added.

## Security

Inspect: the browser pipeline (`protect_from_forgery`,
`put_secure_browser_headers`), every place a token is verified, every call
that turns input into an atom, upload handling, how params reach `Ecto`, and
where secrets are read.

- CSRF: `protect_from_forgery` installs `Plug.CSRFProtection`; it raises on an
  invalid token by default (`with: :clear_session` only drops the session).
  LiveView checks the `_csrf_token` connect param once when the socket joins;
  a JSON API pipeline without cookies does not need it.
- `Phoenix.Token`: `verify/4` enforces the `max_age` (seconds) recorded by
  `sign/4`, 86400 by default; pass `max_age:` on verify for each purpose so a
  reset link or download token lives minutes, not a day.
- Atoms: use `String.to_existing_atom/1` for input that selects a known value,
  never `String.to_atom/1`; atoms are not garbage collected.
- Uploads: `Plug.Upload` writes to a temporary path that is removed when the
  owning process exits; `content_type` and `filename` are client-controlled
  and must be validated by inspecting the content before they are trusted. Move
  or copy the file within the request, or `give_away/3` it to another process.
- Database input: build changes through `Ecto.Changeset.cast/3` with an explicit
  field list, or an explicit allowlist of fields and operators for filters and
  sorts; never interpolate params into a query or map a param to a column name
  without a lookup. Scope every read by the current tenant or scope.
- LiveView: `handle_event/3` params are untrusted exactly like controller params,
  including ids of records the user may not own; load through the scoped context
  function, not `Repo.get/2`. Authorization belongs in `live_session`
  `on_mount` hooks and `handle_params/3`; a hidden control is not a check.
- Secrets: read them in `config/runtime.exs` with `System.fetch_env!/1` so a
  missing value fails boot; never in `config/config.exs`, which is evaluated at
  compile time and bakes the value into the release.
- Logs: Phoenix filters parameters whose key contains a term in
  `config :phoenix, :filter_parameters` (default `["password"]`); add tokens and
  secrets. Logger prints only the metadata keys configured for the formatter
  (`config :logger, :default_formatter, metadata: [...]` in Elixir 1.15+);
  never put a secret or a full request body in metadata.

Verify: a test that sends a request with a tampered or expired token, one with a
record id the user does not own, and `mix sobelow` when the project includes it.

## Telemetry and observability

Inspect: the project's `Telemetry` module (the `metrics/0` list), which events
are attached, and whether a paid call or a job emits anything at all.

- Phoenix emits `[:phoenix, :endpoint, :start | :stop]` (duration of the whole
  request), `[:phoenix, :router_dispatch, :start | :stop | :exception]`,
  `[:phoenix, :error_rendered]`, `[:phoenix, :socket_connected]`,
  `[:phoenix, :channel_joined]` and `[:phoenix, :channel_handled_in]`.
- LiveView emits spans under `[:phoenix, :live_view, :mount | :handle_params |
  :handle_event | :render]` and `[:phoenix, :live_component, :update |
  :handle_event]`, each with `:start`, `:stop` and `:exception` and a
  `duration` measurement.
- Ecto emits `[:my_app, :repo, :query]` (the repo's `telemetry_prefix`) with
  `total_time`, `query_time`, `queue_time`, `decode_time` and `idle_time`; a
  high `queue_time` means the pool is exhausted, a high `query_time` means the
  query or index.
- Oban emits `[:oban, :job, :start | :stop | :exception]` with `duration`,
  `queue_time`, `memory` and `reductions`; `queue_time` is the wait between
  scheduling and execution.
- Req emits no events of its own; its default adapter does:
  `[:finch, :request, :start | :stop | :exception]` for the whole call and
  `[:finch, :queue, :stop]` for the pool checkout wait (`duration`,
  `idle_time`).
- `Telemetry.Metrics` (`summary/2`, `counter/2`, `distribution/2`,
  `last_value/2`) describes what to aggregate; `Phoenix.LiveDashboard` renders
  those metrics in dev through `metrics: {MyAppWeb.Telemetry, :metrics}` in
  the router. Measurements are in native time units; convert with `unit:` or
  `System.convert_time_unit/3`.
- Custom spans: `:telemetry.span([:my_app, :provider, :call], meta, fn -> {result,
  meta} end)` emits `:start`, `:stop` and `:exception` with `duration`; use it
  around every paid call and job step so a cost has a trace.

Verify: in a test, `:telemetry.attach/4` a handler that sends the event to
`self()` (or `:telemetry_test.attach_event_handlers/2`) and `assert_receive`
it with the expected measurements; a span around new provider code before a
performance claim.

## Build, dependencies and releases

Inspect: `mix.lock`, `mix deps.unlock --check-unused`, `_build/<env>` per
`MIX_ENV`, compiler warnings, and the release pipeline when one exists.

- Reproduce a build failure with the lockfile and runtime versions the failing
  environment uses; `elixir --version` and `.tool-versions` are evidence.
- Pin and update through the package manager; `mix hex.outdated` lists candidates,
  `mix deps.update <dep>` changes one boundary at a time.
- `mix compile --warnings-as-errors` and `mix format --check-formatted` are
  deterministic; put them before database-backed tests in any pipeline.
- Elixir 1.17+ type checking emits new warnings on upgrade (type mismatches,
  unreachable clauses), so `--warnings-as-errors` can fail a build that passed on
  1.16: fix the code, do not drop the flag.
- `config/runtime.exs` is evaluated when the release boots, not at compile time;
  read environment there with `System.fetch_env!/1` so a missing variable stops
  boot with its name instead of failing later. `config/config.exs` and
  `config/prod.exs` are compile time and bake values into the release.
- Do not delete another process's `_build` or `deps/` during active work; a clean
  checkout in a temporary directory is the reproducibility check.
- Run database reset, seeds or `mix release` only when the task asks for them.

Verify: the repaired command in a clean checkout, the resolved versions recorded in
the handoff.
