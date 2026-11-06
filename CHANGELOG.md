# Changelog

## Unreleased

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
