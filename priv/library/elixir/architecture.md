# Dependency architecture

Part of the [Elixir context](../ELIXIR.md). Applies to any Mix project with more
than a handful of modules: how modules, contexts and applications may depend on
each other, and how to keep that true. The `architecture-review` workflow decides
ownership; this reference gives the Elixir mechanics.

Inspect: `mix xref graph --format cycles --label compile-connected`, `mix xref
graph --format stats`, the project's contexts and their public functions, every
`Application.get_env/3` that selects a module, behaviours with more than one
implementation, and whether the project uses the `boundary` library or an
umbrella.

## Direction

- Dependencies point one way: the web layer calls contexts, contexts call their
  own schemas and the repo, and nothing below calls back up. A controller, a
  LiveView or a component never calls `Repo` or an HTTP client directly.
- One context reaches another only through that context's public functions.
  A schema may still declare `belongs_to` or join on another context's schema
  when the data truly depends on it (the Phoenix contexts guide allows it); what
  stays private is the other context's write rules and queries. A reporting read
  model that joins many contexts is a deliberate exception, named as one.
- In Phoenix 1.8 apps with scopes, every context function over tenant data takes
  the scope first and filters by it, and PubSub topics are subscribed through a
  scoped context function, never built from a raw id in the view. Jobs and
  global reference data have no scope; do not invent one.
- One module owns every call to a given process (`GenServer.call/3`, `cast/2`,
  `send/2`); callers use its functions, never the process name ("scattered
  process interfaces" in the Elixir anti-pattern guides).

## Contracts and substitution

- Pick the seam by what varies. For an HTTP API reached with Req, the client
  value is the seam: build it once, pass it in, and replace only its transport
  with `Req.Test` (see [HTTP clients and provider APIs](http-clients.md)); no
  behaviour is needed. A service with several real implementations (two model
  providers, a fake engine for development) or reached through a non-HTTP
  library sits behind a behaviour the project owns, whose callbacks are the
  contract; tests use a scripted implementation or Mox. Mock only behaviours you
  own; wrapping a library you do not own in a thin behaviour first is the cost
  of a mockable seam.
- Choose how the implementation is selected by how many call sites need it:
  - a function or module argument with a default
    (`def sync(client \\ Client.build())`) when few call sites need it; tests pass
    a fake and nothing global changes;
  - a single module that reads `Application.get_env/3` at runtime when many
    layers would otherwise have to pass the argument through; tests then change
    a global and run `async: false`, or use Mox expectations, which are per
    process, reach `Task`s through `$callers` and need `Mox.allow/3` for any
    other process. `Mox.stub_with/2` backs a mock with a real implementation, and
    `setup :verify_on_exit!` fails a test whose expectations were not met.
- A library takes its options as keyword arguments or child-spec options, not
  from application env ("using application configuration for libraries"). The
  Elixir guide's exceptions are compile-time code generation (`use Ecto.Repo,
  otp_app: ...`) and swapping implementations that behave identically.

## Enforcing boundaries

- `mix xref graph --format cycles --label compile-connected --fail-above 0`
  fails when a compile-time cycle exists; add it to the gate once the project
  has none. `mix xref trace lib/path.ex` shows, line by line, why a file depends
  on others and whether at compile time, runtime or export.
- The `boundary` library (`compilers: [:boundary] ++ Mix.compilers()`, then
  `use Boundary, deps: [...], exports: [...]` in each top-level module) turns
  forbidden calls between declared boundaries into compiler warnings. Adopt it
  with its allowance for existing violations (`dirty_xrefs`) and tighten later.
  Its README says it is not tested with umbrellas; since it reads compiler
  references, expect it to miss calls made through `apply/3` or a module taken
  from configuration.
- An umbrella shares configuration, the lockfile and the build across its apps;
  it groups code, it does not decouple it. Apps that need different
  dependencies, versions or configuration belong in separate Mix projects
  (path dependencies in one repository, or separate repositories). One team
  shipping one release usually needs a single app with enforced boundaries.

## Compile-time coupling

- A compile-time dependency recompiles the dependent file whenever the
  dependency changes. They come from macros and `use`, and from module bodies or
  attributes that call another module; struct literals and imports create the
  lighter export dependencies. A file listed in `@external_resource` also
  triggers recompilation, though it is not a module dependency.
- Compile-time dependencies are transitive through runtime ones: if `A` uses
  `B` at compile time and `B` calls `C` at runtime, changing `C` recompiles `A`.
  So a module that others `use` or call from their module bodies must not call
  into the rest of the application; keep it small and dependency-free.
- To cut one: move calls out of module bodies and attributes into functions;
  prefer `alias` and `import` over `use` when nothing needs injecting; inside a
  macro, expand a module argument used only at runtime with
  `Macro.expand_literals/2` and the function's env; never build module names
  with `Module.concat/2`, which hides the dependency from the compiler.
- Runtime-only cycles do not force recompilation; fix compile-connected cycles
  first, then runtime cycles that block a clean ownership map.

## Layers inside a feature

- Build from the inside out and stop at the layer the feature needs: data
  (structs, schemas), pure functions over that data, tests of those functions, a
  boundary module (the context or API that validates input and calls effects),
  then lifecycle and workers (processes, jobs) only for runtime needs such as
  concurrency, state over time or isolation. See [Module and function
  shape](code-shape.md) for the pure decision beside the effect.

Verify: `mix xref graph --format cycles --label compile-connected` before and
after with its exit code under `--fail-above 0`; `mix xref trace` output for one
dependency that was cut; a test that swaps the implementation through the chosen
seam (argument or config) and asserts the contract, not the double's internals;
`mix compile --warnings-as-errors` clean with `boundary` when the project uses it.
