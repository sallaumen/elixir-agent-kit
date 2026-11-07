# Working in an Elixir checkout

Part of the [Elixir context](../ELIXIR.md). Applies to every coding-agent session
in a Mix project: where to read before writing, the cheapest feedback for each
question, and the commands that cost a shared machine or someone's data.

Inspect: the project's `AGENTS.md` (including blocks a generator or the
`usage_rules` package wrote), `mix.exs` aliases, `mix.lock`, and whether `deps/`
and `_build/` exist for the environment you are about to use.

## Read the locked version, not memory

- `mix help Module` and `mix help Module.function` print the documentation of
  the version in `mix.lock` (for example `mix help Ecto.Changeset.cast`);
  callbacks such as `Repo.transact/2` are documented on their behaviour (1.20's
  `mix help` prints them; on older versions read them in `deps/`). `mix help
  --search term` finds tasks. This is cheaper and more exact than recalling an
  API, and it needs no network.
- The source of a dependency is in `deps/<package>/lib`; read the function you
  call before guessing an option name. Never edit `deps/`.
- Dependencies may ship rules for agents. Phoenix 1.8 ships
  `deps/phoenix/usage-rules/` (`elixir.md`, `phoenix.md`, `ecto.md`, `html.md`,
  `liveview.md`), and `mix phx.new` copies them into the generated `AGENTS.md`
  unless `--no-agents-md` was passed. Read the files for the technology you are
  touching; they cover HEEx syntax, forms, streams, hooks and test style for the
  locked version. A project-written rule wins over a dependency's.
- The `usage_rules` package (`mix usage_rules.sync`) gathers such files into
  `AGENTS.md` when the project chose to install it; do not add it as part of an
  unrelated task.

## Feedback, cheapest first

1. `mix compile --warnings-as-errors`: syntax, undefined functions and the type
   checker's warnings, in seconds.
2. `mix test path/to/file_test.exs:LINE`, then the file, then `mix test --failed`
   to rerun only what failed last time, or `mix test --stale` for tests whose
   code changed.
3. `mix format` on the files you changed, and `mix credo --strict` on them when
   the project uses Credo.
4. The project's gate alias (`mix precommit`, `mix gate`) on the head commit
   before claiming done; report the commit it ran on.

Use `--only tag`, `--max-failures 1` and `--seed N` to narrow a slow or flaky run
(see [ExUnit and diagnostics](exunit.md)). Read the whole output of the gate, not
a grep of it.

## Find code and its callers

- `grep -rn` for the function name and for dynamic references (strings, config,
  `apply/3`) together with `mix xref graph --sink lib/path.ex --only-nodes`
  (every file that depends on it, directly or indirectly) and `mix xref trace
  lib/path.ex` (why a file depends on others). A language server such as Expert,
  when the client has one, answers "who calls this function" more precisely.

## Questions about the running system

- `mix run --no-start -e 'IO.inspect(MyApp.Parser.parse("..."))'` evaluates pure
  code without starting the application; plain `mix run -e` starts it, with its
  database connections and supervised workers.
- When the project already mounts Tidewave (`plug Tidewave` in the endpoint, dev
  only), its MCP tools (`project_eval`, `get_docs`, `get_logs`,
  `execute_sql_query`, `get_source_location`) answer runtime questions against
  the running dev server. They execute arbitrary code and SQL with the
  developer's privileges; use them for reads, and never add Tidewave as a side
  effect of another task.

## Commands that cost someone else

- Do not open an interactive `iex -S mix` or run `mix phx.server` in the
  foreground: the session blocks. Start a server only through the project's own
  service or preview mechanism, and stop what you started.
- Do not run `mix ecto.reset`, `mix ecto.drop`, seeds or `mix deps.clean --all`
  unless the task asks for it; they destroy local data or force everyone's full
  rebuild. Do not delete another process's `_build` or `deps/`.
- Generators that stamp files (`mix ecto.gen.migration`, `mix phx.gen.*`) produce
  correct timestamps and module names; prefer them to hand-written migration
  filenames.

Verify: the handoff names the docs or source read for each external API used,
the feedback commands run with their results, and the gate's commit.
