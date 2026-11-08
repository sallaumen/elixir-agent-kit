---
name: direct-interactions
description: "Use when a simple selection or adjustment requires excessive forms and disconnected controls."
---

# Direct Interactions

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a LiveView makes the user open a form, pick a value and submit to change one field that could be set in place: a status that needs a modal to move from "draft" to "ready", a priority or rating behind a select and a save button, a list order that requires editing a number and saving, a toggle that reloads the page; when a control looks interactive but is a decorated `<div>` with a click handler and no keyboard path; when an optimistic change shows "saved" before the server answered and does not come back on failure; or when the user asks for "inline editing" or "fewer clicks" on a repeated task.

This workflow owns one control's affordance, feedback and persistence. The journey across screens and what back does belongs to [navigation-ux](../navigation-ux/SKILL.md); results that arrive late or for the wrong record belong to [async-state](../async-state/SKILL.md); keyboard and screen-reader barriers across a whole task belong to [accessibility](../accessibility/SKILL.md); the control's size or placement at a width belongs to [responsive-layout](../responsive-layout/SKILL.md); the transition that shows a state change belongs to [motion-design](../motion-design/SKILL.md).

## Size

- **Small**: add or correct one control's pending, saved and failed feedback on a native element, with one accepted and one rejected test; skip the full control card.
- **Medium**: run the workflow as written for one control: the card, the representation, the states and the accepted and rejected tests.
- **Large**: several controls or one interaction pattern across screens; slice per control, and route shared patterns to design-system and a keyboard barrier across the task to accessibility as later slices.

## Inputs to inspect

- Start at: the template and event handlers for the control (`phx-click`, `phx-change`, `phx-submit`, `phx-value-*`) and the context function the handler calls to persist the change; then the changeset that validates it.
- The decision the user makes with this control: how many values, how often, how reversible, and what a wrong value costs (nothing, a notification, money, data).
- The round trip today: what the user sees between the click and the server's answer, how a validation error reaches them, and whether the control is held while pending (`phx-disable-with`). See [Phoenix and LiveView](../../elixir/phoenix-liveview.md).
- Keyboard, touch and screen-reader behavior of the current element: whether it is a native button, input, select or link, whether it has a name, and whether it can be reached and activated without a pointer.
- Whether another user or session can change the same value, and what happens when both save.

## Workflow

1. Write a control card: the decision, the possible values, reversibility, the cost of a wrong value, the business rule in the changeset, and the current step count from intent to persisted change. Done when a reviewer could decide from the card alone whether a direct control is warranted.

2. Choose the representation from the card: a segmented control, toggle, rating, drag order or inline edit when the values are few and the effect is clear; keep the form when the user needs comparison, explanation or several fields reviewed together. Done when the choice is written with its reason and the native element it will be built on.

3. Build it on a native element with the project's component: a real `<button>` per value, an `<input>` or `<select>` with a `<label>`, a form with `phx-change` and `phx-submit`; each value has a visible or accessible name and the selected state is expressed in the markup (`aria-pressed`, `aria-checked`, `checked`), not only in color. Done when the control is reachable and operable with the keyboard alone in the running application.

4. Define the states and their feedback: pending (control held, no fake success), saved (the server's value re-rendered), failed (previous value restored, error visible and tied to the control), and undo where the cost of a wrong value justifies it. Done when each state has a handler path and a rendered form, and the visible state after a failure equals the persisted value.

5. Keep confirmation where it is earned: a destructive, paid or hard-to-reverse value still asks, inline, before the write; reversible values do not. Done when every value on the card has a stated confirmation decision.

6. Test the accepted and rejected paths with `Phoenix.LiveViewTest`: `render_click/2` or `render_change/2` with a valid value asserts the persisted record and the rendered state; an invalid value or a stubbed failure asserts the restored value and the error; a second rapid change asserts the final state is the last accepted write. Done when the tests pass and the running application shows the same behavior.

## Decision points

- Direct control when values are few and the effect is visible on the spot; a form when the decision needs comparison, explanation or multi-field review.
- The server round trip is the default; an optimistic update only when the previous value can be restored locally and the user will understand a failed save, and never for a paid or destructive value.
- A native element first; a custom widget only when no native element expresses the control, and then with its full keyboard contract (focus, arrows where expected, `Escape`, activation).
- Reducing clicks never removes a confirmation whose consequence is destructive, paid or hard to reverse; move it inline instead.
- Two simple domain-specific controls beat one universal control with modes.

## Quality criteria

- The control communicates the actual choice (what is selected, what the alternatives are) through its element and name, not through decoration or a hidden input.
- Selected, pending, saved and failed states are visibly and programmatically distinct, and the visible state equals the persisted value once the server has answered.
- The control works with keyboard, touch and a screen reader: a name, a focus indicator, activation by `Enter` or `Space`, a target large enough on touch.
- Validation and business rules apply exactly as in the former form; a value the changeset rejects is rejected inline with the reason.
- Destructive, paid or hard-to-reverse values keep an explicit confirmation.

## Validation and evidence

- Minimum: the `Phoenix.LiveViewTest` pair for the control: one valid change asserting the persisted record and rendered state, one rejected or failed change asserting the restored value and the error.
- When turns allow: a rapid double change and a reload after the change, asserting the final persisted value is what the screen shows.
- When turns allow: the control operated with the keyboard alone in the running application, with the accessibility tree showing its role, name and selected state.
- When another session can change the same value: a second session or a stale-revision write exercised, with what the first user sees.

## Avoid

- Do not add autosave or optimistic updates to a complex or costly operation because it looks modern; the round trip is the default.
- Do not build a control on a `<div>` with handlers, express selection by color alone, or hide the current value behind an icon without a name.
- Do not suppress a confirmation to save a click when the value is destructive, paid or hard to reverse.
- Do not show "saved" from the client; render the server's value and restore the previous one on failure.
- Do not fix the journey, the layout at a width or a late result here; route them.

## Completion

A control built on a native element that expresses the choice and its selected state, with pending, saved and failed feedback tied to the persisted value, the same business rules and confirmations as before, and tests for the accepted and rejected paths. For the journey across screens use [navigation-ux](../navigation-ux/SKILL.md); for late or duplicate results use [async-state](../async-state/SKILL.md); for keyboard and announcement barriers across the task use [accessibility](../accessibility/SKILL.md); for the transition that shows the state change use [motion-design](../motion-design/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
