# Size guides routing and workflow execution: implementation plan

**Goal:** Make task size change which workflow is chosen and how its steps are
applied, without repeating the contract's size definitions or plan rule.

**Architecture:** `ROUTING.md` gains a size rule; every `SKILL.md` gains a
required `## Size` section; `lib/elixir_agent_kit/installer.ex` makes size visible
in `START.md` step 2; `scripts/check_library.py` enforces the section; five new
cases E83 to E87 test size-routed pairs.

Spec: [size guides routing](../specs/2026-11-08-size-guides-routing-design.md).

## Global constraints

- Edit `priv/library/` bodies only; no em dash (`—`) in any `priv/library` text.
- Do not change `CONTRACT.md` (its size table and plan rule are the source the
  new section must not repeat).
- `evals/routing.json` stays `json.dumps(data, ensure_ascii=False, indent=2) + "\n"`.
- Stage files by name; squash on merge; no force push.

---

### Task 1: Size rule in ROUTING.md

**Files:** `priv/library/ROUTING.md`.

Insert a `## Size changes the choice` section after the intro paragraph that ends
"needs no workflow beyond the shared contract and project gates.", covering:

- Small and fully specified: NONE, even where an area applies; if a small edit
  still touches the risk a workflow names, pick that workflow and use only its
  Size-small line.
- Medium: the narrowest workflow whose trigger matches the single primary risk.
- Large with several deliveries across owners: `delivery-coordination`; each
  slice then follows the domain workflow for its own risk.
- Large with one dominant risk spread wide: that workflow, sliced by its Size
  section, with a neighbor as a later slice when a second risk is real.

### Task 2: check_library.py requires the Size section

**Files:** `scripts/check_library.py`.

1. Add `"## Size"` to `HEADINGS` in second position (after `## When to use`).
2. In the per-workflow loop, after the mode/area checks, add: the `## Size`
   section must exist and contain `**Small**`, `**Medium**` and `**Large**`,
   parsed from `## Size` up to the next `\n## ` heading. Emit one error per
   missing piece naming the workflow.
3. Run it: expect 38 "Size section missing" errors before the sections exist.

### Task 3: Write the Size section in all 38 workflows

**Files:** every `priv/library/skills/<id>/SKILL.md`.

For each workflow, after `## When to use` and before `## Inputs to inspect`, add:

```markdown
## Size

- **Small**: ...
- **Medium**: ...
- **Large**: ...
```

Each bullet is specific to the workflow's steps and neighbors. Small says which
step(s) still apply and what to trim; Medium says the workflow as written for one
flow/module/delivery; Large says how to slice the steps across the plan and which
neighbor joins as a later slice. No em dash, no restatement of the contract.

### Task 4: Make size visible in START.md

**Files:** `lib/elixir_agent_kit/installer.ex`, `test/installer_test.exs`.

1. Rewrite `entry/2` step 2 to state that size from step 1 changes the choice:
   small and fully specified -> NONE; medium -> narrowest workflow for one risk;
   large -> the workflow for the primary risk sliced by its Size section, or
   `delivery-coordination` for several deliveries across owners; the routing
   guide separates two neighbors.
2. Add to step 4 one clause: apply the selected workflow's `## Size` line for the
   stated size.
3. In `test/installer_test.exs`, extend the round-trip assertions for the new
   step 2 sentence and the step 4 mention, keeping the five-step count check.

### Task 5: Routing cases E83 to E87

**Files:** `evals/routing.json`, `evals/README.md`, `README.md`.

Append E83-E87 per the spec (E83/E84 consolidation pair, E85/E86 provider-call
pair, E87 small NONE), regenerate with `json.dumps(..., ensure_ascii=False,
indent=2) + "\n"`, update the README case count in `evals/README.md` and fix the
stale "66 requests" in `README.md` to the new count.

### Task 6: Changelog and docs

**Files:** `CHANGELOG.md`, `README.md`, `docs/README.pt-BR.md`,
`docs/INSTALL_WITH_AI.md` (tag examples stay on 0.8.0 until the release PR).

Add an `## Unreleased` entry (above `## 0.8.0`) describing the size-routed
choice, the per-workflow Size section, the START.md change and the new cases. In
`README.md` "What an agent does with it", describe the size-aware step 2.

### Task 7: Full verification and pull request

Rebase on `origin/main`; run `mix check`, `python3 scripts/check_library.py`,
`python3 -m pyflakes scripts/`, `python3 scripts/smoke_install.py --git-url
"$(pwd)" --ref "$(git rev-parse HEAD)" --deps-path "vendor/deps (shared)"`,
`python3 scripts/smoke_migration.py`, `mix hex.build` (delete the `.tar`). Push
and open a PR with the spec and plan paths, the checks run, and the note that no
live evaluation ran.
