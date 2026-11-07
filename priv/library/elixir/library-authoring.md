# Writing a library

Part of the [Elixir context](../ELIXIR.md). Applies when the project is a Hex or
Git package that other Mix projects depend on, or an internal package shared by
several applications. An application inherits only the parts about options and
errors.

Inspect: `mix.exs` (`package`, `docs`, dependency requirements, `:only` and
`:optional`), the top-level module namespace, every `Application.get_env/3`, the
public modules and their `@moduledoc`, and the CI matrix.

- Define modules only under the package's own namespace: a package named
  `:my_lib` defines `MyLib` and `MyLib.*`, never `Plug.MyThing` or a top-level
  name another package might use ("namespace trespassing" in the Elixir
  anti-pattern guides). The guide's exceptions: protocol implementations for
  another package's protocol, `Mix.Tasks.*` modules for the package's tasks, and
  modules the namespace's owner explicitly invites.
- Take configuration as function or child-spec options, validated at the
  boundary (the `NimbleOptions` package gives schemas, defaults and generated
  docs), not from application env; the host application may run two
  differently configured instances. Code generation through `use` with
  `otp_app:` is the accepted exception.
- Return `{:ok, value}` or `{:error, reason}` where failure is expected and offer
  a `!` variant that raises for callers who prefer it; the reason is an
  exception struct (`defexception`, name ending in `Error`, message lowercase
  without a trailing period) or a documented atom, so callers can match it.
- Version requirements: `"~> 1.2"` for a dependency at 1.2 or later in major 1.
  To require a fix released in 1.2.1, write `"~> 1.2 and >= 1.2.1"`; `"~> 1.2.1"`
  would stop users at 1.2.x. A dependency still below 1.0 gives no compatibility
  promise between minors, so depend on its patch version (`"~> 0.4.2"`).
  Development-only dependencies take `only: [:dev,
  :test]`; optional ones take `optional: true` and the library compiles without
  them.
- Host projects ignore the library's `mix.lock`. CI runs the suite twice: once
  against the lockfile, once after `mix deps.unlock --all` against the newest
  allowed versions (nightly is enough), plus `mix compile --no-optional-deps
  --warnings-as-errors` when optional dependencies exist, across the oldest and
  newest supported Elixir and OTP versions.
- Every public module has a `@moduledoc` whose first paragraph is one line;
  internal modules use `@moduledoc false`. Public functions have `@doc` (written
  before the first clause), `@spec`, and examples under `## Examples` that run as
  doctests. `@doc since: "1.3.0"` dates an addition; `@deprecated "Use
  new_fun/1"` makes callers' compilation warn, while `@doc deprecated:` only
  marks the docs. `@doc false` hides a function from docs but keeps it public.
- Keep the public surface small and stable: a function made public is a
  promise; breaking it is a major version. Record breaking changes and
  migrations in the changelog.
- Prefer functions to macros; a macro that only saves typing costs every user
  compile-time coupling (see [Dependency architecture](architecture.md)).

Verify: `mix docs` (when `ex_doc` is a dev dependency) renders without warnings,
doctests run in the suite, both CI variants (locked and unlocked) pass, `mix
compile --no-optional-deps --warnings-as-errors` is clean, and `mix hex.build`
lists only the intended files.
