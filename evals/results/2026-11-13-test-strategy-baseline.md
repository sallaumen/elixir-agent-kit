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

Keep the guide unchanged for now. Next, give a fresh session a control case
where the existing examples already distinguish the selections. Check whether
it can show the mutation failing without adding a redundant test.
