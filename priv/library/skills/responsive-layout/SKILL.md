---
name: responsive-layout
description: "Use when a layout breaks, overflows or hides actions across phone, notebook and wide screens, or touch targets and reach fail on a phone."
---

# Responsive Layout

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when content overflows or truncates at some width, when a wide screen collapses into one narrow column, when primary actions sit under unrelated blocks or out of thumb reach on a phone, when sticky elements or the virtual keyboard cover controls, or when a composition designed for one width is being asked to work at others.

Browser history, back-button behavior and overlays that act as navigation belong to [navigation-ux](../navigation-ux/SKILL.md), on every device.

## Inputs to inspect

- The widths the project supports and the ones users actually use; the existing breakpoints, spacing scale and container rules.
- The task's primary controls and the content that must stay visible together at each width; real content lengths, empty states and long names.
- Touch targets, hover-only affordances, sticky headers and footers, and what the virtual keyboard covers on a phone.
- Zoom to 200% and text scaling; orientation changes where they matter for the product.
- How the layout is composed (CSS grid, flex, utility classes, components) and which shared components other pages consume.

## Workflow

1. Declare the viewport matrix for this task: at least one phone width, one notebook width and the widest the product supports, with real data. Write it down; it is the scope you report against.

2. Exercise the task at each width with the keyboard and with pointer input. Record overflow, truncation, unreachable or hidden controls, hover-only affordances, and anything the sticky elements or the keyboard cover.

3. Choose breakpoints where the content or the controls stop working, not from device names. Change composition only where a width needs it; reuse the project's spacing scale, grid and components rather than new arbitrary values.

4. Keep primary controls reachable and named on touch: visible labels or accessible names, targets large enough for a thumb, no action that only hover reveals.

5. On wide screens use the space for comparison and task context while keeping a readable measure; do not force an ultrawide into a single narrow column without a reason, and do not stretch controls to fill it.

6. Re-run the matrix after the change, including a long or empty state and zoom, and name what was emulated versus observed on a physical device.

## Decision points

- Breakpoints come from the point where content or interaction fails, not from a device list.
- A layout change is justified by a width where the current composition stops working; otherwise keep one composition.
- Hover is an enhancement, never the only path to an action.
- Shrinking type or removing scrolling to make a layout "fit" is a defect, not a fix.
- When the defect is one control's interaction rather than the layout, route to [direct-interactions](../direct-interactions/SKILL.md).

## Quality criteria

- The task is usable at every width in the declared matrix with real content, including long names and empty states; nothing overflows, truncates silently or hides a primary control.
- Touch targets and reach work on the phone widths without hover; sticky elements and the keyboard never cover the control the user needs next.
- Wide screens show more context, not larger chrome; line length stays readable.
- Zoom and text scaling reflow without loss; orientation changes keep the task usable where they matter.
- Shared component consumers inspected after a change to a shared component.

## Validation and evidence

- The viewport matrix with a screenshot or snapshot per width for the changed states, labeled emulated or physical device.
- A keyboard and touch-equivalent pass of the primary action at the phone width.
- The overflow, zoom and long-content checks, and the shared components changed with their consumers.

## Avoid

- Do not optimize for a single fixed phone width or declare device coverage from a resized screenshot.
- Do not shrink type, remove scrolling or hide actions to make a layout fit.
- Do not add a breakpoint per device name or a new spacing value when the project has a scale.
- Do not fix navigation or history here; route it to navigation-ux.

## Completion

A declared viewport matrix in which the task works with real content, touch and keyboard, with unsupported cases named. For spacing and density within one width use [layout-density](../layout-density/SKILL.md); for history, back and overlays use [navigation-ux](../navigation-ux/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
