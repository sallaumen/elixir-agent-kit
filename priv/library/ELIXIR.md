# Elixir context

Read only the references whose technology the consuming project actually uses;
`mix.lock` and `mix.exs` are the evidence, not the project's name. A plain Elixir
library inherits none of the Phoenix, Ecto or Oban references. Each one lists what
to inspect, what to do and how to verify, so a workflow can point at it instead of
repeating mechanics. The project's own contracts and exemplar modules win over
every reference here.

| Reference | Read when | It covers |
|---|---|---|
| [Module and function shape](elixir/code-shape.md) | Elixir code is written or refactored | pure decisions beside effects, assertive code, data modeling, errors, naming, docs and the type checker, macros; named after the Elixir anti-pattern guides; the refactoring workflows that apply this reference are [functional-refactoring](skills/functional-refactoring/SKILL.md) and [readable-code](skills/readable-code/SKILL.md) |
| [Pipelines and control flow](elixir/pipelines.md) | data passes through steps: pipe chains, `with`, transactions, streams, fan-out, queue consumers | pipe idioms, normalized `with` errors, token pipelines, `Repo.transact/2` and `Ecto.Multi`, query composition, Enum versus Stream, `Task.async_stream`, GenStage, Flow, Broadway |
| [Dependency architecture](elixir/architecture.md) | modules, contexts or applications depend on each other | direction, cross-context rules, scopes, behaviours as contracts, configuration in libraries, `boundary`, umbrellas, compile-time coupling and `mix xref` gates |
| [OTP processes and supervision](elixir/otp.md) | the project starts its own processes | process or function, restarts, call timeouts, mailbox dedupe, periodic ticks, short-TTL ETS caches, renames |
| [Phoenix and LiveView](elixir/phoenix-liveview.md) | `phoenix` or `phoenix_live_view` is locked | scopes, data loading in `handle_params/3`, keyed async jobs, push over poll, form recovery, unexpected events |
| [Ecto and migrations](elixir/ecto.md) | `ecto_sql` is locked | changesets and constraints, claim before effect, idempotent creation, upserts, expand and contract migrations |
| [Oban](elixir/oban.md) | `oban` is locked | provider capacity, `unique` versus idempotent effects, renamed workers, snooze on rate limits, per-item isolation |
| [ExUnit and diagnostics](elixir/exunit.md) | the project has a test suite | reproduction flags, fakes, configuration knobs, `async` choices, fixtures for external state, `$callers` |
| [HTTP clients and provider APIs](elixir/http-clients.md) | `req`, `finch` or another HTTP client is locked | clients as values, status checks, failure style per caller, retry policies, timeouts, pools, `Req.Test` |
| [Security](elixir/security.md) | the project serves HTTP, takes input or reads secrets | CSRF, tokens, atoms, uploads, params into Ecto, LiveView events, secrets, logs |
| [Telemetry and observability](elixir/telemetry.md) | `telemetry` is locked | Phoenix, LiveView, Ecto, Oban and Finch events, metrics, custom spans |
| [Build, dependencies and releases](elixir/build-releases.md) | any Mix project | reproducing builds, warnings as errors, `precommit` versus `gate`, Credo, runtime configuration |
| [Writing a library](elixir/library-authoring.md) | the project is a package other projects depend on | namespace, options instead of app env, errors, version requirements, locked and unlocked CI, docs and deprecations |
| [Working in an Elixir checkout](elixir/agent-loop.md) | every agent session in a Mix project | docs of the locked version, dependency usage rules, the feedback ladder, finding callers, runtime questions, commands to avoid |
| [Recommended libraries](elixir/libraries.md) | a dependency is added, replaced or questioned | what to use, when, and what to leave out |
