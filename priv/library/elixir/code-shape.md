# Module and function shape

Part of the [Elixir context](../ELIXIR.md). Applies to any Elixir code the
project writes or refactors. The anti-pattern names below are the ones the
Elixir documentation uses (code, design, process and macro anti-patterns), so a
finding can cite them.

Inspect: the project's exemplar module for the kind of code being written (a
client, a context, a job, a LiveView), its `.credo.exs`, and whether public
functions carry `@spec` and the module a `@moduledoc`. The project's written
contracts win over this reference.

## Decisions and effects

- Keep a decision in a pure module named for it (`classify/1`, `plan/2`, a
  metrics calculation) that takes data and returns data; a thin module beside it
  reads, calls and writes. The pure module is tested with `async: true` and no
  database, the thin one with one test per effect. A single function mixing the
  two is the [abstraction-layers](../skills/abstraction-layers/SKILL.md) workflow.
- `@moduledoc` states the module's promise and what it never does ("no call
  raises", "every call is recorded"), so a reader learns the contract without
  reading every clause.
- Keep each function at one level of meaning and within `mix credo --strict`
  nesting and complexity limits without inline exceptions; split by meaning, not
  by line count. Chains of steps follow [Pipelines and control
  flow](pipelines.md).

## Assertive code

- Match the shape you expect and let anything else crash: `%{status: "ok", body:
  body} = response` or a function head, not a lenient `case` that turns an
  impossible shape into a default ("non-assertive pattern matching").
- Read a required key with `map.key` (raises `KeyError` when missing) and an
  optional one with `map[:key]` ("non-assertive map access").
- Use `and`, `or` and `not` when the operands are booleans; keep `&&`, `||` and
  `!` for truthy values such as `nil` ("non-assertive truthiness").
- In a function head, bind only what the pattern or guard needs and destructure
  the rest in the body ("complex extractions in clauses").
- Assertive is about shapes your code or its contract guarantees. Input from
  outside (params, a provider's body, a file) is validated at the boundary and
  turned into a reason; and when a source was not read at all, unknown is a
  value: return `{:error, reason}` or `:unknown` and show it. Zero, an empty list
  or a guess reads as a fact.

## Data and function signatures

- Give a domain concept its own struct with a `parse/1` or `new/1` that
  validates it, instead of passing raw strings, tuples or loose maps everywhere
  ("primitive obsession").
- Replace overlapping boolean flags with one atom option (`role: :admin`, not
  `admin: true, editor: false`) ("boolean obsession").
- An option must not change a function's return type; offer two functions
  instead ("alternative return types").
- More than a few related parameters become a struct or map, and optional ones a
  keyword list ("long parameter list").
- One function name covers one behavior; clauses that do unrelated things are
  separate, separately documented functions ("unrelated multi-clause function").
- Keep structs under 32 fields; beyond that the VM stores them as larger maps.
  Group optional fields in a nested struct or map ("structs with 32 fields or
  more").

## Errors

- Expected failure is a value: `{:ok, value}` or `{:error, reason}`, matched by
  the caller. A function ending in `!` raises instead, for callers who treat the
  failure as a bug. Raising and rescuing to steer normal flow is the "exceptions
  for control-flow" anti-pattern; rescuing at a process or job boundary to turn
  a library's exception into a reason, a snooze or a recorded error is not.
- A public boundary function declares `@spec` with its closed set of results,
  such as `{:ok, value} | {:error, :not_configured | :unreachable | :timeout |
  {:http, status}}`, and callers match each reason they can act on instead of
  folding every error into one message.
- An exception module's name ends in `Error`; its message is lowercase without a
  trailing period.

## Naming

- `?` ends a function that returns a boolean; `is_` starts only guard-safe
  checks (`is_valid/1` usable in `when`).
- `size` names an O(1) count, `length` an O(n) one.
- `get` returns a value or a default, `fetch` returns `{:ok, value}` or `:error`,
  `fetch!` raises; `compare/2` returns `:lt`, `:eq` or `:gt`.
- Prefer naming a helper for what it does over `do_` plus the public function's
  name (a community style-guide rule; the standard library uses `do_` too), and
  never give a private and a public function the same name.

## Documentation and types

- The first paragraph of `@doc` and `@moduledoc` is one line (it is the summary
  tools show); examples under `## Examples` run as doctests. `@moduledoc false`
  marks an internal module; `@doc false` hides a function but keeps it public.
- A comment says why a non-obvious line exists (the failure it prevents), not
  what the next line does ("comments overuse").
- Elixir's type checker ignores `@spec`; Dialyzer reads it. The checker infers
  types from code and warns on its own: 1.18 checks calls and flags
  clauses that can never match, 1.19 adds protocols and anonymous functions, and
  1.20 infers types from guards and whole function bodies and flags redundant
  clauses, dead code and maps missing a required key. Fix the code a warning
  points at; do not add a spec or a catch-all clause to quiet it. Keep `@spec` on
  public functions for documentation and for Dialyzer when the project runs it.

## Macros and module layout

- Prefer a function to a macro; a macro is for what functions cannot do
  (compile-time code generation, new syntax) ("unnecessary macros"). Prefer
  `import` or `alias` to `use` when nothing needs injecting ("`use` instead of
  `import`"); macros' compile-time costs are in [Dependency
  architecture](architecture.md).
- One module per file, path mirroring the module name; inside a module, keep
  `@moduledoc`, `@behaviour`, `use`, `import`, `require`, `alias`, attributes,
  `defstruct`, types and callbacks before the functions, unless the project's
  formatter or Credo config says otherwise.

Verify: `mix credo --strict` and `mix compile --warnings-as-errors` clean, a test
of the pure module that needs nothing beyond its inputs, and for a refactor named
after an anti-pattern, the anti-pattern's name and the before and after in the
handoff.
