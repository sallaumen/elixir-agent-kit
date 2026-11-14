# Engineering workflows: paired implementation exercises

All ten primary guided runs met their case criteria. An additional discovery pair exposed a progress-count regression on repeat; after a focused workflow revision, the final guided run passed the same held-out oracle. All ten controls passed the same
runtime checks; nine also met the requested design criteria. In the remaining
case the control left one calculation outside the requested owner. This supports
bounded adequacy after workflow selection. It does not establish a general
advantage for adding guidance or validate any production application.

## Protocol

Each case was derived by inspecting a historical fix in an Elixir application,
including the affected implementation and its tests or caller changes. The
evaluator rewrote the task using small, independent examples with invented
names and values. No private source, history, model transcripts or application
records are distributed here. The historical solution did not serve as a
text-matching answer key: a different implementation could pass the same
observable contract.

Before the first participant ran, the evaluator recorded the ten briefs,
expected behavior, design criteria and held-out Elixir assertions. Each case
used two new, ephemeral, read-only Codex CLI 0.162.1 sessions, GPT-6.1-Sol at
medium effort, with the same brief in each arm. A had no kit; B also received
the shared contract and the single canonical workflow, byte-identical to
`5f59112`. Run order alternated. The clients saw no other answer, history or
judge. For the ten primary pairs, participants worked from inline briefs,
without tools; the evaluator compiled and ran every returned module independently
in Elixir 1.19.5/OTP 27. The evaluator also inspected dependency direction,
ownership, effect ordering and handoff claims against source evidence. The
participants were blind to the oracle, not to the presence of guidance;
qualitative review was not double-blind.

## What each pair demonstrated

| Workflow | Held-out behavioral or design check | A / B |
| --- | --- | --- |
| data-contracts | Zero and exactly-at-limit requests passed; one over failed. Changing only the owner's value moved the validation boundary and the UI hint in both outputs. | Pass / pass |
| migration-compatibility | Preserved legacy and unrelated fields; existing references won; a missing ordinary source stayed unresolved and an exempt row stayed unchanged. Both retained the fallback absent rollout evidence. No real migration was run. | Pass / pass |
| provider-calls | All four delays, attempt exhaustion, confirmed delivery, permanent refusal and an ambiguous send were exercised both with and without an already-seen audit key. Both isolated a legitimate new event from a retry and advised reconciliation on uncertainty. No network call. | Pass / pass |
| data-pipelines | An entirely retained page advanced; the following page converted only eligible rows. Bank-originated, refunded, imported and previously changed rows survived. Both described guarded updates and durable progress. The transaction advice was not exercised against a database. | Pass / pass |
| abstraction-layers | Successful insert produced notice before broadcast; failed insert produced neither. An existing link took the delete path, preserved its historical return even on delete error, and emitted no notification. The guided entry point named both branches; the control inlined the short deletion branch. | Pass / pass |
| module-design | Two independent slugs produced the original keys on read and write; the writer's return passed through. Both outputs gave storage one key builder and avoided the reverse catalogue dependency. | Pass / pass |
| code-consolidation | Two value callers and the map-change caller shared one normalization rule. Nil, internal spacing, absent name and unrelated padded title survived. | Pass / pass |
| house-patterns | Both left the no-change branch effect-free; the changed branch passed the updated value into the loader once. Both followed the written raw-value and one-stage-per-line rule; their code was identical. | Pass / pass |
| functional-refactoring | Both passed leap-month, last-day, next-day, single clock read, cross-midnight deadline and nil cases. Only B delegated deadline arithmetic to the named pure owner alongside the other calendar rules; A kept it in the public withdrawal module. | Partial / pass |
| readable-code | Both removed the nested decision, preserved signed prefixes and ignored suffixes, returned zero for nil or unparsable strings, called lookup once and propagated its exception. | Pass / pass |

**Evaluator correction.** The first pipeline test accidentally supplied shuffled
rows to a function expressly given an ordered stream in this case; both
implementations failed that assertion. The historical database query orders
its results. The evaluator sorted its fixture to restore the stated precondition
and replayed the same unmodified answers. The expected cursor, retained rows,
eligibility rules and empty-page termination were unchanged. This was a harness
error, not an improvement attributed to the guide.

## Discovery and repeat: changing the meaning of a progress counter

A second design removed the primary pagination exercise's explicit cursor
diagnosis and provided a broken implementation plus a short accounting rule.
Clients could inspect the two synthetic files and run Elixir. The same hidden
oracle included a full protected page, an eligible later row, arbitrary signed
IDs, retained row order, repeated execution and the public count of nonempty
discovery pages. Static review also required the write to inspect the current
stored row and the runner to stay behind the adapter.

- **First pair, unmodified guide:** A diagnosed the stall, but inferred that
  *every* posted row was protected. Its own checks passed; the independent
  oracle reported zero pages and left both eligible rows untouched. B processed
  three pages, changed exactly the two eligible rows and preserved two examined
  pages on rerun. Both complete answers were saved and matched their CLI logs;
  a shared shell wrapper errored after output capture, so its return code is
  not evidence for this pair.
- **Fresh repeat, same inputs and unmodified guide:** A passed. B correctly
  changed the two eligible rows but filtered protected records before paging.
  The first run returned one page instead of three. Its local tests passed
  because they assumed its new page-count semantics. This inverse result is
  why the first pair alone was insufficient. The historical database query
  pages discovery candidates before checking ledger evidence; the progress
  return is an explicit part of the synthetic harness, not a claim about the
  application's public API.
- **Guide change:** one decision now asks which records discovery examines and
  what each public counter measures. It proposes a complete no-write page
  followed by an eligible record to test cursor progress and distinguish pages
  examined from records changed. Neither the trigger nor the routing changed.
- **Fresh post-change pair, identical brief and oracle:** A counted the pages
  correctly but declined to convert any record, overlooking the origin marker.
  B changed exactly the two eligible rows, retained the protected records and
  their order, and returned three examined pages on the first run and two on
  rerun. Its storage write checked current state, origin and evidence; the
  runner used the adapter. This is one successful guided retest, not an estimate
  of repeatability. Across all three discovery pairs, controls passed once in
  three and guided outputs passed twice in three across two guide versions.

The primary-output logs show no tool calls. In the first discovery pair the
only eight commands enumerated/read the two exercise files, checked Elixir's
version, reproduced the problem or tested proposed modules. No outside skill,
plugin, other answer, judge or network lookup was observed. The initial
sessions used an isolated client home with no user configuration; host skill
metadata was not explicitly disabled. The repeat and the post-change pair
disabled host skill discovery, skill search and plugins explicitly.

The [offline replay](../fixtures/engineering-pairs/README.md) contains the
synthetic cases, hidden assertions, answer hashes and returned modules.
Historical identifiers, private source and client logs remain outside the kit.
The primary pairs used 60,629 tokens in total without guidance and 87,290
with guidance, as reported by the CLI. Only these particular tasks were
measured: one paired run per primary case, one client and no routing, release
integration, Ecto execution or reliability estimate.
