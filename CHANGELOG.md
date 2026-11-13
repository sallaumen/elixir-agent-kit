# Changelog

## Unreleased

## 1.1.0 — 2026-11-13

- Minor release: code reviews can now use a changed branch, caller or previous
  fix to prioritize a failure scenario. Small reviews skip this step. The
  existing workflow IDs, installer, configuration and dependencies are unchanged.
- Architecture review now describes unfiltered Mix xref cycles as groups across
  all dependency labels. The [closed pilot](evals/results/2026-11-13-architecture-prioritization.md#production-follow-up)
  confirmed 19 fewer recompiled sources with the real adapter still enabled.
  No analyzer or additional review step is required.

## 1.0.0 — 2026-11-08

- Documentation recommends Ponytail as an optional companion: per-client setup
  in `docs/compatibility.md`, a pointer in both READMEs, and live evaluation runs
  record the Ponytail level in `notes`. This recommendation was already in the
  published 1.0.0 tag.

- First stable release. The 0.x fronts are complete and published: size-guided
  routing with a per-workflow `## Size` section (0.9.0), the quality review of
  all 38 workflows (0.10.0), and the public-interface and versioning
  documentation (0.9.0).
- A field round on four real projects ran the kit at v0.10.0: two readable-code
  medium executions merged with full gates, and a written no-real-need rationale
  for the other code/backend workflows, whose machine-enforced project guards
  already prevent those defect classes (see
  evals/results/2026-11-08-deepseek.md).

## 0.10.0 — 2026-11-08

- Quality review of all 38 workflows: every numbered step now ends in an
  observable "Done when" (revision-lineage, provider-calls, responsive-layout,
  accessibility, motion-design, test-strategy, async-state and process-lifecycle
  gained theirs), `check_library.py` flags the obsolete `mix xref callers` and
  `Repo.transaction` in workflow bodies, and `data-contracts` uses `Repo.transact/2`.
- Trigger and separating-rule fixes: `architecture-review` names
  `functional-refactoring` and `readable-code` and stresses ownership over
  duplication; `accessibility` carves out one control's keyboard path and
  separates WCAG target size from width and reach; `revision-lineage` carves out
  stale asynchronous results. Mechanics that drift are pointed at the `elixir/`
  references instead of restated, and `navigation-ux` and `performance` stop and
  ask before a schema change.

## 0.9.0 — 2026-11-08

- Task size now changes the route and the execution: `ROUTING.md` gains a "Size
  changes the choice" section, every workflow gains a required `## Size` section
  saying what to trim, keep or slice at each size, and `START.md` surfaces the
  rule at choice time. `scripts/check_library.py` requires the section and its
  Small, Medium and Large bullets in all 38 workflows.
- Five new evaluation cases E83 to E87 (87 total) test size-routed pairs: the
  same kind of request changes route by size (competing flows, paid calls), and a
  fully specified small edit stays NONE.
- `docs/versioning.md` defines the public interface under semantic versioning
  (configuration keys, Mix tasks and flags, file layout, the `state.tsv` format,
  the block markers and the stable workflow IDs), the versioning and deprecation
  policy, and an upgrade guide; `scripts/check_library.py` keeps the documented
  workflow IDs in sync with `catalog.tsv`.

- Every code and backend workflow has a medium and a large evaluation case
  (E67 to E82, 82 total), and `scripts/check_library.py` enforces that coverage.
- `scripts/eval_matrix.py` prints the coverage matrix by workflow and task size,
  and, from live-round result files in `evals/results/*.tsv`, an outcome matrix of
  routing, stated size, the plan rule and completion. It reads files only and
  calls no model; `check_library.py` validates every committed result file.
- `evals/README.md` documents how to run a size round.

## 0.8.0 — 2026-11-07

- New workflows `functional-refactoring` and `readable-code` (code area), both
  behavior-preserving and analyze-and-fix. `functional-refactoring` makes a
  module's hidden inputs explicit at the edge, extracts its decisions as pure
  functions tested without stubs and layers its functions (ideas from *Grokking
  Simplicity*, concept only). `readable-code` resolves reading obstacles inside
  working code (names, nesting, comments, error flow) through the `code-shape`
  vocabulary (ideas from *Clean Code*, concept only).
- `ROUTING.md` routes refactoring requests by symptom; a vague request with both
  symptoms runs `functional-refactoring` first and `readable-code` as a later
  slice. `abstraction-layers`, `module-design`, `code-consolidation` and
  `house-patterns` name the new boundaries.
- Evaluation cases E63 to E66 (66 total).

## 0.7.0 — 2026-11-07

- A deeper Elixir review before 0.7 (Elixir anti-pattern and library guides, the
  1.18 to 1.20 changelogs, Phoenix 1.8 usage rules and guides, Ecto, Broadway and
  Mox docs, `boundary`, public style guides and agent rule sets) adds four
  references: `elixir/pipelines.md` (pipe idioms, normalized `with` errors, token
  pipelines, `Repo.transact/2` and `Ecto.Multi`, query composition, Enum versus
  Stream, `Task.async_stream` options, GenStage, Flow and Broadway failure
  semantics), `elixir/architecture.md` (dependency direction, scopes, behaviours as
  contracts, configuration in libraries, `boundary`, umbrellas, compile-time
  coupling and `mix xref` gates), `elixir/library-authoring.md` and
  `elixir/agent-loop.md` (docs of the locked version through `mix help`,
  dependency usage rules, the feedback ladder, commands to avoid, Tidewave only
  when present). `elixir/code-shape.md` now uses the anti-pattern vocabulary
  (assertive code, data modeling, errors, naming, docs, the type checker, macros);
  LiveView, Ecto, security, OTP, ExUnit, build and libraries gain the matching
  rules, and `Repo.transaction/2` advice moves to `Repo.transact/2`.
- New workflow `data-pipelines` (backend) for flows of many items: a flow card,
  idempotent effects proven against a duplicate, a poisoned item that leaves the
  flow with a record, bounded memory and concurrency. `pipeline-design` points data
  pipelines to it. `architecture-review` gates compile-time cycles and records the
  substitution seam; `abstraction-layers`, `module-design`, `code-review`,
  `test-strategy`, `performance`, `process-lifecycle` and `house-patterns` gain
  their Elixir rules.
- Fix: `house-patterns` no longer suggests `mix xref callers` with a function,
  which Elixir 1.19 rejects; it uses `mix xref graph --sink`. LiveView tests assert
  on elements by DOM id, as Phoenix's usage rules ask, not on raw HTML.
- Evaluation cases E57 to E62, each with an `expected_size`.
- The shared contract plans in proportion to size: `START.md` step 1 names the task
  size (small, medium or large) and a new step 5 asks a large task to write a plan
  from `templates/task-plan.md` in `.elixir-agent-kit/plans/` before the first edit,
  to reread it after compaction and to ask for approval of the plan only on a stop-and-ask trigger, while authority rules still apply.
- The installer owns `.elixir-agent-kit/plans/.gitignore`, which ignores the
  folder's contents without touching the project's `.gitignore`; uninstall keeps
  existing plans. `check` reports the file as drift when missing or edited.
- Every evaluation case carries `expected_size`; E55 and E56 add two large cases.
- New workflow `house-patterns` (code area): bring existing code to patterns the
  project already established, with a pattern card, a deviation table, a public-seam
  test pinned before each one-rule, one-site step, defects reported apart and the
  gate green on the head commit. The routing guide separates it from
  `code-consolidation` (two implementations of one job) and `architecture-review`
  (no pattern chosen yet); `code-consolidation`, `module-design`,
  `abstraction-layers` and `architecture-review` point to it.
- `ELIXIR.md` is now an index of per-technology references in `elixir/`, so an agent
  reads only what its `mix.lock` calls for. New guidance, generalized from the
  practices of a consuming application and checked against the library sources:
  module and function shape (pure decisions beside effects, `@spec` with closed
  reasons, unknown as a value); periodic processes and short-TTL ETS caches;
  LiveView data loading in `handle_params/3`, one keyed async job with a timeout,
  resubscription, `phx-auto-recover="ignore"` and a catch-all `handle_event/3`;
  claim-before-effect writes, idempotent creation keys and upserts that leave other
  writers' fields alone; rate limits that snooze and per-item isolation in Oban
  batches; configuration knobs restored after tests, fixtures for external state and
  `$callers` reach; Req clients as values, status checks, failure style per caller,
  named retry policies and revision-checked writes; `precommit` versus `gate`; and a
  Recommended libraries table with what to leave out.
- `provider-calls` adds the call registry, provider fallback only on refusals
  unrelated to the request, the cheapest passing tier by default, a schema-checked
  paid-answer cache and a fixture engine behind a behaviour. `test-strategy`,
  `process-lifecycle`, `async-state` and `performance` gain the matching steps; the
  validation template asks for the commit each check ran on.
- Evaluation cases E51 to E54 cover `house-patterns`, its two neighbors and a
  one-site edit that needs no workflow.
- Tests cover the CLI option rules (`ElixirAgentKit.CLI.options!/3`), the outdated
  query timeout and an unreachable repository, a pre-existing `CLAUDE.md` and state
  recorded by another kit version; the install smoke exercises selection flags and a
  dry-run uninstall.

## 0.6.0 — 2026-11-06

- The routing guide separates the pairs live sessions confused: density within one
  width versus behavior across widths, code review versus delivery validation,
  notification transport versus alert lifecycle, a late result on the wrong revision
  versus a stale result overwriting state, and debugging as the fallback when no
  area workflow names the symptom. `async-state` names a failed refresh that erases
  the last good state. The catalog header lists all eight operational domains, and
  the installer history left the practice-evolution guide.
- Evaluation cases: E05 expects `responsive-layout`, E07 expects `debugging`, and
  E47 to E50 add a phone overflow, a backend NONE, a density-only screen and a
  measured render time, so every workflow has a primary case.
- `scripts/check_library.py` now enforces the workflow template (headings in order,
  a When to use that goes beyond the catalog sentence, `Start at` and `Minimum`
  lines, no em dashes or operator tools), a primary routing case per workflow,
  CATALOG.md and README rows equal to `catalog.tsv`, the evals README case count,
  Markdown anchors, external skill links pinned to a commit, and every documented
  tag equal to the `mix.exs` version.
- Every workflow now opens with concrete symptoms and the linked neighbors it hands
  off to, orders its inputs with a `Start at` line, ends each step in a condition,
  names the artifact its first step produces, and marks the single `Minimum`
  evidence that proves the fix, so a session that names a workflow has something
  to open first and a bound to stop at. The 26 workflows that still repeated their
  catalog sentence are rewritten to the depth of the eight revised earlier; those
  eight gain the same `Start at` and `Minimum` markers. `layout-density` no longer
  claims width behavior, which belongs to `responsive-layout`.
- The managed block is found and hashed from marker to marker, so a linter that
  removes the blank lines around it, a CRLF checkout or a stripped final newline no
  longer reports "malformed" markers; blocks keep the file's line endings and owned
  files converted to CRLF are not drift. Blocks recorded by earlier versions are
  still recognized on upgrade.
- Generated `AGENTS.md` and `CLAUDE.md` start at the first line, and a block is
  appended after exactly one blank line.
- A `CLAUDE.md` that already imports `AGENTS.md` is not given a second `@AGENTS.md`.
- `START.md` step 4 asks for the workflow's `Start at` input as the first file opened
  and the artifact its first step produces, so a named workflow is also a read one.
- A declared `:elixir_agent_kit` entry in `mix.exs` is the source of truth; keys
  removed there fall back to defaults instead of the recorded state.
- `install`, `sync` and `check` fail when the dependency's library is incomplete at
  the path the links point at; `uninstall` refuses selection flags; the tasks print a
  note when `CLAUDE.md` exists without `:claude` selected; `outdated` times out
  instead of hanging on a stalled network. Task docs describe each task's own flags.
- `docs/README.pt-BR.md` mirrors `README.md` section by section.
- `mix.exs` carries a `docs:` configuration for maintainers who add `ex_doc` to a
  local checkout; the package itself still declares no dependency, because a nested
  dev dependency would be fetched by every consumer. Publish with
  `mix hex.publish package`.
- CI lints `scripts/` with pyflakes.

## 0.5.3 — 2026-11-06

- Move the selection to the start of the session: the generated block, `START.md` and
  the pointer skills now say "before opening any source file for a change or a review,
  select one workflow and name it, or NONE", and step 4 ends with "then open the code
  and investigate the way the workflow says". The v0.5.2 remeasure showed sessions
  reading the local contract and investigating for 50 to 100 turns before the kit,
  then hitting their cap on `START.md`. Existing installations pick it up on `sync`.

## 0.5.2 — 2026-11-06

- `START.md` and the pointer skills now share one body: four steps that end in
  stating the workflow ID or NONE before the first edit, followed by the enabled
  catalog with links into the dependency. The v0.5.1 live rerun
  (`evals/results/2026-11-06-claude-code.md`) showed two backend sessions opening
  `START.md` and leaving it without a workflow; the old index pointed at three
  more files before any `SKILL.md`. Existing installations pick it up on `sync`.

## 0.5.1 — 2026-11-06

- Reword the generated instruction block and the pointer skill description from
  "for development tasks, consult" to "before changing behavior or reviewing code,
  select one workflow", stating that a local contract does not replace the
  selection. The live evaluation (`evals/results/2026-11-06-claude-code.md`) showed
  backend symptoms going to a consumer's own contract and skipping the kit. Existing
  installations pick the new block up on `sync`. Routing case E46 (46 total) tests
  that precedence.

## 0.5.0 — 2026-11-06

- Reorganize the catalog into five areas: frontend; backend and data (contracts,
  migrations, security, provider calls); code structure and quality (architecture,
  modules, consolidation, tests, review, debugging, performance, async and process
  state); operational domains (alerts, notifications, readiness, metrics,
  simulations, eligibility, revisions, model capacity), which a project without
  those domains can omit from `skills:`; delivery and build. Area keys in
  `catalog.tsv` and `mix agent_kit.list` change accordingly.
- Add `process-lifecycle` (code): when a process is warranted, who owns its state
  and how it is rebuilt after restart, blocking callbacks, dedupe and backpressure,
  restart strategy, with tests for restart, duplicates and bursts. Routing case E45
  (45 total).
- Merge `version-lineage` and `asset-lineage` into `revision-lineage` (one identity
  model: entity, immutable revisions, explicit pointers, artifacts that carry their
  parent revision; viewing never selects). Fold `test-consolidation` into
  `test-strategy` as its "Removing duplicates" step. Rename `responsive-mobile` to
  `responsive-layout` and move browser history and overlay behavior to
  `navigation-ux`, which now covers them on every device. Routing cases E06, E11,
  E17 and E31 follow. A `skills:` selection that names a removed ID fails
  `mix agent_kit.check` until updated: `asset-lineage`/`version-lineage` →
  `revision-lineage`, `test-consolidation` → `test-strategy`,
  `responsive-mobile` → `responsive-layout`.
- Rewrite `accessibility`, `async-state` and `test-strategy` with observable
  completion conditions, required evidence and pointers into the Elixir context:
  a keyboard transcript and accessibility tree for accessibility; a lifecycle
  table with one durable owner per transition and out-of-order delivery tests for
  async state; a ranked risk list with each regression test seen failing for test
  strategy.
- Add `provider-calls` (backend), the single paid or rate-limited call: budget
  before the network, one audit row at the billing moment, typed failure reasons,
  retries only with provider-honored idempotency, output validated as data.
  `ai-orchestration` now routes the single call there. Routing case E44 (44 total).
- Rewrite `ELIXIR.md` by technology (OTP, Phoenix and LiveView, Ecto and
  migrations, Oban, ExUnit and diagnostics, build and releases), each with what to
  inspect, what to do and how to verify, so workflows can point at concrete
  mechanics instead of restating them. Applies only to technologies present in
  `mix.lock`.
- Record every review lens with its origin and the license found in the local
  copy (`docs/provenance.md`), date each release in this changelog, describe the
  evaluation cases by language instead of "bilingual", and remove leftover
  "version 0.2" wording from the evolution policy and verification record.
- Redesign the README around a how-it-works diagram (`docs/assets/how-it-works.svg`,
  light and dark), badges, a three-step quick start with the expected output, a
  worked example of an agent routing one request, and the catalog at a glance.
  The Portuguese guide follows the same structure. `install` and `sync` now print
  the next step after listing the paths they changed.
- Generate one pointer skill per native client (`.claude/skills/elixir-agent-kit/SKILL.md`
  for `:claude`, `.agents/skills/elixir-agent-kit/SKILL.md` for `:codex`) with a
  discovery description, the selected catalog and links into the dependency.
  Claude Code and Codex scan only their own skill directories, so the dependency
  alone was invisible to native discovery. No workflow body is copied; uninstall
  prunes only directories the kit emptied; a pre-existing skill with that name
  blocks installation.

## 0.4.0 — 2026-11-06

- Make the Claude block import `AGENTS.md` whenever the kit manages that file
  or the project already has one. Claude Code reads `AGENTS.md` only while no
  `CLAUDE.md` applies, so the previous block hid a consumer's own instructions
  from Claude sessions. Existing installations pick this up on `sync`.
- Add `motion-design`, a frontend workflow for interface motion adapted from
  motion-kit (MIT, revision `6173e5c`): registers, one curve per property, timing
  from distance and weight, a lead and uneven reactions, continuity across layout
  changes, reduced-motion alternatives and browser verification. It carries a
  `MOTION.md` reference with attributed curves and interface timing floors.
- Point rendered video, motion graphics and animated decks to the external
  `motion-designer` skill at a pinned revision; the routing guide states the
  boundary and does not bundle that skill's text.
- Add routing cases E42 and E43 (43 total), and update the catalog, provenance,
  source review and workflow counts.

## 0.3.1 — 2026-11-06

- Point game and canvas interface work to one pinned external skill,
  `game-ui-ux` from awesome-gamedev-agent-skills, beside the kit's frontend
  workflows. The routing guide links it; no external text is packaged.
- Add routing case E41 (41 total) for a canvas HUD and pause menu.

## 0.3.0 — 2026-11-06

- Rework all 33 workflows with task-specific inputs, decision points, quality
  criteria, validation evidence and pitfalls, drawing selectively on the original
  long-form collection and reviewed professional skills.
- Group workflows into frontend, backend, cross-cutting engineering and delivery
  in the catalog and `mix agent_kit.list`; add an area routing guide.
- Add a complete source-review matrix, 11 routing cases (40 total) and a
  documentation map. Preserve the
  reference-only consumer layout and the offline integrity contract.

## 0.2.0 — 2026-11-05

- Replace copied snapshots and per-skill wrappers with a small dependency-backed index and instruction blocks. Fresh checkouts need `mix deps.get`; native per-skill registration is removed.
- Safely migrate 0.1 ownership records, preserving local instructions and refusing modified generated content.
- Add explicit `mix agent_kit.outdated` stable-tag discovery; offline integrity checks retain their meaning.
- Establish shared-source evolution, reusable templates and 29 evaluator-only routing cases.
- Preserve effect-order and bounded-delivery refinements from the original library.


## 0.1.1 — 2026-11-05

- Include the MIT license in installed library snapshots so committed copies retain attribution.
- Update installation examples to the patch release.

## 0.1.0 — 2026-11-05

Initial public release.

- 33 English coding-agent workflows, shared contract, Elixir context and handoff template.
- Codex and Claude Code skill entry points plus generic file-reading integration.
- Mix install, sync, check, list and uninstall tasks with project-level selection.
- Managed blocks and SHA-256 inventory; local edits and unmanaged collisions fail preflight.
- Symlink/path guards, repeated-install stability and conservative removal.
- English and Portuguese setup documentation and a copyable AI installation prompt.
- GitHub distribution; no Hex publication or live multi-client certification claimed.
