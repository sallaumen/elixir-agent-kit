# Architecture review: does a new module break this compile cycle?

**Decision:** correct the description of unfiltered xref output; keep the workflow,
routing and evidence requirements as they are. The old skill and experimental
wording both produced the right architectural decision in both sessions. This
is evidence against adding a mandatory investigation step on the strength of
this case alone.

## Case and independent verification

Real source: [Jason v1.4.4](https://github.com/michalmuskala/jason/tree/926d2ac6cc0271b9a7079b2ec16ae0cf802f7963).
The task and proposed extraction were constructed for this evaluation; they
are not an upstream bug report or a claim about newer Jason releases.
On Mix/Elixir 1.19.5 and OTP 27, three calls in the body of
[Jason.Encode](https://github.com/michalmuskala/jason/blob/926d2ac6cc0271b9a7079b2ec16ae0cf802f7963/lib/encode.ex#L288)
to the ordinary functions jump_table/2 and /3 generate escape tables during compilation.
In the other direction, key encoding in Codegen calls Encode.key/2. Xref
groups source files, not individual modules. The group's presence is not a
measurement of compile duration or recursive execution.

| Layout in a fresh upstream snapshot | Unfiltered cyclic groups | Compile-connected groups | Upstream encode, helper and decode suites |
|---|---:|---:|---|
| Unmodified release | 1 | 1 | 2 doctests + 38 tests passed |
| Pure table functions moved to another module in codegen.ex | 1 | 1 | Same 40 passed |
| Identical module and functions in their own file | 1 | 0 | Same 40 passed |

The existing skill described the unfiltered graph as “for runtime cycles”.
The baseline is a counterexample to **runtime-only** interpretation: the
unfiltered group contains a compile dependency. The residual group after
separating files is not a failure of the compile-cycle objective. Passing the
focused tests does not establish full compatibility or a speedup.

With Python 3.12+, Git, Mix, Hex and a local clone containing the pinned revision,
run the [replay script](../../fixtures/jason-architecture/replay.py) with the clone
path as its only argument. It archives that commit into three temporary directories,
fetches its locked test dependencies, builds with MIX_ENV=prod, checks both xref
reports, then runs the three suites under MIX_ENV=test. Only the evaluator sees
these variants. The input clone is not edited; dependency fetching can use the
network and the local Hex cache.

## Live review comparison

Four fresh Codex CLI 0.162.1 sessions, gpt-6-sol, medium reasoning, companion
configuration off. The first session used the unchanged guide; then we tried
the experimental text and repeated both arms. Each had a separate checkout
of the pinned source, a copy of the kit guide at a1ae7d2 (with or without the
[evaluator-only patch](../../fixtures/jason-architecture/candidate.patch)),
and the same saved baseline output: both cycle reports and the xref traces
of lib/encode.ex, lib/codegen.ex and lib/encoder.ex. No post-change graph,
grade key or other sessions' answers were supplied. The patch targets that
baseline revision, not the subsequently corrected skill.

The question was whether moving the jump-table functions into a new module
immediately above Jason.Codegen in the same file would meet the compile-cycle
objective without changing encoding behavior. Ask for the evidence in both
reports, the recommended boundary, and what to verify; request a read-only
proposal and distinguish predictions from measurements.

| Criterion (manually assessed from the final answers) | Existing | Candidate |
|---|---:|---:|
| Reject same-file change and identify the source file as the unit | 2/2 | 2/2 |
| Locate module-body compile calls and the reverse dependency; recommend a separate pure helper | 2/2 | 2/2 |
| Separate predicted graph from measured baseline; propose behavior checks | 2/2 | 2/2 |
| Explicitly say the graphs are not runtime call traces | 0/2 | 2/2 |

Neither baseline answer **claimed** runtime recursion. The extra sentence made
the limit clearer; it did not fix a wrong decision. The examiner knew the case,
the prompt highlighted the file placement, and the sessions received prepared
traces. This measures interpretation, not whether an agent would independently
find the right evidence. On another task, test discovery without prepared traces.
The exact [final answers and client usage](runs.json) are retained for review.
