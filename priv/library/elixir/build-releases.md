# Build, dependencies and releases

Part of the [Elixir context](../ELIXIR.md). Applies to every Mix project.

Inspect: `mix.lock`, `mix deps.unlock --check-unused`, `_build/<env>` per
`MIX_ENV`, compiler warnings, and the release pipeline when one exists.

- Reproduce a build failure with the lockfile and runtime versions the failing
  environment uses; `elixir --version` and `.tool-versions` are evidence.
- Pin and update through the package manager; `mix hex.outdated` lists candidates,
  `mix deps.update <dep>` changes one boundary at a time.
- `mix compile --warnings-as-errors` and `mix format --check-formatted` are
  deterministic; put them before database-backed tests in any pipeline.
- Keep two aliases with different effects. `precommit` (Phoenix 1.8 generates
  it) fixes before a commit: `compile --warnings-as-errors`, `deps.unlock
  --unused`, `format`, `test`. `gate` only checks and is what CI and a delivery
  run: `deps.unlock --check-unused`, `compile --warnings-as-errors`, `format
  --check-formatted`, `credo --strict`, `test`. `def cli, do: [preferred_envs:
  [precommit: :test, gate: :test]]` (Elixir 1.15+) runs both in the test
  environment without setting `MIX_ENV`.
- `mix credo --strict` belongs in the gate; exclude generated framework files
  (`core_components.ex`, the `*_web.ex` module, generated test cases) in
  `.credo.exs` instead of restyling them, and add no inline disables to pass it.
- Each Elixir release since 1.17 type-checks more (see [Module and function
  shape](code-shape.md)) and adds deprecations, so `--warnings-as-errors` can fail
  a build that passed before: fix the code, do not drop the flag. Common ones: a
  struct update `%URI{uri | path: p}` now wants `uri` matched as that struct
  first (1.19); `unless` is soft-deprecated (1.18, `mix format --migrate`
  rewrites it); comma-separated `mix do a, b` warns since 1.19, so write `mix do
  a + b`; in 1.20 a size in a bit pattern needs the pin (`<<x::size(^n)>>`),
  `Logger.enable/1` and `disable/1` give way to `Logger.put_process_level/2` and `delete_process_level/1`, and
  `xref: [exclude: ...]` gives way to `elixirc_options: [no_warn_undefined: ...]`.
- Once the project has no compile-time cycle, keep it that way in the gate with
  `mix xref graph --format cycles --label compile-connected --fail-above 0` (see
  [Dependency architecture](architecture.md)); `mix hex.audit` lists
  dependencies that are retired or have security advisories.
- `config/runtime.exs` is evaluated when the release boots, not at compile time;
  read environment there with `System.fetch_env!/1` so a missing variable stops
  boot with its name instead of failing later. `config/config.exs` and
  `config/prod.exs` are compile time and bake values into the release.
  `Application.compile_env/3` belongs only in a module body (it raises inside a
  function), and the application refuses to boot when the runtime value differs
  from the compiled one; read everything else at runtime with
  `Application.get_env/3`, and never read another application's env.
- Do not delete another process's `_build` or `deps/` during active work; a clean
  checkout in a temporary directory is the reproducibility check.
- Run database reset, seeds or `mix release` only when the task asks for them.

Verify: the repaired command in a clean checkout, the resolved versions recorded in
the handoff.
