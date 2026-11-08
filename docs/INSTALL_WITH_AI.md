# Install or migrate with an AI agent

Copy the prompt below into an agent with filesystem and terminal access to the
consuming Elixir project. Review the resulting diff and evidence under your
project's existing delivery policy. The prompt grants no new paid calls or deploys.

```text
Install or migrate Elixir Agent Kit v1.0.0 in this Elixir project using its
reference-only layout. Read the project's instructions and the versioned guide:
https://github.com/sallaumen/elixir-agent-kit/blob/v1.0.0/README.md
and compatibility:
https://github.com/sallaumen/elixir-agent-kit/blob/v1.0.0/docs/compatibility.md

1. Inspect the working tree, Mix project, existing instruction files, dependency
   aliases and any previous .elixir-agent-kit/state.tsv. Preserve unrelated work;
   use an isolated branch/worktree under this project's rules.
2. In the existing deps/0 add or update exactly one dependency:
   {:elixir_agent_kit,
    git: "https://github.com/sallaumen/elixir-agent-kit.git",
    tag: "v1.0.0", only: [:dev, :test], runtime: false}
   It is public: no token in source. Do not claim it is published to Hex.
3. In project/0 set elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all],
   unless this project already has a deliberately narrower selection.
4. Fetch dependencies (deps.get for new install; deps.update elixir_agent_kit for
   upgrade). Inspect local aliases before executing commands. No application,
   database or model needs to start for this setup.
5. Run mix agent_kit.sync --dry-run, inspect the changes, then mix agent_kit.sync.
   For a 0.1 installation this removes its unmodified recorded library copies and
   per-skill wrappers. Do not delete by glob or erase the ownership manifest.
   If edited managed content blocks migration, preserve the edits as project rules
   or upstream proposals and restore only their recorded originals before retrying.
6. Verify the only kit-managed content remaining is the generated START.md,
   state.tsv, .elixir-agent-kit/plans/.gitignore (commit it), bounded blocks in AGENTS.md/CLAUDE.md and, for :claude and :codex,
   one generated pointer skill each (.claude/skills/elixir-agent-kit/SKILL.md,
   .agents/skills/elixir-agent-kit/SKILL.md). Preserve other tools' skills and
   all local instructions. Do not copy workflow bodies or register per-workflow
   files. Library text must be read directly from the Mix dependency.
7. Run mix agent_kit.check: it verifies both drift and the presence of the
   library files the links point at in the downloaded dependency. Verify a second
   sync makes no changes. Add check to the appropriate existing local/CI gate
   after fetching dependencies; never auto-sync in CI.
8. In a fresh agent session, read the project's instructions, the generated
   START.md, the dependency's ROUTING.md and one task-appropriate SKILL.md. Name
   its inputs, decision and validation criteria in the agent's work. A file-link
   check alone does not establish that the client loaded or followed the skill.
9. Update this project's setup instructions: a fresh checkout needs mix deps.get;
   clients must read ignored dependency files directly. For DeepSeek, confirm the
   harness loads AGENTS.md or the index in its actual executor worktree. A model
   name does not establish compatibility. Do not claim live compliance from file checks.
10. Explain maintenance: reusable lessons are proposed upstream through the kit's
   EVOLUTION.md; product-specific rules remain local. Use mix agent_kit.outdated
   explicitly to discover stable releases; no background or unpinned update.
11. Run project-required checks, inspect the diff and stage files by name. Commit
    dependency, lock, index/state, plans/.gitignore, references and removal of obsolete owned files
    together. Follow existing PR/merge authority. Report exact files/counts,
    validation, selected version, any blocked steps and unverified live clients.
```
