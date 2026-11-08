---
name: navigation-ux
description: "Use when users lose context or need unnecessary steps to complete a multi-screen task."
---

# Navigation UX

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a LiveView journey loses the user's context: a filter or selection on an index disappears after opening and closing a detail; browser back from a modal or drawer leaves the page instead of closing the overlay, or closing the overlay leaves a stale history entry; a deep link into a detail renders without the list, tenant or step it belongs to; a multi-step task (onboarding, checkout, a wizard) cannot be resumed after reload or forces re-entry of saved data; or a redirect after an action lands the user somewhere they cannot explain. Use it on every device, phone and desktop alike.

This workflow owns history, URLs, overlays that act as navigation, back behavior, deep links and the sequence of a multi-step task. A layout that fails at one width is [responsive-layout](../responsive-layout/SKILL.md); one control's affordance or feedback is [direct-interactions](../direct-interactions/SKILL.md); the hierarchy of a single screen is [ui-identity](../ui-identity/SKILL.md); results that arrive late or overwrite the current selection are [async-state](../async-state/SKILL.md); authorization of a route or tenant is [security-boundaries](../security-boundaries/SKILL.md).

## Size

- **Small**: fix one transition (one overlay classification or one piece of state moved to the URL) and walk only that path; skip the full journey map.
- **Medium**: run the workflow as written for one journey: the map, the walk at phone and desktop widths, and the LiveView test of each transition.
- **Large**: a whole journey across many steps and overlays, or several journeys; slice per step or overlay, and route deep links that cross an authorization boundary to security-boundaries as a later slice.

## Inputs to inspect

- Start at: the router (`router.ex`): the `live_session` groups, the routes of the journey and the LiveView and action each maps to; then that LiveView's `handle_params/3` for what it reads from the URL.
- How each transition is made: `push_patch`, `push_navigate`, `redirect`, plain links, and JS commands that show or hide overlays without touching the URL. See [Phoenix and LiveView](../../elixir/phoenix-liveview.md).
- Which state lives in the URL (path and query params), which in socket assigns, which in the session or database, and therefore what survives reload, back and a shared link.
- The overlays in the journey (dialogs, drawers, sheets, inline panels) and whether each represents a place (a detail, a step) or a transient local choice.
- The user's primary goal, the detours they legitimately take (compare two items, go back a step), the recovery path after an error, and the permissions of the account used to test.

## Workflow

1. Write a journey map: each step as a row with its URL, the transition that reaches it, the state the step needs, where that state lives (URL, assign, session, database), and what back does from there. Done when the map covers entry, the intermediate decisions, cancellation, completion and the return to where the user started.

2. Walk the journey in the running application with real data, following the map: open the detail, close it, press back with the overlay open, reload mid-step, open a deep link to the detail in a fresh session. Record for each row what the user actually sees. Done when every row has an observed result and the first point where context is lost is marked.

3. Classify each overlay: a place gets a URL and a history entry (`push_patch` with its params) and back closes it to the underlying context; a transient choice gets no history entry and closes on `Escape` or its own control. Done when every overlay in the map has one classification and the code matches it.

4. Move the state that must survive to where it survives: filters and selection into URL params read in `handle_params/3`, wizard progress into the database or session keyed by the task, unsaved work preserved according to the product rule. Moving wizard progress into the database may need a schema change, which is a persisted-data change: stop and ask before writing the migration. Done when reload and a deep link reconstruct the step from the map's state column alone.

5. Remove steps that do not inform a decision and keep confirmations whose consequence is destructive, paid or hard to reverse; make the next action and the way back visible on each step. Done when no row in the map is crossed without a decision and every row names its exit.

6. Re-walk the map at a phone width and a desktop width: primary route, deep link, back and forward, reload, one recoverable error. Done when every row's observed result matches its intended result, or the mismatch is listed as unverified.

## Decision points

- A place has a URL; a choice does not. Decide per overlay, never with a global history interceptor or a reflex history entry on every open.
- State the user would expect in a shared link lives in the URL; personal transient state lives in assigns; state that must outlive the socket lives in the database or session.
- `push_patch` for a change within the same LiveView, `push_navigate` when the process must restart, `redirect` only when leaving LiveView; a remount that drops the user's work is a finding.
- Keep exploratory backtracking and comparisons; remove a step only when it does not help a decision.
- A deep link that cannot reconstruct its context redirects to the nearest context it can, with a message, rather than rendering a partial page.

## Quality criteria

- The next meaningful action and the way back are discoverable at every step without hiding the context the user came from.
- Reload, back, forward and a direct link reconstruct the step from URL, session or database state; closing a navigable overlay restores the underlying context, and back never leaves the application unexpectedly.
- Unavailable or partial information is explained and every error has a route to recover; no dead ends.
- Labels and destinations match what the action does, including destructive or paid consequences; confirmations exist exactly where those consequences are.
- The journey behaves the same at the phone and desktop widths, with differences named.

## Validation and evidence

- Minimum: the journey map with observed results, and a `Phoenix.LiveViewTest` walk of the primary route asserting the URL after each transition (`assert_patch/2`, `assert_redirect/2`) and the rendered context after a deep link to the detail.
- When turns allow: back with an overlay open, closing the overlay, reload mid-step and a deep link, in the running application at a phone width and a desktop width, labeled emulated or observed on a device.
- When turns allow: a reconnect (stop the view process and mount it again) showing the step and selection survive.
- When the journey crosses a permission boundary: the walk repeated with a lower-privilege account.

## Avoid

- Do not replace an exploratory journey with a forced linear wizard, or add a step whose only purpose is to confirm a reversible choice.
- Do not judge the flow from the route list or a happy-path screenshot; walk it with real state.
- Do not create a history trap: an overlay whose back leaves the page, a step the user cannot return from, or a global interceptor installed to fix one overlay.
- Do not keep filters, selection or wizard progress only in socket assigns when the user expects them after reload or in a shared link.
- Do not fix a width-dependent layout or a single control's feedback here; route them.

## Completion

A journey map in which every step has a URL or a justified absence of one, overlays are classified as places or choices, state lives where it survives reload and deep links, and the walk at phone and desktop widths matches the map, with unverified paths named. For a layout that fails at a width use [responsive-layout](../responsive-layout/SKILL.md); for a single control's feedback use [direct-interactions](../direct-interactions/SKILL.md); for late or duplicate results use [async-state](../async-state/SKILL.md); for route and tenant authorization use [security-boundaries](../security-boundaries/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
