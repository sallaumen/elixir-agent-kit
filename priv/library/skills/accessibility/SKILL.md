---
name: accessibility
description: "Use when controls, forms, dialogs or asynchronous changes may exclude keyboard or assistive-technology users."
---

# Accessibility

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when controls, forms, dialogs or asynchronous changes may exclude keyboard or assistive-technology users.

## Inputs to inspect

- The affected task, applicable project accessibility rules, interactive states and the actual rendered structure.
- Keyboard path, accessible names, focus behavior, zoom/reflow, contrast and any dynamic announcement mechanism.

## Workflow

1. Define the flow and applicable accessibility criteria before testing. Inspect semantic structure, accessible names, labels, focus order and keyboard operation.

2. Exercise dialogs, error messages, live updates and loading states. Check contrast, zoom, text wrapping and target sizes in the actual presentation.

3. Use automated tools to find candidates, then verify behavior manually. Prefer native semantics and repair the underlying interaction rather than adding misleading ARIA.

4. Document the tested scope, confirmed barriers and remaining limits. A limited sample or scanner result does not establish whole-product WCAG compliance.

## Decision points

- Prioritize an obstacle that blocks the task before cosmetic audit findings; verify the applicable standard rather than importing a checklist verbatim.
- Use native semantics where they fit; when a custom widget is necessary, check its complete interaction contract.

## Quality criteria

- Provide correct heading/landmark order, labels and programmatic relationships that match the visible task.
- Maintain a visible focus indicator and meaningful keyboard order through dialogs, errors, validation and navigation.
- Check contrast on the real background and ensure information is not conveyed only by color, animation or iconography.
- Announce relevant asynchronous results without repeating every refresh; support zoom, reflow and reduced motion according to the project’s target.

## Validation and evidence

- Traverse the changed task with keyboard and inspect the accessibility tree or equivalent platform semantics, including an error state.
- Report the actual barriers fixed and what assistive technology or device combinations were not exercised.

## Avoid

- Do not certify accessibility from one automated scanner or color ratio alone.
- Do not replace missing semantics with ARIA attributes that contradict native controls.

## Completion

Concrete barriers fixed or reported with reproducible evidence and clearly bounded coverage.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
