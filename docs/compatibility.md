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

Repeat in isolated executor worktrees; a parent session's access proves nothing
about a worker. Filesystem and Mix smoke tests verify links, preservation,
migration, exclusion from production and repeatability. They do not prove live
client discovery or model compliance. Evaluator-only scenarios live in `evals/`
in the source repository, not in the installed index.
