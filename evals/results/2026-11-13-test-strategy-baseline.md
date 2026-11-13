# Test strategy: a green threshold test can still miss the wrong output

**Baseline, not a workflow change.** One fresh Codex CLI 0.162.1 session
(GPT-6.1-Sol, medium) used the test-strategy guide shipped in v1.1.0.
The case was a disposable Mix wrapper around a private application's real
pure function and its entire five-test module. The brief asked whether the
current suite protected the documented output before a refactor. It supplied
neither the mutation nor an expected literal.

The contract chooses the first candidate that meets a threshold, with the
last candidate as fallback. The existing examples asserted that results reach
the threshold and covered the fallback. The reviewer tried searching from the
opposite end. All five examples still passed. It independently worked out an
input with an interior crossing and added one exact-output assertion at the
public function. That test failed on the mutation; restoring the original
source produced six passes. The reviewer ran ExUnit directly because Mix
could not open its local PubSub socket in that session.

Separately, the evaluator substituted the last candidate unconditionally.
The original five tests passed; the new sixth test failed alone on that same
mutation, and all six passed after restoration using normal Mix. These are
focused observations in an isolated subset, not an application suite run or
evidence of a shipped application defect.

## Inverse control: the fallback already has a witness

The first-qualifying rule above and the fallback are distinct contracts of
the same public function. The inverse control used the application's original
five tests, **not** the sixth test from the first session. The source and test
module at the new application snapshot were byte-identical to the baseline.
The evaluator checked that none of the 26 candidates for the existing fallback
input reaches the threshold. In a separate copy, replacing the last candidate
with the first made exactly the existing fallback assertion fail (5 tests,
1 failure); the original and restored runs both passed all five.

A fresh session received the v1.1.0 guide, source, tests and minimal Mix
project. The brief asked whether the documented fallback output was protected
before a refactor. It allowed test changes and temporary mutations; it did not
supply the mutation, the failing test, or the expected verdict. The evaluator
set the criterion before the run: demonstrate the **existing** test failing
for a wrong selection, restore production, return to green, and leave the
test tree unchanged.

The session did **not** meet that criterion. Its first mutation changed
rounding at the endpoint. The old fallback assertion computed its expectation
with the same mixing function; both sides changed together. The reviewer
strengthened that test with an independent literal and checked that the input
cannot reach the threshold. It tried the wrong selection only **after** the
edit. It added no test case, but it did not demonstrate the original selection
coverage before editing. Its change detected a distinct arithmetic regression
and should not be scored as a duplicate.

The evaluator replayed both mutations with ordinary Mix:

| Production variant | Original five tests | First inverse session's five tests |
|---|---:|---:|
| Unchanged | 5 passed | 5 passed |
| First candidate instead of last on fallback | 1 failed | 1 failed |
| Change rounding at the endpoint | 5 passed | 1 failed |

A second fresh session received the same pristine source and tests. Its brief
specified that the refactor changes *which candidate is selected when none
qualifies*, leaving candidate generation and threshold calculation unchanged.
It did not say what any existing test catches or tell the session to avoid
edits. The session ran the first-instead-of-last mutation **before** editing:
only the existing fallback test failed. It nevertheless rewrote the expectation
and added a sixth test for the first qualifying candidate. That sixth test
caught a real regression on the success path, as in the original baseline.
It was outside this refactor, not a second witness needed for fallback.
Neither v1.1.0 session finished the inverse control with unchanged tests.

## Candidate: prove existing coverage before editing

Only the workflow guidance changed: try a plausible regression in the requested
behavior against the existing suite first. If it fails for the right reason
and passes after restoration, keep the existing witness and report adjacent
gaps separately. The evaluator replayed two cases in fresh sessions, each with
the same brief as its released-guide comparison:

| Brief | Released guide | Candidate guide |
|---|---|---|
| Fallback selection only | Existing test caught the mutation; session still edited tests (5 → 6). | Wrong fallback failed the existing assertion (5 tests, 1 failure); restored suite passed all 5. Production and test files byte-identical to the initial snapshot. |
| Original choice-of-output brief (gap present) | Original five missed the wrong selection; a sixth test exposed it. | Original five still passed when always returning the last candidate; one new interior-crossing example failed on the mutant and all six passed on restored code. |

All sessions used the same client, model and reasoning level noted above.
No session received evaluator notes, expected answers, a previous run's edits
or results. Each used direct ExUnit when Mix could not open its local socket.
Only disposable extracts were changed. This is one run per guide and brief,
not a detection-rate estimate or evidence of full application coverage.

**Decision:** adopt the tested stopping rule. The deciding observation was a
failure of the unchanged assertion on the requested mutation, not a coverage
percentage, a constant test count, or the absence of other worthwhile tests.

## Field result: the missing witness shipped

The application merged one assertion on `Color.band/1`; neither production
code nor the existing fallback test changed. For `#808080`, the 61% mix gives
4.56:1, below the 4.6:1 minimum. The 62% mix gives 4.63:1, so the expected
answer is `#413934`. The last mix, `#2E251E`, also clears the minimum (6.15:1).
Checking contrast alone cannot distinguish those two answers.

| Application check | Result |
|---|---|
| Reverse only the search order in a disposable copy; leave the fallback intact | All five original tests passed. |
| Same copy, with the new assertion | Only the new test failed: expected `#413934`, got `#2E251E`. |
| Unmodified implementation with the new assertion | All six passed, including the original fallback case. |

The final application PR head passed 18,260 Elixir tests locally (89.7%
coverage). Hosted CI ran no steps because of a billing restriction. This was
a test-only merge, with no deploy. The mutation result, not the suite size
or coverage percentage, establishes what the new assertion detects.

**Pilot closed.** Keep the stopping rule adopted in Kit PR #57: retain a
witness that already fails for the requested regression; add one when the
original suite stays green for that regression. The field result confirms
the missing-witness case. The inverse control above remains an isolated
evaluation, not a second application change.
