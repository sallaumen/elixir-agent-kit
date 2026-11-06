---
name: navigation-ux
description: "Use when users lose context or need unnecessary steps to complete a multi-screen task."
---

# Navigation UX

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when users lose context or need unnecessary steps to complete a multi-screen task.

## Inputs to inspect

- Entry routes, links, search, notifications, back/forward behavior, deep links, forms and existing journey documentation.
- How overlays (dialogs, drawers, sheets) relate to the URL and history on every device: which ones represent navigation and which are transient local choices, and how `push_patch`, `push_navigate` and redirects are used. See [Phoenix and LiveView](../../ELIXIR.md#phoenix-and-liveview).
- A primary user goal, likely detours, recovery path and representative data or account permissions.

## Workflow

1. Walk a complete user journey, including entry, intermediate decisions, cancellation, completion and return. Use actual application state rather than a screenshot-only interpretation.

2. Locate lost filters, confusing labels, redundant forms, unexpected navigation and missing recovery. Explain how each problem affects task completion.

3. Simplify the flow while retaining business constraints and meaningful confirmations. Preserve selected entities and unsaved work according to the product rules.

4. Verify browser back/forward, direct links, refresh and error recovery where relevant, on a phone width as well as desktop. Reproduce back with an overlay open, closing an overlay, and a deep link into a detail before changing history handling. Confirm the user can tell what happened and what to do next.

## Decision points

- If the defect is within one control, use direct-interactions; if the layout itself breaks at a width, use responsive-layout.
- When an overlay represents navigation (a detail, a step), the URL and history represent it and back closes it to the underlying context; when it is a transient local choice, do not add a history entry by reflex. Never install a global history interceptor to fix one overlay.
- Keep exploratory comparisons and legitimate backtracking; remove steps only when they do not help a decision.

## Quality criteria

- Make the next meaningful action discoverable at each step without hiding context or creating an endless wizard.
- Preserve state when returning, reloading or following a direct link, according to the application’s actual navigation contract; closing a navigable overlay restores the underlying context and back never escapes the application unexpectedly.
- Explain unavailable or partial information and provide a route to recover after errors rather than leaving a dead end.
- Ensure labels, destinations and confirmation states match what the action really does, including destructive or paid consequences.

## Validation and evidence

- Walk the primary route, a direct deep link, back/forward, reload and one recoverable error in the running product, at a phone width and a desktop width; state whether phone behavior was emulated or observed on a device.
- Report a journey map with where context was lost, what changed and which paths remain unverified.

## Avoid

- Do not replace a useful exploratory journey with a forced linear wizard.
- Do not judge the flow solely by a static route list or a happy-path screenshot.
- Do not create a history trap: an overlay whose back button leaves the page, or an entry the user cannot return from.

## Completion

A complete, validated journey with fewer avoidable steps and preserved context. A single visual composition issue belongs to ui-identity or layout-density.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
