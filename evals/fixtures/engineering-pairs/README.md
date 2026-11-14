# Offline engineering behavior checks

These synthetic modules are small models of historical application contracts.
They are evaluator artifacts, not application code or shipped agent guidance.
Use Python 3 and Elixir on PATH:

```sh
python3 evals/fixtures/engineering-pairs/replay.py
```

The replay runs each recorded output in a separate Elixir process. For each
primary case, `cases.json` contains the participant brief, independently held
assertions, design criteria, modules actually returned and SHA-256 hashes of
the full original answers, including the omitted prose. The executable checks
do not score readability, dependency direction or deployment recommendations.
The accompanying report records that separate inspection.

For the discovery case, copy only `operation.exs` as `job.exs` and
`boundary.txt` as `recording.md` into each participant directory.
`request.txt` is the participant brief. Keep `holdout.exs`, `cases.json`,
`discoveries.json` and the grader outside those directories. A is the control;
B additionally receives the canonical shared contract and data-pipelines
workflow. The follow-up used the same files, brief and oracle after a focused workflow change. A recorded answer can fail an oracle: a successful replay means
the original verdict was reproduced, not that every answer passed.
