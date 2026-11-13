# Paired reviews: stock and version

Evaluation only. Keep this folder, the scoring criteria, arm names and other
answers outside each executor's checkout. Each session sees only its BRIEF, a
Git repository with two tags, and the assigned copy of the kit's guide.
The stock fixture introduces retry handling and extracts a date filter; the
control uses only the historical version hunk. Neither is an application to ship.

From the kit root (Python 3.12+), prepare a new checkout per run:

```sh
python3 scripts/prepare_review_pair.py stock old /tmp/review-01
```

Choose `stock` or `version` and `old` (7be0224) or `pilot` (d9c9811).
The destination must not exist. Assign neutral paths, shuffle arm order, keep
the key separately, and use a fresh session with the same model, effort and
client settings for every run. No script invokes a client. Use this prompt:

> Read BRIEF, guide/skills/code-review/SKILL.md and guide/CONTRACT.md. Perform
> the requested review in English, read-only, using only this checkout and
> ordinary Git/Elixir tools. The Git tags base and candidate delimit the
> snapshots. Do not use external analyzers, network, other agents or other
> checkouts. Do not edit tracked files. Report actual findings, checks and limits.

**Grade the final answers before revealing the arms.** A stock finding earns
`receipt_scope` if it explains that two depots can legitimately issue the same
receipt number and one delivery is lost. It earns `last_date` if it identifies
that an otherwise eligible receipt on the inclusive upper bound is dropped.
A generic warning about deduplication or dates earns no credit. Credit additional
reachable regressions after independent verification; list unsupported findings
separately. For the version control, check the answer, its evidence and whether
the commands show needless risk ranking; no findings is not 100% precision.
If any session fails, retain that fact and repeat the pair separately.

To verify the fixture independently of the reviewer, prepare a **separate**
stock checkout. At each tag run `mix test`, then run
`elixir -r lib/stock.ex /absolute/path/to/oracle.exs` there, using the evaluator's
[oracle](oracle.exs). The supplied suite passes at both tags; the two oracle
assertions pass at base and both fail at candidate. Do not copy them into
a review checkout. Summarize the adjudicated JSON offline with
`python3 scripts/score_review_pair.py path/to/runs.json`.
