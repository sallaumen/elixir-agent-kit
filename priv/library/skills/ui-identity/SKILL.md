---
name: ui-identity
description: "Use when a working interface lacks product-specific hierarchy, identity or visual coherence."
---

# UI Identity

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a LiveView page works but every element carries the same weight, so the primary action (save, publish, approve) is not findable at a glance; when a dashboard or index reads as a grid of equal cards and the user cannot tell what the screen is for; when one page uses a different look from the rest of the product (another font, another accent, generic placeholder chrome) without a reason; when the user says "make this look like ours" or "this looks generated"; or when a new screen must be composed from the project's existing components and direction before it ships.

This workflow owns one screen's hierarchy and product identity. Spacing, alignment and density inside a screen whose hierarchy is already right belong to [layout-density](../layout-density/SKILL.md). Tokens, shared components and rules that must hold across screens belong to [design-system](../design-system/SKILL.md): fix the screen here, promote the rule there. A layout that fails at a width goes to [responsive-layout](../responsive-layout/SKILL.md); one control's affordance goes to [direct-interactions](../direct-interactions/SKILL.md); motion goes to [motion-design](../motion-design/SKILL.md).

## Size

- **Small**: promote one block on the named screen with the incumbent identity; skip the full hierarchy table and reuse the project's tokens and components as they are.
- **Medium**: run the workflow as written for one screen: the hierarchy table, the identity source and every state rendered with real data.
- **Large**: several screens share the direction, or the identity itself is unstated; slice per screen and promote the shared rules to design-system as a later slice of the same plan.

## Inputs to inspect

- Start at: the project's design guidance (DESIGN.md or the file the project instructions name) and the one route the user named, rendered in the running application with real data.
- The LiveView or controller template for that route, the core components it calls (`core_components.ex` or the project's component module) and which of them it bypasses with ad hoc markup or utility classes.
- The user's primary decision on this screen, the data that must be seen together, and the empty, loading, error and success states as they actually render, including long names and one-item collections. See [Phoenix and LiveView](../../elixir/phoenix-liveview.md).
- Two or three neighboring screens of the same product, to read the incumbent identity: type scale, accent use, container style, copy tone.
- Any visual reference the user supplied, and the width at which they reported the problem.

## Workflow

1. Write a hierarchy table before editing: each visible block, its purpose for the user's decision, the weight it has today (position, size, contrast) and the weight it should have (primary, secondary, supporting). Done when every block has a row and the primary action and the key information appear exactly once as primary.

2. Name the identity source: the design guidance when the implementation agrees with it, otherwise the neighboring screens. Record the type scale, accent role, container style and copy tone you will reuse. Done when every visual value you plan to use points at an existing token, component or neighboring screen.

3. Rebuild the weight with the project's own components: promote the primary action and key information by position, size, typography and wording; demote repeated chrome and equal-weight containers. Done when the table's target column matches the rendered page and no new one-off color, font or spacing value was introduced.

4. Render every state in the table with real data: empty, loading, error, partial, success, disabled, long names, one item. Fix copy that is vague or dishonest about what happened. Done when every state keeps the same hierarchy and the copy names what the user can do next.

5. Confirm nothing functional regressed: keyboard reach of the primary action, visible focus, accessible names on icon-only controls, and the layout at the reported width. Done when the primary action completes with the keyboard in the running application.

6. Report the chosen direction, the user problem each major change solves, and the states or widths not verified. Done when the report shows the hierarchy table before and after.

## Decision points

- Do not assume user states are mutually exclusive. For independently true conditions, inspect the actual combination one person sees, together with the action it invites. Keep useful links, but derive the primary action and wording from whether that person still has a decision or commitment to make.

- When the screen asks for a consequential decision, compare the information and choices from the perspective of each person who can arrive there. Group supporting facts or terms as one decision, distinguish what commits it, and trace each realistic alternative through the same guards and state as the primary action. Keep an existing safe way out; if declining simply returns to the same question, identify the reachable alternative and the evidence for it.

- A visual refinement keeps the incumbent identity; a new direction needs the user's explicit authorization and a written comparison of the old surface against the product's actual purpose, made before the change.
- When the design guidance and the implementation disagree, follow what the product already ships, name the gap, and route the rule to [design-system](../design-system/SKILL.md); do not silently pick a side.
- Cards, tables, gradients and illustration are options judged by the user's task; a repeated container that adds no meaning is removed, one that groups a decision stays.
- A style that only this screen needs stays local; a decision two screens will share is promoted, not duplicated.
- If the hierarchy is right and only spacing is off, stop and route to [layout-density](../layout-density/SKILL.md).

## Quality criteria

- The primary action and the key information lead by hierarchy, position, typography and wording at first glance; no decorative accent stands in for hierarchy.
- Every visual value comes from the project's tokens, components or an existing screen; a reviewer can name the source of each.
- All states in the hierarchy table render with honest copy, including long names and one-item data, without a different hierarchy per state.
- Keyboard use, visible focus, semantics and the reported width work as before or better; reduced motion is honored where motion carries state.
- No invented metrics, testimonials, placeholder interactions or decorative controls appear.

## Validation and evidence

- Minimum: the hierarchy table before and after, plus the route rendered in the running application at the reported width with real data, with the primary action completed through the keyboard.
- When turns allow: the same route in each state of the table, with the DOM or accessibility tree confirming the primary action is a real button or link carrying its visible name.
- When turns allow: the same flow at one phone width and one wide width, labeled emulated or observed on a device.
- When a shared component was changed: the other screens that consume it, rendered once.

## Avoid

- Do not import another product's aesthetic, invent testimonials or metrics, or turn every surface into equal-weight cards.
- Do not add a new color, font or spacing value when the project has a token or component for it; do not restyle a core component inline.
- Do not change identity across screens from here; fix the screen and hand the rule to [design-system](../design-system/SKILL.md).
- Do not call a screenshot proof of navigation, accessibility or a completed action; the keyboard path in the running application is the proof.
- Do not reduce a working state (loading, error, empty) to a placeholder because it is visually inconvenient.

## Completion

One screen whose primary action and key information lead by hierarchy, built from the project's own components and direction, with every state rendered honestly and the keyboard path verified in the running application. For spacing and density inside the screen use [layout-density](../layout-density/SKILL.md); to promote a rule or component across screens use [design-system](../design-system/SKILL.md); for a journey across screens use [navigation-ux](../navigation-ux/SKILL.md); for motion that carries state use [motion-design](../motion-design/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
