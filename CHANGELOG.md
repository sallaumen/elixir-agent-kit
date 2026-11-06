# Changelog

## 0.4.0

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

## 0.3.1

- Point game and canvas interface work to one pinned external skill,
  `game-ui-ux` from awesome-gamedev-agent-skills, beside the kit's frontend
  workflows. The routing guide links it; no external text is packaged.
- Add routing case E41 (41 total) for a canvas HUD and pause menu.

## 0.3.0

- Rework all 33 workflows with task-specific inputs, decision points, quality
  criteria, validation evidence and pitfalls, drawing selectively on the original
  long-form collection and reviewed professional skills.
- Group workflows into frontend, backend, cross-cutting engineering and delivery
  in the catalog and `mix agent_kit.list`; add an area routing guide.
- Add a complete source-review matrix, 11 routing cases (40 total) and a
  documentation map. Preserve the
  reference-only consumer layout and the offline integrity contract.

## 0.2.0

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
