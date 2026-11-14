# Runtime and delivery: controls from a real application

The evaluator selected historical application revisions and fixed the question
and pass criteria before dispatch. Each pair used the same pre-fix source
extract (or, for validation, the same historical delivery record), in separate
read-only sessions. A received the task alone; B also received the current
workflow and shared contract. Neither got the later patch, the grading key,
the other response or repository history. This measures performing a selected
task, not routing into it. Planning cases were scored as plans, not as shipped
changes.

## Independent controls

| Workflow | Control outside the review sessions |
|---|---|
| Performance | Ran the old and corrected application guard on 300 and 600 generated tags, including a comparison operator inside an attribute. Both accepted clean input and reported the planted offender on line 601. At 600 tags the old and corrected runs took 1.08 s and 0.32 s including VM startup on this machine; single runs illustrate scale, not a benchmark guarantee. |
| Async state | Executed five historical decision clauses against combinations of the rendered mark, current mark and related payment state. A matching clear removes the mark; repeated clear on an empty row is harmless; conflicting marks cannot silently erase a paid state. |
| Process lifecycle | A real OTP timer delivered its message to the evaluator process before cancellation. Cancellation returned false and left the tick available. The real field fix consumed that tick; this probe did not run a LiveView. |
| Pipeline design | Installed each historical hook in a disposable Git repo with real commits and a recording substitute for the expensive check. The old hook ran it on deletion-only and deletion plus docs; the fix skipped both, still ran on new code and deletion plus code, and skipped docs alone. |
| Build dependencies | A cold copy failed with a missing module. Installing the locked dependencies in the assets directory and rerunning the same map test against its data yielded 15 passes. No global package install or version change was needed. |
| Delivery coordination | Compared proposed slices against the historical planning and rollout records: first measure, then match, cover all publication paths, provide a human decision and reversal path, then dry-run historical data before any approved writes. A credible delivery plan need not mirror the historical ordering exactly. |
| Delivery validation | Queried two historical CI runs separately: the green 13,314-test run belonged to the guard-batch head, not the later runtime head. That later revision had its **own** successful run with 13,317 tests; its result was deliberately absent from the reviewers' evidence packet. |
| Security boundaries | Replayed 18 assertions on the field fix's panel-entry policy clauses with stand-in structs: both resource types, three authorized roles, mismatched actor and anonymous actor. This was a defensive authorization review; visibility is not a substitute for server authorization and entry does not grant every write. |

## What the two arms returned

| Skill | A: no guide | B: unchanged guide |
|---|---|---|
| `performance` | Isolated repeated suffix conversion and prefix counting at four input sizes; proposed bounded scanning. | Measured the same dominant stage and tested equivalence on edge cases; did not extrapolate the timing to the absent application tree. |
| `async-state` | Reproduced a stale clear in a model, then replaced repeat-to-clear with a separate action. | Also found the stale command and recommended a separate clear action. Both missed the existing gesture as a constraint; see follow-up. |
| `process-lifecycle` | Identified the queued tick after cancellation and recommended binding ticks to the current timer. | Demonstrated the obsolete tick interfering with the replacement timer and proposed accepting only the current timer reference. Both distinguish message delivery from cancellation. |
| `pipeline-design` | Located the deletion misclassification and retained checking of code refs in a mixed push. | Same; ran controls on separate deletion, creation and mixed input records. Skipping a deletion must not skip the rest of the batch. |
| `build-dependencies` | Identified the cold module-resolution failure and prescribed installing the lockfile in the assets directory. | Same; separated local missing-module evidence from the unavailable remote job log. Neither claimed a green full run inside the partial packet. |
| `delivery-coordination` | Proposed a staged, reversible shadow rollout, preserving human decisions. | Added an explicit owner, shared-file ownership, dependencies and acceptance check per slice. Both deferred production writes. |
| `delivery-validation` | Limited the green claim to the named guard head. | Also separated measured guard durations from an unproven suite-wide speedup; required later-head evidence. |
| `security-boundaries` | Separated link visibility, panel access and action-specific authorization; called out missing rendering evidence. | Produced an actor/resource matrix with direct-entry and denied-role controls. Both avoided claiming that missing templates proved an actual exposure. |

The client was Codex CLI 0.162.1, GPT-6.1-Sol, medium; the baseline guide
revision was `5f59112`. Preliminary pairs with host-skill reads or shell
wrapper errors were discarded. Five pairs were repeated, both arms, with host
discovery, skill search and plugins disabled. Three of those pairs needed another repeat with an explicit ban on reading host skills. No retained log showed a read of
an external skill body. These are case decisions, not detection rates.

**Async-state follow-up.** A candidate asked the reviewer to preserve the
rendered gesture, carry what the user saw to the state owner and distinguish a
replay from a conflicting transition. On the original open-ended brief it kept
repeat-to-clear and payment confirmation; its conservative response to a
conflict still required another press. That is not the historical last-choice
behavior. In a fresh paired follow-up, the brief specified that ordinary
unpaid alternation must honor the last named choice without an extra press,
and that the existing gesture and confirmations must remain. Both the original
and candidate guides then produced decision models covering those rules,
duplicates and financially sensitive conflicts. Neither ran a database race.
On a separate stale-lookup control, both correctly matched replies to request
generations, including repeat selection of the same item, without adding
confirmation. Adopt the candidate for preserving the original interaction in
the ambiguous case; it cannot supply a product conflict policy the brief omits.
