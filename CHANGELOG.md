# Changelog

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
