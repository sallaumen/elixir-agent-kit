# Two-defect review and repeated small control

**Keep the pilot local to code-review.** Neither the first round nor this one
shows an additional verified finding from prioritization. The latest small
controls show no structural investigation, but output tokens increased in
both pairs. A claim that small reviews are cheaper would be premature.

| Case and repetition | Old → pilot: known defects found | Old → pilot: shell calls | Old → pilot: output tokens |
|---|---|---|---|
| Stock 1 | 2 → 2 | 9 → 17 | 1,763 → 1,818 |
| Stock 2 | 2 → 2 | 8 → 8 | 1,990 → 2,096 |
| Version 1 | 0 → 0 (clean control) | 7 → 8 | 1,471 → 1,629 |
| Version 2 | 0 → 0 (clean control) | 13 → 8 | 1,531 → 1,604 |

**What the outputs establish.** Every stock review gave a concrete collision
between receipt numbers belonging to different depots and a receipt omitted
on the final date. Each identified why the visible tests passed. Every control
reported 1.0.0 and qualified its evidence: direct Mix project configuration
worked, while a regular Mix command was blocked by the local PubSub socket.
There were no unsupported defect findings. Calling both stock defects “high”
or “P1” is a separate judgment: wrong totals and missing dates were shown,
but the fixture supplies no production frequency or business impact.
Do not count severity labels as evidence of a better review.

**What this round cannot distinguish.** The untouched skill was already at
the ceiling on this compact fixture. Its two contracts are explicit; neither
arm had to reconstruct a contract across modules. The optional step may not
have been necessary. More calls or tokens do not prove a reviewer used the
step, and a correct final cannot prove the order of private reasoning. One
shell call can batch multiple commands. These are client-reported output
tokens, including reasoning, not total cost. With two pairs, one model and
one new synthetic diff there is no speed, billing or population-level claim.
The control was the same historical mix.exs hunk as before, isolated this
time as a one-file checkout. Compare arms within this round.

**Method.** Eight fresh ephemeral Codex CLI 0.162.1 sessions, gpt-6-sol with
medium reasoning, three at most concurrently, randomized run order, separate
client homes, companion configuration off. Kit arms: 7be0224 and d9c9811.
No external analyzer calls. Each checkout held only the input snapshots,
brief and one revision of the guide; tracked files remained unchanged.
The coordinator defined and exercised the independent assertions before
reading answers, graded the anonymous finals against them, then joined the
arm key. No independent second grader. Ordinary tests passed in both
snapshots (one at base, two at candidate); the evaluator's two assertions
passed at base and failed independently at candidate on Elixir 1.19.5 / OTP 27.
All eight sessions completed; none was retried or discarded.

[Reproduction and scoring rubric](../../fixtures/stock-review/README.md) ·
[Finals, commands, observed usage and grades](runs.json) ·
[Earlier six-session comparison](../2026-11-13-code-review-pilot.md).
Run `python3 scripts/score_review_pair.py evals/results/2026-11-13-review-repeat/runs.json`
to regenerate the detailed table without a model.

**Next decision.** Do not add this step to another skill, or promise a cheaper
control, on this evidence. Prefer a real upcoming diff with competing cross-module
risks and an unchanged caller, with the grading key fixed independently of both
answers. If none is available, stop here rather than tuning the skill against
the known fixtures.
