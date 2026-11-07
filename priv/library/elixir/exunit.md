# ExUnit and diagnostics

Part of the [Elixir context](../ELIXIR.md). Applies to every project with a test
suite.

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
- Trace values with `dbg/1`, `IO.inspect(value, label: "...")`,
  `Logger.metadata/1` for request or job ids; remove them before committing.
  Under `iex -S mix test` a `dbg/1` call stops in a pry session, and
  `--breakpoints` (Elixir 1.17+) stops at the start of every test (`n` next
  line, `c` next test) and sets `--trace`.
- Fake external services behind a behaviour with `Mox`; keep one real contract
  check where authorized. A mock expectation is not proof of provider behavior.
- Silence background work by configuration, not by sleeping: the test config
  stretches poll intervals (an hour keeps a supervised poller alive and quiet),
  sets retry delays to 0, turns caches off, switches local services off and sets
  `config :my_app, Oban, testing: :manual`; the test calls the tick function
  itself.
- A test that calls `Application.put_env/3` saves the previous value and
  restores it in `on_exit/1`, deleting the key when it was absent:
  `Application.get_env/3` returns its default only for a missing key, so a key
  restored as `nil` reads as `nil`. Application env is global, so that module is
  `async: false` with a comment naming the global; every other module stays
  `async: true`.
- Point an external store the application reads (another program's database
  file, a directory of logs) at a fixture created in `test_helper.exs` and removed
  with `System.at_exit/1`, so a developer's real state never reaches a test.
- Synchronize with a process instead of sleeping: `Process.monitor/1` and
  `assert_receive {:DOWN, ^ref, :process, _, _}` for its exit, `_ =
  :sys.get_state(pid)` as a barrier after a cast, and no `Process.alive?/1`
  checks.
- Pure functions with invariants (round trips, ordering, idempotence) get
  property tests with `StreamData` (`check all`) when the project has it; a
  doctest is an example, not coverage. ExUnit 1.18 `use ExUnit.Case,
  parameterize: [...]` runs a module once per parameter set.
- Processes a test starts inherit its sandbox connection and its private
  `Req.Test` stubs through `$callers`: a `Task`, a `start_async/3` job and the
  LiveView process that `live/2` starts (LiveView 1.2 passes the test process as
  the caller). A supervised process the test did not start needs
  `Ecto.Adapters.SQL.Sandbox.allow/3` and `Req.Test.allow/3`, or shared mode in an
  `async: false` module.
- A regression test must fail before the fix; if that is impossible to show, say
  so.
- Avoid tautological assertions (the expected value computed the same way as the
  code) and implementation-coupled tests (private functions, side-channel reads).
- Measure before optimizing: `Benchee` with warmup for functions, `:timer.tc/1`
  for a quick read, `:observer`/`:recon` for process and memory shape when they
  are available, `Phoenix.LiveDashboard` for request and query timings in dev.

Verify: the focused test, then the project gate; report skips, fixtures and
anything that limits confidence.
