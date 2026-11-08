---
status: approved
date: 2026-11-08
tags: [routing, size, workflows, installer, evals]
---

# Size guides the workflow choice and its execution

## Problem

Task size (small, medium, large) currently decides only whether a large task
writes a plan file: `CONTRACT.md` has the "Plan in proportion to size" table and
`START.md` step 5 turns it into an action. `ROUTING.md` never uses size, and no
workflow says how its own steps should shrink for a small task or be sliced for a
large one. The evaluation matrix records size but is evaluator-only and changes
no decision. An agent can therefore state the right size and still over-run a
small task, or under-slice a large one, because the workflow text does not scale.

This is the first of the 1.0 fronts. The quality review of the 38 workflows
(front 2) runs after this one because both edit the same `SKILL.md` bodies.

## Decisions

1. Size becomes an explicit routing dimension, not just a planning one. The rule
   is stated once in `ROUTING.md`, visible in `START.md` step 2 at choice time,
   and carried by a short per-workflow `## Size` section that check_library.py
   requires. It does not repeat the contract's size definitions or plan rule.
2. The per-workflow section is a new required heading `## Size`, placed after
   `## When to use` and before `## Inputs to inspect`, with exactly three bullets
   in order: `Small`, `Medium`, `Large`. Each bullet says what is specific to
   that workflow at that size: what to trim, keep, or slice, and which neighbor
   joins as a later slice of the same plan when the task is large.
3. `ROUTING.md` gains a "Size changes the choice" section with the three examples
   the owner asked for: a small, fully specified edit picks NONE; a medium task
   picks the narrowest workflow for its one risk; a large task with several
   deliveries across owners goes to `delivery-coordination`, while a large task
   with one dominant risk stays with that workflow and is sliced by its Size
   section.
4. `START.md` step 2 restates the same rule in one sentence, so a session sees
   size at the moment it chooses; step 4 applies the selected workflow's `## Size`
   line for the stated size.

## The Size section

Template enforced by `scripts/check_library.py` (the eight existing headings gain
`## Size` in second position, and the section must contain `**Small**`,
`**Medium**` and `**Large**`):

```markdown
## Size

- **Small**: <the one or two steps that still apply, and what to skip>.
- **Medium**: <the workflow as written, one flow or module, one delivery>.
- **Large**: <how to slice the steps across the plan, and which neighbor workflow
  joins as a later slice>.
```

The bullets never restate what small, medium or large mean, never restate the
file-versus-artifact plan rule, and never use an em dash. Each is specific to the
workflow's own steps and neighbors.

## Routing cases

New cases E83 to E87, requests in Portuguese, each with `expected_size`. Two pairs
show the same kind of request changing route by size, and one small singleton
shows a fully specified edit staying NONE even where an area nominally applies:

- E83 (medium) vs E84 (large): competing/half-done flows. One pair of duplicated
  onboarding paths, one delivery, is `code-consolidation`; several half-done
  areas across contexts, to be finished or retired in owned deliveries, is
  `delivery-coordination`.
- E85 (medium) vs E86 (large): paid provider calls. One module whose retry
  charges twice is `provider-calls`; the same call discipline across three
  contexts and two workers, delivered in owned pieces, is
  `delivery-coordination` with `provider-calls` as an allowed alternative for the
  domain risk.
- E87 (small): change one timeout constant in one module, fully specified, NONE.

## Verification

- `python3 scripts/check_library.py`: the new heading is required and each of the
  38 workflows has a Size section with the three bullets.
- `mix check`: `test/installer_test.exs` asserts the new step 2 sentence and the
  step 4 mention of the Size section in the generated `START.md`.
- `python3 -m pyflakes scripts/`, `python3 scripts/smoke_install.py --git-url
  "$(pwd)" --ref "$(git rev-parse HEAD)" --deps-path "vendor/deps (shared)"`,
  `python3 scripts/smoke_migration.py`, `mix hex.build`.
- No live evaluation runs automatically; the first size round is manual and paid.

## Delivery

One pull request, then release 0.9.0 (minor: `START.md` and workflow bodies
change what an agent reads and does).

## Out of scope

The quality review of the 38 workflows (front 2), the public-interface and
versioning documentation (front 4), live field-round runs, and any change to the
contract's size table or plan rule.
