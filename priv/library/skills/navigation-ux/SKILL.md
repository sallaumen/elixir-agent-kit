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
- A primary user goal, likely detours, recovery path and representative data or account permissions.

## Workflow

1. Walk a complete user journey, including entry, intermediate decisions, cancellation, completion and return. Use actual application state rather than a screenshot-only interpretation.

2. Locate lost filters, confusing labels, redundant forms, unexpected navigation and missing recovery. Explain how each problem affects task completion.

3. Simplify the flow while retaining business constraints and meaningful confirmations. Preserve selected entities and unsaved work according to the product rules.

4. Verify browser back/forward, direct links, refresh and error recovery where relevant. Confirm the user can tell what happened and what to do next.

## Decision points

- If the defect is within one control, use direct-interactions; if mobile browser history is broken, pair with responsive-mobile only for that distinct risk.
- Keep exploratory comparisons and legitimate backtracking; remove steps only when they do not help a decision.

## Quality criteria

- Make the next meaningful action discoverable at each step without hiding context or creating an endless wizard.
- Preserve state when returning, reloading or following a direct link, according to the application’s actual navigation contract.
- Explain unavailable or partial information and provide a route to recover after errors rather than leaving a dead end.
- Ensure labels, destinations and confirmation states match what the action really does, including destructive or paid consequences.

## Validation and evidence

- Walk the primary route, a direct deep link, back/forward, reload and one recoverable error in the running product.
- Report a journey map with where context was lost, what changed and which paths remain unverified.

## Avoid

- Do not replace a useful exploratory journey with a forced linear wizard.
- Do not judge the flow solely by a static route list or a happy-path screenshot.

## Completion

A complete, validated journey with fewer avoidable steps and preserved context. A single visual composition issue belongs to ui-identity or layout-density.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
