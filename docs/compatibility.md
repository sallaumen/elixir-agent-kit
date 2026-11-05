# Client compatibility and evaluation

Elixir Agent Kit distributes instructions. The host tool determines discovery,
permissions, context loading and execution. GPT, Claude and DeepSeek are model
families; model selection alone does not prove client integration.

| Adapter | Project files | Basis | Verification boundary |
|---|---|---|---|
| `codex` | `AGENTS.md`, `.agents/skills/eak-*/SKILL.md` | [Codex repository skills](https://learn.chatgpt.com/docs/build-skills) | Generated format, paths and links tested; live session behavior not certified. |
| `claude` | `CLAUDE.md`, `.claude/skills/eak-*/SKILL.md` | [Claude Code project skills](https://code.claude.com/docs/en/skills) | Generated format, paths and links tested; live session behavior not certified. |
| `generic` | `AGENTS.md` | Explicit file-reading integration | Harness must load the entry point; no automatic model-specific hook. |

The local snapshot is `.elixir-agent-kit/`. Native entry points link to that
snapshot, so a client must be allowed to read project files outside its skill
folder. Clients that require fully sandboxed skill bundles need a separate
adapter; do not claim compatibility merely because they accept `SKILL.md`.

Client versions and policies can change discovery. Restart or open a new session
and inspect the client's available skills. Hosted chat interfaces do not
necessarily see repository files. This package does not upload content to accounts.

## DeepSeek and isolated workers

Configure the actual harness to read project `AGENTS.md` or explicitly supply
`.elixir-agent-kit/START.md` as the initial project instruction. Each worktree
must contain the committed snapshot or run installation locally. Do not assume
the checkout hosting a dashboard is the checkout used by its worker.

No global harness settings or provider credentials are modified. If the harness
cannot load these files, report the unsupported integration and identify its
supported instruction mechanism before writing a new adapter.

## Reproducible client evaluation

Use a disposable project and a fresh client session. Record the client version,
model, package version, task and observed evidence. Do not include secrets.

1. **Discovery:** ask the client to find the architecture workflow and name the
   contract and workflow files it read. Verify the actual reads if logs are available.
2. **Routing:** request a read-only diff review. Expect `code-review`, not a broad
   architecture rewrite. Confirm the client preserves the requested read-only mode.
3. **Execution:** provide a small reproducible bug in a fixture. Expect evidence,
   a bounded change when authorized, and a relevant regression check.
4. **Restraint:** request a simple text correction. Expect a proportional response,
   not all 33 workflows or unnecessary delegated tasks.
5. **Handoff:** ask for verified results and limitations. Check that commands and
   outcomes match the tool transcript.

Passing `mix agent_kit.check` establishes installation consistency, not those
behavioral criteria. No paid model evaluation is part of the automated test suite.
