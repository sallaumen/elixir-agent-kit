# Choose one workflow

Start with the project's instructions and actual task. The categories name the
**primary** kind of work, not ownership boundaries in an application's source tree.
A LiveView race may use `async-state` under code structure and quality; a UI that
shows a cross-tenant record needs `security-boundaries` under backend and data.
Follow the trigger, not the directory name. A small, specified edit may need no
workflow beyond the shared contract and project gates.

| Start here when the problem is… | Area | Typical distinctions |
|---|---|---|
| A screen's meaning, interaction, layout, navigation, accessibility, motion or assets | [Frontend and user experience](CATALOG.md#frontend-and-user-experience) | Identity versus density; density within one width (layout-density) versus behavior across widths, overflow and touch targets (responsive-layout); layout at a width versus history and overlays (navigation-ux, on every device); design system versus one screen; motion versus state feedback |
| Persisted data, a schema or payload that must survive a version change, authorization and tenant scope, a paid or rate-limited provider call, or a flow of many items (import, stream, queue consumer) | [Backend and data](CATALOG.md#backend-and-data) | Data contracts versus migration compatibility; a boundary that leaks data versus a call that charges twice; a flow of many items with delivery guarantees (data-pipelines) versus one process (process-lifecycle) versus a CI pipeline (pipeline-design) |
| Code that is hard to understand, review, test, debug, measure, or that holds state in processes | [Code structure and quality](CATALOG.md#code-structure-and-quality) | A diff before merge is code-review (review mode); an integrated revision against acceptance criteria is delivery-validation; architecture versus one module versus one function; existing code brought to a pattern the project already chose (house-patterns) versus two implementations of one job (code-consolidation) versus a pattern nobody has chosen yet (architecture-review); a module's hidden inputs and effects (functional-refactoring) versus reading obstacles inside working code (readable-code), see [Refactoring requests](#refactoring-requests); test gaps and duplicates (one workflow); performance (measured, correct result) versus asynchronous correctness versus process ownership; debugging only when no area workflow names the symptom |
| A product pattern with its own lifecycle: alerts, notifications, integration readiness, metrics and costs, simulations, offer eligibility, revisions and assets, model capacity | [Operational domains](CATALOG.md#operational-domains) | Transport that fails or repeats (notifications) versus an incident's lifecycle (operational-alerts); readiness versus eligibility; capacity across workers versus one provider call; a late result attached to the wrong revision (revision-lineage) versus a stale result overwriting current state (async-state); a product revision versus the running build |
| Packaging, sequencing, CI or acceptance of combined work | [Delivery and build](CATALOG.md#delivery-and-build) | Build failure versus pipeline design; coordination versus independent delivery validation |

Debugging is the fallback, not the first stop: when an area workflow names the
symptom (a stale asynchronous result, a process that differs after restart, a build
that differs by environment, a measured slow path), that workflow applies and its
steps include the reproduction. Read one workflow and its [shared contract](CONTRACT.md). Add a neighboring
workflow only when the task has a distinct risk that the first does not cover;
state that reason. Read [Elixir context](ELIXIR.md) only for technologies actually
used. The default mode in the catalog yields to the user's explicit scope.

## Refactoring requests

A request to refactor names a style, a symptom or neither. Route by the symptom,
then by scope:

- Hidden inputs (the clock, configuration, the database) or effects interleaved
  across a module, or a rule that cannot be tested without them:
  [functional-refactoring](skills/functional-refactoring/SKILL.md); a single
  function with that problem: [abstraction-layers](skills/abstraction-layers/SKILL.md).
- Working, tested code that is hard to read inside its functions:
  [readable-code](skills/readable-code/SKILL.md); a misleading module name,
  location or public function name: [module-design](skills/module-design/SKILL.md).
- Code that drifts from a pattern the project already chose:
  [house-patterns](skills/house-patterns/SKILL.md), whatever style the request names; a
  convention still to be chosen for many modules:
  [architecture-review](skills/architecture-review/SKILL.md).

"In a functional style" or "like Grokking Simplicity" points to
functional-refactoring, and "clean" or "like Clean Code" to readable-code, unless
the symptom says otherwise. When a vague request ("refactor module X") shows both
symptoms, select functional-refactoring and plan readable-code as a later slice of
the same plan.

## Game and canvas interfaces

The kit has no game workflow. When the project renders a game or canvas scene and
the task touches its HUD, menus or overlays, add the external
[`game-ui-ux`](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/tree/19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9/skills/disciplines/game-ui-ux)
skill (Apache-2.0, pinned commit) beside the kit workflow the risk names, usually
`accessibility`, `navigation-ux` or `responsive-layout`. It contributes a screen
stack, focus navigation, event-driven HUD updates, scaling and safe areas; map its
Godot and Unity examples onto the project's own rendering code. The evidence is a
canvas or engine scene in the source, not a playful visual theme. Install that one
skill per project, after reading and scanning it.

## Motion and rendered video

Interface motion is `motion-design`: choosing curves, durations and reactions for
state changes in the running product, with a reduced-motion alternative. It governs
the interface, not film.

For rendered video, motion graphics or an animated deck, apply the external
[motion-designer](https://github.com/hughminhphan/motion-kit/tree/6173e5c408f81f1989435843af3f0788b74bda96/skills/motion-designer)
skill (MIT, pinned revision). It supplies a GSAP helper (`motion-kit.js`), a motion
library and the same principles for frame-accurate work. Read `SKILL.md` and
`LIBRARY.md`, add the skill per project rather than the whole repository, vendor the
helper into the composition, and record the revision. Its text is not bundled here;
`motion-design` is the interface adaptation, and the repository's `docs/provenance.md`
(outside the installed library) records the source revision. A page whose motion is plain CSS does not need
the external skill.

A workflow does not grant permission to send messages, spend money, publish,
merge, deploy or access production. A user's existing authorization still applies.
For frontend work, verify behavior in the running application when available;
for backend work, validate the actual read/write or job boundary. No structural
check proves that a model followed the guidance in a live session.
