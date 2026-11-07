---
name: layout-density
description: "Use when spacing, alignment or information density makes a screen hard to scan or use."
---

# Layout Density

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a LiveView page is hard to scan at the width the user works at even though nothing overflows: a form whose labels, inputs and help text do not sit on one grid; a table or list where related values and their actions drift apart; a dashboard where empty space pushes the next action below the fold while the chrome above has room to spare; a detail page wrapped in nested containers that add borders but no grouping; or a dense admin screen the user calls "cramped" or "airy" without being able to say which rule is broken.

This workflow owns spacing, alignment, grouping and information density within one viewport width. Any symptom stated as "at a width", "on the phone", "overflows", "truncates", "at a breakpoint", "the touch target is too small" or "out of thumb reach" belongs to [responsive-layout](../responsive-layout/SKILL.md), including a wide screen that collapses into one narrow column. When the screen's hierarchy or identity is the problem rather than its spacing, route to [ui-identity](../ui-identity/SKILL.md); when the spacing scale itself is missing or inconsistent across screens, route to [design-system](../design-system/SKILL.md).

## Inputs to inspect

- Start at: the route the user named, rendered in the running application at the one width they reported, with real data volumes; then the spacing, grid and type scale the project defines (its CSS configuration or design guidance).
- The template and components for that route: which spacing comes from the scale, which from arbitrary values, and which containers exist only to carry a border or a shadow.
- The user's most frequent task on the screen and the labels, values and actions that must be read together to complete it.
- Real content: the longest label, the largest list, the empty state and the one-item state, as they render. See [Phoenix and LiveView](../../ELIXIR.md#phoenix-and-liveview) for the streams and forms that decide what renders.
- The shared components the screen uses and the other screens that consume them.

## Workflow

1. Write a reading-order list for the task at the reported width: each group of labels, values and actions in the order the user needs them, its current defect (misaligned, too far apart, stretched, boxed without meaning, hidden by whitespace) and the scale value or grid line that should govern it. Done when every visible group has a row and every defect names a rule, not a feeling.

2. Measure the current layout against that list in the rendered DOM: box edges, gaps and alignment between related elements, in the project's scale units. Done when each defect in the list has a measured value next to it.

3. Correct alignment and spacing from the existing scale: put related labels, values and actions on one grid; remove containers that add no grouping; let actions take their natural width instead of stretching; close the whitespace that pushes the next action out of view. Done when no arbitrary spacing value remains in the changed markup and every gap maps to a scale value.

4. Group by decision, then weight: related content closer together than unrelated content, primary content heavier than supporting content, without flattening the hierarchy [ui-identity](../ui-identity/SKILL.md) established. Done when the rendered order and grouping match the reading-order list.

5. Re-render with the long label, the largest list, the empty state and the one-item state at the same width; confirm type size, targets and line length were not reduced to fit. Done when all four states keep the same grid and nothing was shrunk.

6. Render the shared components you changed on their other consumers and check that keyboard focus order still follows the reading order. Done when every consumer renders without a new defect and the focus order matches the list.

## Decision points

- Spacing values come from the project's scale; when the scale lacks a value this screen needs, use the nearest one and record the gap for [design-system](../design-system/SKILL.md) instead of inventing a value.
- A container earns its border or background by grouping a decision; otherwise it is removed, not restyled.
- Long content scrolls; the target is less friction for the task, never "the whole page fits one viewport".
- Type size, touch targets and line length are fixed inputs here; a layout that needs them smaller has a composition problem, which is routed, not forced.
- The moment a defect depends on the width (it appears or disappears when the viewport changes), stop and route to [responsive-layout](../responsive-layout/SKILL.md) with what was measured.

## Quality criteria

- Related labels, values and actions align on one stable grid from the project's scale; a reviewer can name the scale value for each gap in the changed markup.
- Groups follow the task's reading order, and keyboard focus order follows the groups.
- Empty space no longer hides the next action at the reported width, while line length stays readable and controls keep their size.
- The long label, the largest list, the empty state and the one-item state render on the same grid without truncation or shrinking.
- Every shared component changed has its other consumers rendered without a new defect, or the unchecked ones named.

## Validation and evidence

- Minimum: the reading-order list with measured before and after values, and the route rendered in the running application at the reported width with real data.
- When turns allow: the same route rendered in the long-label, largest-list, empty and one-item states at that width.
- When turns allow: the accessibility tree or DOM order of the changed region, showing the focus order matches the reading order.
- When a shared component was changed: each consumer rendered once, with the ones not checked named.

## Avoid

- Do not shrink type, targets or line length until a layout happens to fit; do not apply a universal no-scroll rule.
- Do not add arbitrary spacing values or a new container style when the project has a scale and components.
- Do not fix a width-dependent symptom here or add breakpoints; route it to [responsive-layout](../responsive-layout/SKILL.md).
- Do not flatten the hierarchy into even spacing everywhere; grouping needs contrast between near and far.
- Do not change data semantics, ordering rules or domain copy while regrouping.

## Completion

The screen reads in task order at the reported width, with related content aligned on the project's scale, meaningless containers removed and the next action visible, verified with real content and the long, large, empty and one-item states. For a width, overflow, breakpoint or touch-target symptom use [responsive-layout](../responsive-layout/SKILL.md); for hierarchy and identity use [ui-identity](../ui-identity/SKILL.md); for a missing or inconsistent spacing scale use [design-system](../design-system/SKILL.md); for keyboard and announcement barriers use [accessibility](../accessibility/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
