# Install with an AI coding agent

Copy the prompt below into a coding agent with access to the target Elixir
repository. The setup uses the public GitHub release and requires no download
token or model API key. The agent's own account/access is separate.

---

Install Elixir Agent Kit v0.1.0 in this Elixir project and verify the setup.

Read the installation guide at
https://github.com/sallaumen/elixir-agent-kit/blob/v0.1.0/README.md
and the client compatibility notes at
https://github.com/sallaumen/elixir-agent-kit/blob/v0.1.0/docs/compatibility.md.
Use the actual documentation for this release. If it cannot be retrieved, report
that limitation and do not invent commands or a successful installation.

1. Read this project's instructions, `mix.exs`, contribution rules and validation
   commands. Inspect the working tree and preserve unrelated work. Determine the
   Elixir/OTP versions and the coding-agent tools actually used here. Ask only for
   client selection or another material choice that cannot be established locally.

2. Add the dependency without replacing the existing dependencies:

   ```elixir
   {:elixir_agent_kit,
    git: "https://github.com/sallaumen/elixir-agent-kit.git",
    tag: "v0.1.0",
    only: [:dev, :test],
    runtime: false}
   ```

3. Add an `:elixir_agent_kit` key to the existing `project/0` configuration.
   Use `agents: [:codex, :claude, :generic]` only if all are desired; otherwise
   select the relevant adapters. Use `skills: :all` initially unless the project
   needs a narrower set. `:generic` means a file-reading harness, not a guarantee
   of automatic DeepSeek integration.

4. Fetch dependencies with `mix deps.get`. Never embed credentials in source,
   URLs or chat. Do not run database resets, seeds, application startup or unrelated
   upgrades as part of this installation.

5. Run `mix agent_kit.install --dry-run`, inspect collisions, and run
   `mix agent_kit.install`. Preserve existing `AGENTS.md` and `CLAUDE.md` content.
   If managed-content conflicts occur, preserve edits and follow the documented
   recovery procedure. Do not delete state or force an overwrite.

6. Run `mix agent_kit.check`, then run install again and verify that it reports
   no changes. Run the appropriate project checks. Add a read-only kit check to
   the existing CI when within this task's scope; do not replace existing gates.

7. Inspect the generated entry points and resolve their links to the shared
   contract and selected workflows. Commit-ready output should include `mix.exs`,
   `mix.lock`, the local library snapshot, its state record, and selected agent
   entry points. Stage only the files belonging to this change.

8. For isolated workers, ensure the guidance is in their checkout and identify
   how their harness loads it. Test a fresh session if available. If a client is
   unavailable, report “files installed; live discovery not verified” rather than
   declaring its integration complete. Do not launch paid model calls without
   corresponding authorization.

9. Document update and removal commands in the project's normal setup guide.
   Report the installed version, selected adapters, changed files, checks and
   any remaining limitations. Separate structural verification from observed
   model behavior.

Complete the authorized local setup. Publishing, merging and deployment follow
this project's rules and the user's existing authorization.

---

## Expected outcome

A second install makes no changes, `mix agent_kit.check` passes, project-owned
instructions remain intact, and the report states which clients were actually
verified. Review the diff before committing. See the release's README for updates
and safe removal.
