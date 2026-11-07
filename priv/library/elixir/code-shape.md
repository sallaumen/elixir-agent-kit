# Module and function shape

Part of the [Elixir context](../ELIXIR.md). Applies to any Elixir code the project writes or refactors.

Inspect: the project's exemplar module for the kind of code being written (a
client, a context, a job, a LiveView), its `.credo.exs`, and whether public
functions carry `@spec` and the module a `@moduledoc`. The project's written
contracts win over this reference.

- Keep a decision in a pure module named for it (`classify/1`, `plan/2`, a
  metrics calculation) that takes data and returns data; a thin module beside it
  reads, calls and writes. The pure module is tested with `async: true` and no
  database, the thin one with one test per effect. A single function mixing the
  two is the [abstraction-layers](../skills/abstraction-layers/SKILL.md) workflow.
- A public boundary function declares `@spec` with its closed set of results,
  such as `{:ok, value} | {:error, :not_configured | :unreachable | :timeout |
  {:http, status}}`, and callers match each reason they can act on instead of
  folding every error into one message.
- `@moduledoc` states the module's promise and what it never does ("no call
  raises", "every call is recorded"), so a reader learns the contract without
  reading every clause.
- Unknown is a value: when a source was not read, return `{:error, reason}` or
  `:unknown` and show the reason. Zero, an empty list or a guess reads as a fact.
- A comment says why a non-obvious line exists (the failure it prevents), not
  what the next line does.
- Keep each function at one level of meaning and within `mix credo --strict`
  nesting and complexity limits without inline exceptions; split by meaning, not
  by line count.

Verify: `mix credo --strict` and `mix compile --warnings-as-errors` clean, and a
test of the pure module that needs nothing beyond its inputs.
