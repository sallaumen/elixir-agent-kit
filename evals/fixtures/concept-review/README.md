# Three counterexamples for workflow reviews

Run from the repository root with Elixir on PATH. These original examples use
fictional data and the standard library. They are evaluator material, excluded
from the package. They replay application behavior, not the model sessions.

| Command | What failure would distinguish the alternatives? |
|---|---|
| `python3 evals/fixtures/concept-review/functional/replay.py` | Compares per-element preference reads with a snapshot. Construction, partial consumption, repeated consumption and moving to another process distinguish the two contracts. Each original passes its own four checks and fails the opposite contract. |
| `elixir evals/fixtures/concept-review/architecture/verify.exs` | With the same public commands and dependency directions, the mixed-unit implementation wrongly labels 5,399 seconds long; the control preserves the 5,400-second cutoff. The verifier checks the exact mismatch list. |
| `elixir evals/fixtures/concept-review/clarity/check.exs` | A tuple operation in the body can raise where the same operation in a guard falls through. Matching ordinary inputs is insufficient: malformed data and overlapping clauses distinguish the contracts. |

For the live comparison, rubric and interpretation see the [concept review](../../results/2026-11-14-concepts.md).
