---
name: motion-design
description: "Use when interface motion is missing, generic or applied to every change, or when transitions misrepresent state."
---

# Motion Design

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when an interface moves with one borrowed default (everything fades up on the same curve and duration), when a state change is hard to follow without motion, or when transitions replay on every server update and make the screen feel unstable. Use it for a new surface that needs a motion decision and for an audit of an existing one.

This workflow governs **interface motion**. Rendered video, motion graphics and animated decks are a different craft; the [routing guide](../../ROUTING.md) points to an external skill for those.

## Size

- **Small**: replace one borrowed or default transition with a curve and duration chosen for that property and a reduced-motion alternative; skip the register-wide pass.
- **Medium**: run the workflow as written for one surface: the motion inventory, one register and the frame-by-frame validation.
- **Large**: motion across many surfaces, or the motion tokens themselves are missing; slice per surface and hand shared tokens to design-system as a later slice.

## Inputs to inspect

- Start at: the project's motion guidance (its design notes, motion tokens or the [motion reference](MOTION.md)) and the transition in question, stepped through in the running interface.
- The running interface and the real state changes it must explain: load, open and close, select, reorder, submit, fail, reconnect, live update.
- The existing tokens and transitions in CSS, the component library and JavaScript hooks: the properties animated, curves, durations, delays and reduced-motion handling.
- The client stack: how updates arrive (full render, patch, stream append, client navigation), which properties the browser can composite, and the DOM structure that would carry spatial continuity.
- The product register and one moment, if any, that the product wants the user to notice.

## Workflow

1. Inventory the motion that exists. For each animated change, record what triggers it, which property moves, its duration and curve, and what the user learns from it. Mark motion with no job.

2. Choose a register for this surface: technical, editorial, premium, expressive, playful or calm. Keep one dominant register and name the single moment allowed to break it. Pick curves per property from the [motion reference](MOTION.md); do not reach for `ease`, `ease-in-out` or a library default as the answer.

3. Decide what each change **is** before how it eases. A new surface may arrive; a value that changes should update in place; a row that is added should appear without replaying the page's entrance; a state the user caused should answer immediately. Most text and static content cuts on. Reserve a crafted entrance for the element that carries the new context.

4. Derive timing instead of copying it. Duration follows distance and weight; exits run shorter and accelerate; a group has a lead and uneven reactions instead of an even stagger. Keep input feedback fast enough to feel connected, and never delay an action to finish an animation. The reference gives a formula and starting values.

5. Implement with tokens, not scattered numbers: name the curves and durations once, keep them beside the existing design tokens, and reuse them. Use transform and opacity for movement; use the browser's View Transitions API or a FLIP technique when an element keeps its identity across layouts. Do not animate on every broadcast; animate the change that a person caused or that a person must notice.

6. Validate in the running interface: step through an entrance, an exit, a reorder and a failed update; emulate reduced motion; check rapid input, reconnect and slow network. Remove motion that queues, blocks, replays or contradicts state.

## Decision points

- If the motion explains a state change, keep it and make it exact. If it only decorates, cut it or remove it.
- Prefer a cut or a short in-place change for text, rows and counters. A crafted travel is for a new context or a signature moment, not for every section.
- Use a spring only for direct manipulation or physical arrival (sheet, drag, add and remove). Overshoot is a choice; decelerating curves suit most product surfaces.
- Animate a component's entrance on mount, not on each update. If the server re-renders a list, the new item alone may appear.
- When the same element changes layout, keep it continuous (shared element, FLIP, transform-origin) instead of removing and re-adding it.

## Quality criteria

- Every animated property has a curve chosen for that property; horizontal and vertical travel may differ. Neither a named preset nor `transition: all` is a default.
- Durations come from distance and weight, with exits shorter than entrances and interaction feedback immediate. UI timing is shorter than video timing for the same distance.
- Groups have one lead and reactions at uneven offsets. Streams, polls and patches do not replay entrance animations.
- Holds are still unless a living detail communicates real state (progress, listening, sync). No infinite decorative loop.
- Motion never gates input, never implies work that has not happened, and never replaces the visible state it animates.
- Reduced motion is honored with a legible alternative: travel becomes a cut or short change, loops and parallax stop, and the state remains understandable.
- The register matches the product and the surface; a second product's motion identity is not imported.

## Validation and evidence

- Minimum: a frame-by-frame step through the transition in question (a real entrance, exit or list change) in the browser, recording the actual curves and durations and the reason each was chosen.
- When turns allow: emulate `prefers-reduced-motion: reduce` and confirm that the same flow stays legible with the alternative treatment.
- When turns allow: exercise keyboard use, rapid repeated actions, a failed request and a reconnect; confirm that animation does not queue, block or replay.
- When turns allow: compare relevant wide and narrow widths, and report which states, devices or clients were not observed. A screenshot alone does not prove motion behavior.

## Avoid

- Do not animate every stream update, broadcast or reconnect, or re-run an entrance when data refreshes.
- Do not fade and blur everything in, add glow orbs, shimmer, or a scroll reveal for every section; those are template tells, not a motion decision.
- Do not animate layout properties where transform, opacity or a view transition would do, and do not leave a long animation on a critical action.
- Do not disable all feedback under reduced motion when a static or instant form of the same feedback is possible.
- Do not copy a demo reel's devices or another product's curves; take the mechanism and justify the character.

## Completion

Each animated state change has a stated purpose, a curve and duration derived for it, and a reduced-motion alternative, verified in the running interface. For shared motion tokens and component contracts route to [design-system](../design-system/SKILL.md); for a screen's composition use [ui-identity](../ui-identity/SKILL.md); for assistive-technology behavior use [accessibility](../accessibility/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
