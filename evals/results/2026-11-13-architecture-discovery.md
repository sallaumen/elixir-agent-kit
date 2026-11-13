# Architecture review: discovery from an incremental build symptom

**Keep the guide unchanged.** In a private Phoenix application, two independent
sessions using the guide at 78f0873 found the same compile-time dependency
without receiving an xref report, a list of suspect modules or the fix. Both
distinguished the cause from plausible runtime calls and an unrelated cycle.
This result covers explaining one named consumer, not finding the largest
recompilation cost in an unfamiliar repository.

## Setup

At a fixed application revision, the evaluator compiled a clean checkout using
the project's pinned Elixir 1.19.5 / OTP 27 toolchain and test environment.
After a no-change compile did no work, adding only a comment to a utility file
recompiled 46 source files. Restoring the bytes recompiled the same number.
Before the sessions we recorded the expected causal path, two alternatives,
the smallest plausible correction and what this experiment could not prove.

The brief named the changed utility and one unexpected UI consumer, asked why
the latter rebuilt and what to investigate or change. It did not give a middle
module, graph output, traces, count, proposed extraction or expected answer.
Each session had its own tracked source snapshot and warm build, no remote,
no application credentials or evaluator notes. A local command adapter ran
the installed Mix xref task against the copied compiler manifest, without
booting the application. Reviewers chose every query themselves. Providing
that adapter cues xref as an available tool; this tests discovery of the edge,
not unaided selection of a tool or exact prediction of the other 45 files.

## Reviewers and ground truth

Codex CLI 0.162.1, gpt-6-sol, medium reasoning, fresh ephemeral sessions with
user config off, same guide and brief. Both traced a module-body attribute
calling a helper at compile time. The helper file depends on the edited utility
at runtime, **in other functions**. Elixir tracks source files rather than a
per-function call graph for this purpose. A separate call inside the rendering
function and the caller's template invocation are runtime dependencies; neither
explains why this consumer itself must be recompiled. Both sessions checked
cycle membership and rejected it as an explanation for this path.

| Fresh session | Both edges and their labels | Distinguished runtime render/template usage | Guarded recommendation | Shell calls / output tokens |
|---|---|---|---|---:|
| A | Yes | Yes | Move the deterministic sample calculation to render; measure before claiming a win | 41 / 4,109 |
| B | Yes | Yes | Same, with no claim about unrelated recompilations | 45 / 5,546 |

These counts are observed client events, not billing or time. The sessions
were read-only; the coordinator graded the answers and independently ran the
intervention. Private source, raw transcripts and project paths are not included.

## Intervention

The evaluator moved only the deterministic sample lookup into the existing
render function, computed once per render and reused. The same utility edit
now rebuilt **45 instead of 46** files. The only file removed from the compiled
set was the named consumer; no files were added. Its edge to the helper changed
from compile to runtime. The rendered HTML was byte-identical and the 27 focused
application tests passed. This is a measured reduction by one source file,
not a measured wall-clock speedup or a claim that moving work to request time
is always beneficial. A broader recompilation problem remains a separate task.

The [unnamed-consumer round](2026-11-13-architecture-prioritization.md) tests the separate question of which dependency to investigate first.
