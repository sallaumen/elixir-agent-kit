---
name: layout-density
description: "Use when spacing, alignment or information density makes a screen hard to scan or use."
---

# Layout Density

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when spacing, alignment or information density makes a screen hard to scan or use.

## Inputs to inspect

- Representative pages and component variants at phone, notebook and wide-screen sizes; actual content lengths and zoom behavior.
- Existing spacing scale, grids, typography rules, accessibility requirements and the user’s most frequent task.

## Workflow

1. Identify the task, reading order and the information that should be visible together. Measure the actual layout at the widths users work with.

2. Correct misalignment, disproportionate whitespace, stretched actions and unnecessary containers using the existing spacing system. Group related content without flattening hierarchy.

3. Keep long labels, empty states and real data volumes in the layout. Do not reduce text size or touch targets simply to fit more content.

4. Check small and wide viewports, keyboard focus and overflow after the change. Keep domain rules and data semantics unchanged.

## Decision points

- If information is hard to locate across pages, use navigation-ux; if the spatial hierarchy itself lacks identity, use ui-identity.
- Choose breakpoints from the point where content or controls stop working, not from a device name alone.

## Quality criteria

- Align related labels, values and actions on a stable grid. Group information by decision, then give primary and secondary content appropriate weight.
- Use available width when it improves scanning; avoid forcing an ultrawide workspace into a single narrow column without purpose.
- Reduce empty space that hides key actions, while keeping readable line lengths, comfortable controls and room for zoom and translation.
- Let long content scroll naturally. The useful target is less task-friction, not a rule that every page fits in one viewport.

## Validation and evidence

- Inspect the same content at representative narrow and wide widths and with a long or empty state; check overflow, truncation and reading order.
- Name the specific alignment or density defect corrected and record any shared component consumers inspected.

## Avoid

- Do not shrink type until a broken layout happens to fit.
- Do not apply a universal no-scroll rule or use arbitrary spacing values when the project has a working scale.

## Completion

A balanced layout supported by before/after evidence and usable content at representative sizes.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
