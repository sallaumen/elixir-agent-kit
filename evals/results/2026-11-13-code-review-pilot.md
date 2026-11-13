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

## Live paired round, 2026-11-13

**Hold expansion.** Six fresh Codex CLI 0.162.1 sessions (gpt-6-sol, medium
reasoning) completed one pair per diff. The pilot found no additional defect.
Neither arm added structural investigation to the one-line review. The pilot
used fewer shell calls there, but more on the new diff.

| Case | Confirmed findings: old / pilot | Shell calls: old / pilot | Output tokens: old / pilot |
|---|---|---:|---:|
| Installer | 1 / 1, same selection-change regression. Neither found the duplicate import. | 21 / 13 | 3,631 / 3,366 |
| Mix version | 0 / 0, both correctly confirmed 1.0.0. | 12 / 7 | 1,623 / 1,284 |
| New reminder diff | 1 / 1, same underfilled batch, demonstrated by both. | 10 / 18 | 1,740 / 2,029 |

**Evidence.** Both arms reported two substantiated findings out of two total;
both found one of the two preselected defects. The installer finding was
outside the answer key: install with Codex + Claude, then sync to Claude only.
We replayed it independently with Mix on both historical revisions. At base,
AGENTS.md was removed, no import remained, and check was clean. At head the
same file was removed but CLAUDE.md still imported it, and the next check
reported drift. This is a finding against the historical diff, not a statement
about the current release.

The unseen input was a new synthetic Elixir change adding skip IDs to a
reminder batch. Both sessions explained exactly why the passing test missed
the bug: for eligible IDs 1, 2, 3, skipping 1 before filling two slots should
return 2 and 3; the implementation takes two first and returns only 2. Both
reviewed the implementation and its new test. On the installer both covered
the changed block selection and associated tests; this coverage did not
surface every reachable scenario. Neither control looked for hotspots, caller
inventories or churn; resolving Git refs and verifying the version accounted
for shell work.

**Method and limits.** The old skill was 7be0224; the pilot was d9c9811.
Each run had a separate ephemeral session, temporary client home and checkout
with the same pair of snapshots, no remotes or future commits, the assigned
skill and shared contract under the same paths, and no evaluator notes.
User configuration and companion skills were excluded. The arms ran in mixed
order; the assignment was not in the brief. Transcripts show no external
analyzer calls and all tracked inputs remained unchanged. These are skill
execution tests, not discovery or routing tests. The coordinator scored the
finals against criteria recorded before the runs and checked the extra
finding separately. No independent second human grading was performed.

Each session received the same instructions to read the assigned brief, skill
and contract, work read-only and report actual checks and limits. The two
historical briefs used the paths above; the new brief asked for reachable
defects in lib/reminders.ex and test/reminders_test.exs. The small brief asked
only whether Mix now reports 1.0.0. Full Mix tasks could not open their local
PubSub socket inside the client sandbox; both arms used direct Elixir checks.
The snapshot labels were Git tags rather than branches, causing ref lookup
retries. A shell call is one completed command tool invocation, which may
contain multiple commands. Tokens are the client's reported output, including
reasoning. Neither measure is elapsed time or a bill. With one run per cell,
the differences cannot be attributed to the skill.

[Run records](2026-11-13-review-pair/runs.json) preserve the six final answers,
shell commands, exit codes and reported token usage with checkout paths
normalized. The [new fixture](2026-11-13-review-pair/reminders.json) contains
the base files and the two head replacements. Before extending the pilot,
repeat the simple control and test a new diff with **two independent failure
paths**. Look for additional confirmed findings without losing the second path
or starting unnecessary investigation on the control.
