---
name: ui-identity
description: "Use when a working interface lacks product-specific hierarchy, identity or visual coherence."
---

# UI Identity

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a working interface lacks product-specific hierarchy, identity or visual coherence.

## Inputs to inspect

- A representative running page, its empty/error/loading states, the product brief or DESIGN.md, and the components/tokens it actually uses.
- The primary user decision, real content and copy, relevant screen widths, and any visual reference supplied by the user.

## Workflow

1. Inspect the running interface and the existing design direction before editing. Identify the primary user task, information hierarchy and useful local conventions.

2. Use the product vocabulary, typography, spacing and component system to distinguish important actions and content. Replace generic visual treatments only when their consequences are clear.

3. Preserve functional states, accessibility and responsive behavior. Avoid invented metrics, decorative controls, unverifiable claims and placeholder interactions.

4. Validate the changed flow in a browser at relevant widths. Record what was actually observed; screenshots alone do not establish interaction correctness.

## Decision points

- If the request is a narrow spacing repair, route to layout-density; if the problem is finding the next page or returning to work, route to navigation-ux.
- For a visual refinement preserve incumbent identity; for an authorized redesign compare the old surface with product truth before choosing a new direction.

## Quality criteria

- Make the primary action and essential information distinguishable by hierarchy, position, typography and wording; a decorative accent is not a substitute.
- Treat cards, tables, gradients and illustration as options whose value depends on the task. Remove repeated chrome only when it adds no meaning.
- Design selected, loading, empty, partial, failed, disabled and success states with honest copy. Long names and one-item data should remain legible.
- Preserve keyboard use, visible focus, semantics and touch access. Motion should explain state and honor reduced-motion preferences rather than imply work that has not happened.

## Validation and evidence

- Compare the same flow before and after at relevant wide and narrow widths; exercise a primary action and one recovery path in the running app.
- Report the chosen visual direction, the user problem each major change resolves, actual browser findings and any state or viewport not verified.

## Avoid

- Do not import another product’s aesthetic, invent testimonials or metrics, or turn every surface into equal-weight cards.
- Do not call a screenshot proof of navigation, accessibility or a completed action.

## Completion

A coherent, task-oriented interface with working states and browser evidence. For a narrow spacing problem use layout-density; for an end-to-end journey use navigation-ux.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
