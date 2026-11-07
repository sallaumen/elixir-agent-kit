# Routing evaluation cases

These 59 cases keep the original requests (all in Portuguese) and their evaluator
criteria, in either language, with public workflow IDs. `EVOLUTION` routes to the maintenance guide;
`NONE` means a bounded task does not need a broader workflow. Cases stay outside
the installed library so expected answers are not injected into agent instructions.

For a live evaluation, give the executor only the request plus ordinary project
context. Keep criteria with an independent evaluator. Record model/client version,
package revision, actual selected files, actions and results. Include negative,
neighboring-workflow and insufficient-input cases. Never infer model compliance
from structural validation. No paid/model evaluations run automatically.

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

E57 to E61 come from the deeper Elixir review: a Broadway consumer stuck on a
poisoned message with duplicate writes (E57, `data-pipelines`), compile-time
coupling and a cycle between contexts (E58, `architecture-review`, with
`build-dependencies` acceptable), a large import that exhausts memory and
duplicates rows after a restart (E59, `data-pipelines`, with `performance`
acceptable), a one-function `for` rewrite that needs no workflow (E60, `NONE`),
and a written decision applied to six call sites (E61, `house-patterns`, with
`NONE` acceptable for a mechanical change). Each carries an `expected_size`.
