# Recommended libraries

Part of the [Elixir context](../ELIXIR.md). Applies when a dependency is added, replaced or questioned.

Inspect: `mix.exs` and `mix.lock` before adding anything; a library already in
the lockfile, or one the Phoenix generator includes, beats a new dependency
that does the same job. The project's existing choice wins over this table.

| Need | Use | Leave out | Why |
|---|---|---|---|
| HTTP client | `Req` (Finch underneath), `Req.Test` for stubs | `:httpoison`, `:tesla`, `:httpc` in a project that has Req | The Phoenix 1.8 generator includes Req and its generated agent guidance prefers it; retries, timeouts, JSON and test plugs live in one request value. Set `retry:` per client. |
| Durable background work | `Oban`, with `testing: :manual` in tests | a `GenServer` timer loop for work that must survive a restart, retry or be inspected | Persisted jobs, attempts, `unique`, `snooze`, cron and telemetry come with it; a timer is for a cheap tick whose loss is harmless. |
| Interactive UI | `Phoenix.LiveView` (`start_async`, streams, PubSub) | a browser timer that polls the server | Server push and keyed async results keep one owner per state. |
| LiveView tests | `Phoenix.LiveViewTest` with `{:lazy_html, ">= 0.1.0", only: :test}` | Floki added only for LiveView tests | LiveView 1.2 parses rendered HTML with LazyHTML, an optional dependency the project declares. |
| Persistence | `Ecto` with `ecto_sql` and `postgrex`; `Ecto.Multi` for grouped writes | raw SQL strings built from params | Changesets, constraints, the SQL sandbox and migrations. |
| Reading another program's SQLite file | `exqlite` (`Exqlite.Sqlite3.open(path, mode: :readonly)`, closed in `after`) | an Ecto repo, or a read-write handle on a file the application does not own | A direct read-only handle cannot corrupt the other program's state; use `ecto_sqlite3` only when the application owns the database. |
| HTTP server | `Bandit` (`Bandit.PhoenixAdapter`) | a second server adapter | The Phoenix generator default. |
| JSON | `Jason`, the configured `:json_library` | a second JSON library | One encoder for Phoenix, Req and logs. |
| Metrics | `telemetry_metrics`, `telemetry_poller`, `phoenix_live_dashboard` | ad hoc timing logs | Spans and summaries the dashboard renders in dev; see [Telemetry and observability](telemetry.md). |
| Static checks | `credo` (`--strict` in the gate), `sobelow` (`--exit` on Phoenix apps) | disabling checks inline to pass | Deterministic gates an agent can run before a commit. |
| Assets | the `esbuild` and `tailwind` Mix wrappers; `heroicons` as a sparse Git dependency with `app: false, compile: false` | a Node toolchain only to build CSS and JS | Standalone binaries keep the build reproducible from `mix`. |
| Behaviour fakes | `Mox` for a port with expectations; a fixture implementation for development | a mock of a module the project does not own | A fake implements the project's own behaviour; a fixture engine lets development run without a key. |

Verify: `mix deps.unlock --check-unused` after a change, the new dependency's
license and version recorded in the handoff, and the reason it is not already
covered by a locked library.
