---
name: responsive-mobile
description: "Use when mobile navigation, browser history or layouts fail across phone and wide-screen sizes."
---

# Responsive Mobile

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when mobile navigation, browser history or layouts fail across phone and wide-screen sizes.

## Inputs to inspect

- Supported device widths, actual touch tasks, dialogs or drawers, route/history implementation, desktop compositions and project UI rules.
- Direct links, browser back/forward behavior, long text, zoom and orientation cases that matter for this product.

## Workflow

1. Separate navigation defects from layout defects. Reproduce back-button behavior, modal history, deep links and refresh on the relevant flow.

2. Inspect phone, notebook and wide-screen layouts with meaningful content. Check overflow, sticky elements, virtual keyboards and reachable actions.

3. Preserve navigation state and remove phantom history entries only after understanding how routes and overlays are modeled. Adapt composition using existing breakpoints and design conventions.

4. Verify mouse, touch-equivalent and keyboard interactions. State whether evidence comes from emulation or a physical device; do not claim device coverage from a resized screenshot.

## Decision points

- When a dialog represents navigation, decide whether URL/history must represent it; when it is a transient local choice, do not add history by reflex.
- Use a layout change where content or interaction requires one; do not assume every screen needs the same breakpoints or gestures.

## Quality criteria

- Keep primary controls reachable and named on touch screens without relying on hover or a universal edge-swipe gesture.
- Closing a navigable overlay should restore the underlying context; direct detail links should open correctly and browser back should not escape unexpectedly.
- On notebook and wide displays, use space for comparison and task context while preserving readable measure and coherent hierarchy.
- Avoid hiding essential actions below unrelated blocks or making zoom, translation and long content overflow.

## Validation and evidence

- Exercise phone, notebook and wide views chosen for the project; test modal open/close, back/forward, reload and deep link where applicable.
- Capture actual viewport sizes, interaction observations and any untested device behavior; screenshots alone cover layout, not browser history.

## Avoid

- Do not install global history interceptors to fix one overlay.
- Do not optimize only a fixed 390-pixel viewport or remove scrolling at the cost of legibility.

## Completion

Correct navigation and usable layouts across a declared viewport/device matrix, with unsupported cases identified.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
