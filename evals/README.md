# Routing evaluation cases

These 87 cases keep the original requests (all in Portuguese) and their evaluator
criteria, in either language, with public workflow IDs. `EVOLUTION` routes to the maintenance guide;
`NONE` means a bounded task does not need a broader workflow. Cases stay outside
the installed library so expected answers are not injected into agent instructions.

For a live evaluation, give the executor only the request plus ordinary project
context. Keep criteria with an independent evaluator. Record model/client version,
package revision, actual selected files, actions and results. Include negative,
neighboring-workflow and insufficient-input cases. Never infer model compliance
from structural validation. No paid/model evaluations run automatically.

## Running a size round

`python3 scripts/eval_matrix.py` prints the coverage matrix: the code and backend
workflows in rows, small, medium and large in columns, and the case IDs in each
cell. A live round fills that matrix with observed runs:

1. Install the kit at a fixed version in a disposable worktree of a real consumer
   and run `mix agent_kit.check`.
2. Start one fresh client session per run with the case request, one sentence of
   project context, and a closing request to list the files read and the workflow
   chosen. Reset the worktree between runs.
3. Record one row per run in `evals/results/YYYY-MM-DD-<client>.tsv` from the
   transcript, which is the evidence. The header is
   `run case client model kit routed size_stated plan outcome turns tokens notes`
   (tab-separated). `size_stated` is `small`, `medium`, `large` or `none`; `plan` is
   `before_edit`, `after_edit`, `none`, or `review` for a plan written in a mode that
   does not edit; `outcome` is `finished`, `turn_cap` or `error`; `turns` and
   `tokens` are integers or empty. Start `notes` with the
   [Ponytail](../docs/compatibility.md#recommended-companion-ponytail) level the
   client ran with (`ponytail=full`, `ponytail=off`), because it changes how much
   code and text a run produces; compare runs only at the same level.
4. Have an independent evaluator judge each run against the case's success and
   failure signals, and note the verdict in `notes`.
5. Run `python3 scripts/eval_matrix.py evals/results/<file>.tsv` for the outcome
   matrix (runs, routed, size, plan and finished per cell; large passes the plan
   rule with `before_edit` or `review`, small and medium with `none`) and commit
   the `.tsv` with a short Markdown summary beside it.

`scripts/check_library.py` validates every committed `.tsv`, so a malformed row
fails CI. Runs are manual and paid; nothing here calls a model.

## Case notes

E25 removes private product names. E27 corrects a contradictory legacy criterion:
its user explicitly authorizes merge/deployment, so requesting the same authority
again is not success. Required checks and any independently applicable boundaries
still apply. A read-only review alone never grants publication authority.

E30–E40 add one primary routing case for most previously uncovered workflows.
They test selection criteria and expected quality signals; they are not a record
of live GPT, DeepSeek or Claude evaluations.

E41 checks the routing guide's external `game-ui-ux` pointer: it applies only
when the project source has a canvas or game scene.

E42 adds the interface-motion route (`motion-design`) for a screen where one borrowed easing runs on every change. E43 checks the rendered-video boundary: the kit has no video workflow, so the expected route is `NONE` with the external `motion-designer` skill named by the routing guide; selecting `motion-design` is acceptable only if the boundary is stated.

E44 (a paid provider call that charges twice) and E45 (a poller whose state differs
after a restart) cover `provider-calls` and `process-lifecycle`. E46 names a local
contract first and still expects a kit workflow (`async-state`), the case the
2026-11-06 live evaluation was built on.

E49 (density within one width that does not break) and E50 (a measured render
time at a known data scale) keep `layout-density` and `performance` covered as
primaries after the E05 and E07 changes below.

E47 gives `responsive-layout` its first primary case (a phone overflow and thumb
reach with a working desktop). E48 is the first backend `NONE` case (one log line in
a worker), so over-routing on bounded backend edits is measurable. E05 now expects
`responsive-layout` with `layout-density` as the alternative, since width behavior
left `layout-density` in 0.6; E07 expects `debugging` with `performance` and
`process-lifecycle` as alternatives, because nothing is measured yet and the
freeze follows a deploy.

E51 to E54 cover `house-patterns`: a contract rule that two clients break (E51,
primary), two copies of one job that belong to `code-consolidation` (E52), a request
to standardize where no pattern was chosen yet, which is `architecture-review` with
`house-patterns` acceptable only if it stops for a recorded decision (E53), and a single fully specified
client edit that needs no workflow (E54, `NONE` with `house-patterns` as the
alternative) so over-routing on a one-site conformance edit is measurable.

E57 to E62 come from the deeper Elixir review: a Broadway consumer stuck on a
poisoned message with duplicate writes (E57, `data-pipelines`), compile-time
coupling and a cycle between contexts (E58, `architecture-review`, with
`build-dependencies` acceptable), a large import that exhausts memory and
duplicates rows after a restart (E59, `data-pipelines`, with `performance`
acceptable), a one-function `for` rewrite that needs no workflow (E60, `NONE`),
a written decision applied to six call sites (E61, `house-patterns`, with `NONE`
acceptable for a mechanical change), and a GenServer whose mailbox floods under
load, which stays `process-lifecycle` (E62) so many events alone do not pull
routing to `data-pipelines`. Each carries an `expected_size`.

Every case carries `expected_size` (`small`, `medium` or `large`), following the
contract's "Plan in proportion to size" table, so a live evaluation also judges
the size classification. E55 (extracting a billing flow from a LiveView, a
context and two Oban workers while queued jobs keep working) and E56 (progress
events out of order across a worker, PubSub and a LiveView) are large cases: the
expected behavior is a plan file in `.elixir-agent-kit/plans/` before the first
edit, and stopping for approval only on a stop-and-ask trigger.

E63 to E66 cover the refactoring workflows. E63 asks for a functional-style
refactor of a module whose rules read the clock and the database
(`functional-refactoring`); E64 asks for a readable, Clean Code style cleanup of
working code (`readable-code`); E65 is a request that names no style ("refactor module X") but shows both
symptoms, where the expected route is `functional-refactoring` first with
`readable-code` planned as a later slice; E66 renames a public function, a
negative case for `readable-code` (`module-design`, or `NONE` for the bounded
edit).

E67 to E82 complete the size coverage of the code and backend workflows: every
workflow in those areas now has a medium and a large case, and
`scripts/check_library.py` keeps it that way. The large cases expect a plan in
`.elixir-agent-kit/plans/` before the first edit, except E76, a large read-only
review, where the expected behavior is a written review plan and no edit. E79 to
E81 are medium cases, where the first-step artifact in the reply is the plan and a
plan file is a failure. E82 is a small case that expects `NONE` and no plan.

E83 to E87 test that size changes the route, following the "Size changes the
choice" section of `ROUTING.md`. E83 and E84 are one pair of the same kind of
request at two sizes: two competing onboarding paths in one delivery is
`code-consolidation` (medium), while several half-done areas across contexts,
finished or retired in owned deliveries, is `delivery-coordination` (large). E85
and E86 are the provider-call pair: one module whose retry charges twice is
`provider-calls` (medium), while the same call discipline across three contexts
and two workers, each with its own owner and retry, delivered in owned pieces, is
`delivery-coordination` (large, and a `provider-calls` answer is its failure
signal). E87 keeps the small boundary measurable: a fully specified timeout
change stays `NONE` even where the provider-call area nominally applies.

The large arm of each pair deliberately reuses the shape of an earlier large case
(E84 echoes E01, E86 echoes E68); the pair's value is the size contrast within
the pair, not a new large-route discovery.
