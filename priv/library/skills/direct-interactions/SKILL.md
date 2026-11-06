---
name: direct-interactions
description: "Use when a simple selection or adjustment requires excessive forms and disconnected controls."
---

# Direct Interactions

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a simple selection or adjustment requires excessive forms and disconnected controls.

## Inputs to inspect

- The repeated task, current form or control, possible values, reversibility, validation rules and how the server saves state.
- Keyboard, touch and screen-reader behavior of current components, plus consequences of a wrong selection.

## Workflow

1. Identify the user's decision and the business rules behind it. Consider whether a direct representation such as selection, rating, ordering or inline editing improves comprehension.

2. Keep labels, keyboard operation, focus, screen-reader semantics and non-pointer alternatives available. Do not hide validation or destructive consequences behind a gesture.

3. Define pending, success, failure and undo behavior where applicable. Optimistic UI must reconcile with persistence and recover accurately on failure.

4. Test a real completion path and a rejected or failed update. Prefer existing controls when a novel interaction has no demonstrated benefit.

## Decision points

- Use direct selection when choices are few and the effect is clear; retain a full form when the user needs comparison, explanation or multi-field review.
- Choose optimistic updates only if the previous state can be restored and the user can understand a failed save.

## Quality criteria

- Use a representation that communicates the actual choice, such as a segmented control or thumbnail, without turning decoration into a hidden input.
- Give selected, pending, saved and failed states distinct feedback, and keep server truth synchronized with the visible state.
- Preserve accessible names, focus order, keyboard activation and sufficient targets for touch.
- Keep destructive, paid or hard-to-reverse actions explicit; reducing clicks is not a reason to suppress meaningful confirmation.

## Validation and evidence

- Test rapid changes, save failure, reload and a second device/session if stale state is a real risk.
- Describe which steps were removed, which decision stayed visible and how failed writes recover.

## Avoid

- Do not add autosave to a complex operation merely because it looks modern.
- Do not build a universal control with many modes when two simple domain-specific controls are clearer.

## Completion

A simpler interaction with equivalent rules, accessibility and reliable persistence.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
