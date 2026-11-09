# Client compatibility and verification

The kit routes through project instruction files plus one generated pointer skill
per native client; it registers no per-workflow skills or slash commands. The
installer never configures clients globally or invokes models.

| Client | Entry point | Required capability |
|---|---|---|
| Codex | `AGENTS.md` and `.agents/skills/elixir-agent-kit/SKILL.md` | Read project instructions and follow links into the dependency. |
| Claude Code | `CLAUDE.md` (importing `AGENTS.md` when present) and `.claude/skills/elixir-agent-kit/SKILL.md` | Read project instructions and follow links into the dependency. Claude Code ignores `AGENTS.md` once a `CLAUDE.md` exists, so the generated block imports it; it discovers skills only under `.claude/skills`, which is why the pointer exists. |
| Generic harness, including DeepSeek-backed executors | `AGENTS.md` or explicit index loading | Configure the harness to load instructions in its actual working checkout. |

The default library path is `deps/elixir_agent_kit/priv/library/`. Dependencies must
be fetched first. Git ignores this path in most projects, so filename search may
omit it; direct filesystem reading must still be available. If the client cannot
read it, report the limitation and configure permitted file access before claiming
setup complete. Do not silently copy the whole library as a workaround.

## Fresh-session verification

1. Fetch dependencies and run `mix agent_kit.check` in the actual checkout.
2. Start a fresh client session; ask it to read project instructions, follow
   `.elixir-agent-kit/START.md`, and select `code-review` for a read-only diff.
3. Ask it to name the contract and selected workflow files it actually read.
4. Observe that only relevant guidance is loaded, local scope is respected and
   the review does not become an unsolicited edit or publication.
5. For a large request, observe that the session names the size, writes a plan in
   `.elixir-agent-kit/plans/` before its first edit, and stops for approval only on
   a stop-and-ask trigger from the contract.
6. Record package revision, client/harness version, paths and observed behavior.

For a repeatable round across many cases and sizes, follow
[Running a size round](https://github.com/sallaumen/elixir-agent-kit/blob/main/evals/README.md#running-a-size-round)
and record the runs as a result file the matrix script reads.

Repeat in isolated executor worktrees; a parent session's access proves nothing
about a worker. Filesystem and Mix smoke tests verify links, preservation,
migration, exclusion from production and repeatability. They do not prove live
client discovery or model compliance. Evaluator-only scenarios live in `evals/`
in the source repository, not in the installed index.

## Recommended companion: Ponytail

[Ponytail](https://github.com/DietrichGebert/ponytail) is a separate, MIT-licensed
ruleset that keeps an agent to the least new code that fully solves the task:
reuse what the repository, the standard library or an installed dependency
already provides, and never cut validation, error handling, security or
accessibility. It pairs well with the kit and we recommend it. The kit decides
which workflow applies, what to inspect and what evidence to show; Ponytail keeps
the code that workflow produces small. Both follow the contract's rule of the
smallest coherent correction.

The kit does not install, require or configure Ponytail. It is a user-level choice
per client:

| Client | Install | Notes |
|---|---|---|
| Claude Code | `/plugin marketplace add DietrichGebert/ponytail`, then `/plugin install ponytail@ponytail` as a second prompt | Plugin with skills and lifecycle hooks; also injects the ruleset into subagents. |
| Codex | `codex plugin marketplace add DietrichGebert/ponytail`, then `codex plugin add ponytail@ponytail` | Open `/hooks` in `codex`, review and trust its two hooks, then start a new thread. |
| DeepSeek Harness and other generic harnesses | Place Ponytail's `AGENTS.md` in the harness's user-global instructions (`~/.dsh/AGENTS.md` for DeepSeek Harness) and its `skills/` in the user skill root (`~/.dsh/skills/`) | Instruction-only: no hooks, so a level switch lasts one session. Pin a release tag in the checkout you link from. |

The default level is `full`; set `defaultMode` in `~/.config/ponytail/config.json`
or `PONYTAIL_DEFAULT_MODE` to change it. Ponytail's
[install guide](https://github.com/DietrichGebert/ponytail/blob/main/INSTALL.md)
covers other clients and uninstalling.

When the two disagree, the project's instructions, the kit contract and the
selected workflow decide: Ponytail never removes a check, a test or a plan that
the workflow requires. Ponytail changes how agents write and report, so record
its level (`ponytail=full`, `ponytail=off`) with every live evaluation run; see
[Running a size round](https://github.com/sallaumen/elixir-agent-kit/blob/main/evals/README.md#running-a-size-round).
