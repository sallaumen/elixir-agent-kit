# One source for shared practices

The editable shared source is [Elixir Agent Kit](https://github.com/sallaumen/elixir-agent-kit),
in `priv/library/`. An application's dependency is a versioned download, not a
second authoring location. Never edit files in `deps/`, generated indexes, managed
instruction blocks or old copied snapshots to contribute a rule.

Project-specific architecture, domain constraints, commands and permissions belong
in that application's canonical documents. Reference a shared workflow rather than
pasting it. A dependency does not override local instructions or existing authority.

## Improvements travel in both directions through review

1. When application work reveals a reusable lesson, record the observed problem,
   affected workflow, proposed rule and a counterexample. Use the
   [proposal template](templates/practice-proposal.md). Continue the authorized
   application work; do not turn every task into a library rewrite.
2. Decide ownership: local product fact stays local; general practice belongs in
   this kit; a client/tool limitation belongs in compatibility or installer code.
   Remove credentials, customer information and private product details before
   sending a proposal to the public repository. File an issue or PR only when
   publishing is authorized; otherwise leave a local proposal for the maintainer.
3. Change the existing contract or workflow at its owner. Add a new workflow only
   for a distinct trigger. Update relevant evaluator cases and validate the kit.
   Do not execute every workflow merely because you are maintaining the library.
4. Review and release an immutable version. Applications adopt that version in a
   focused PR: update the tag and lock, sync references, inspect removals, run
   project checks and merge under the project's existing authority.
5. Record upstream PR/release and downstream adoption in the delivery evidence.
   A local exception is not silently copied upstream or into other projects.

## Discover and adopt releases

`mix agent_kit.outdated` explicitly queries public stable Git tags. It requires
network access and changes nothing. `--check` makes a newer release fail the
command, suitable for an existing dependency-maintenance routine. Network failure
means unknown freshness. There is no background scheduler or automatic update.

`mix agent_kit.check` is offline and checks this installation against its locked
package/configuration. Passing it does **not** mean the newest version is installed.
Both checks have different purposes; avoid making network freshness a mandatory
build gate unless your project deliberately chooses that policy.

After reviewing a release, change the tag in `mix.exs`, run
`mix deps.update elixir_agent_kit`, `mix agent_kit.sync --dry-run`,
`mix agent_kit.sync`, `mix agent_kit.check` and the project's required checks.
Commit the dependency, lock and generated references together. Keep tags pinned;
following `main` silently would make identical project revisions behave differently.

A fresh checkout must run `mix deps.get` before agents can read the library. The
client must be able to read dependency files even when Git ignores `deps/`; verify
that in a fresh session. This layout registers no per-workflow native skills or
slash commands: it routes through project instructions and one generated pointer
skill per client to the dependency catalog.
