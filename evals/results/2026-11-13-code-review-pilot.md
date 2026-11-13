# Code review pilot: choosing which scenario to trace first

Maintainer walkthrough, Elixir 1.19.5 / OTP 27. Both inputs are path-limited
diffs from the public kit history. Git and Mix sufficed; no analyzer was used.
These observations establish a known defect and a simple control, not a
before/after measurement of reviewers. Keep this page out of executor prompts.

| Input for a read-only review | What the walkthrough checked | Observed |
|---|---|---|
| `git diff 07132a2 f0676a0 -- lib/elixir_agent_kit/installer.ex test/installer_test.exs` | The new tests cover managed, unmanaged and absent AGENTS.md. The changed multi-agent branch adds an import without looking at existing CLAUDE.md text. Tried that branch with the import already present. | Standalone import lines in the generated file: **1 at base, 2 at head**. The same input at `7be0224` produced **1**. Demonstrates duplicate file content; no claim that a client reads the instructions twice. |
| `git diff 3ceefe8 7125df3 -- mix.exs` | Only the configured package version changes. At the head, ran `mix run --no-start -e 'IO.inspect(Mix.Project.config()[:version])'`. | **"1.0.0"**, as requested. Skipped prioritization; no ranking, caller inventory or history search. Scope is the one hunk, not release readiness. |

To reproduce the first row, use a fresh temporary checkout at each revision.
From its root run this with `mix run -e`, setting `CONSUMER` to a new empty
temporary directory each time:

```elixir
root = System.fetch_env!("CONSUMER")
File.write!(Path.join(root, "CLAUDE.md"), "# Mine\n\n@AGENTS.md\n")
ElixirAgentKit.Installer.run(:install, root, agents: [:codex, :claude])
text = File.read!(Path.join(root, "CLAUDE.md"))
IO.inspect(length(Regex.scan(~r/^@AGENTS\.md$/m, text)))
```

## Decision before extending the pilot

Review the same two diffs in fresh sessions with the old skill (`7be0224`) and
the pilot, on the same client/model and companion settings. Give each executor
only the revisions, paths and request for a read-only review (the small case
asks whether Mix now reports 1.0.0). Make the selected skill available separately
from the historical checkout. Use the [size round procedure](../README.md#running-a-size-round)
for session isolation and transcripts.

Have an independent reader record, for each arm: did it find the known
regression, how many reported findings had a reachable trigger and consequence
out of all findings (n/a for zero), and did the small review start unnecessary
prioritization? Record the test or decision the signal changed and turns or
tokens only if observed. Check that all changed behaviors were reviewed.
If both arms perform equally, this pair shows no gain. Try a previously unseen
diff before adopting the rule elsewhere; narrow or remove the rule if it
adds work to simple reviews or encourages unsupported findings.
