---
name: accessibility
description: "Use when controls, forms, dialogs or asynchronous changes may exclude keyboard or assistive-technology users."
---

# Accessibility

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a control works with a mouse but not a keyboard, when errors or live updates appear without being announced, when a dialog opens or closes and focus goes nowhere, when contrast or target size is in doubt, or when a feature is declared accessible without evidence. Use it for a new interactive surface as well as for an audit.

Target WCAG 2.2 level AA unless the project names another level. A scanner result, an `aria-*` attribute or a screenshot is not evidence; a keyboard path through the real task is.

## Inputs to inspect

- Start at: the rendered route's accessibility tree (the browser's accessibility tree, from devtools or a headless run): landmarks, heading order, accessible names, roles, current focus.
- The task the user must complete, its interactive states (idle, loading, invalid, error, success, disabled) and the rendered DOM in each state, not the template source alone.
- Keyboard path: tab order, activation keys, `Escape`, arrow keys inside composite widgets, what happens to focus after each change.
- Contrast on the real background, text zoom to 200%, reflow at 320 CSS pixels, target size of controls that matter on touch.
- For LiveView: how a patch changes the DOM (`phx-update`, streams), whether live regions survive it, and where focus lands after `push_patch`, a flash or a form error. See [Phoenix and LiveView](../../ELIXIR.md#phoenix-and-liveview).

## Workflow

1. Name the task and the states to cover. Write them down before testing; they are the scope you report against.

2. Walk the task with the keyboard only, in the running application, for each state. Record where focus is after every step, what is announced, and the first point the task cannot continue. Stop and fix that blocker before cosmetic findings.

3. Read the accessibility tree at the problematic states. Compare names, roles and relationships to what a sighted user sees: an icon button needs a name; an error needs to be programmatically tied to its field (`aria-describedby`) and announced (`aria-live` or focus moved to it); a dialog needs a role, a name, trapped focus and a return point on close.

4. Fix at the source of the semantics: a real `<button>`, `<label for>`, native `<dialog>` or the project's dialog component, headings in order. Add ARIA only where no native element expresses the role, and never in a way that contradicts the element.

5. For asynchronous changes decide what must be announced (a result, an error, a progress end) and what must stay silent (every poll, every stream insert). Put the announcement in a region that the next patch does not replace.

6. Check contrast, zoom and target size on the changed states. Run an automated scanner last, to catch what the manual pass missed; treat its output as candidates to verify, not as the result.

7. Report the states covered, the barriers fixed, the barriers left, and the assistive technologies and devices not exercised.

## Decision points

- A barrier that stops the task outranks any number of cosmetic findings; fix it first and say so.
- Native semantics first; a custom widget is acceptable only when the native element cannot do the job, and then its full keyboard contract (focus, arrows, Escape, Home/End where expected) is part of the work.
- Announce results and errors; do not announce refreshes. If a region is replaced by every patch, move the announcement out of it.
- When focus has nowhere good to go after a change, send it to the heading or the first interactive element of the new context, not to the top of the page.
- When the standard and the project rules disagree, follow the project rule and name the gap; do not quietly lower the target.

## Quality criteria

- Every interactive element reachable with the keyboard has a visible focus indicator and an accessible name that matches its visible label.
- Each state of the task has correct heading and landmark structure; a screen reader user can tell where they are and what changed.
- Form errors are tied to their fields and announced once; a dialog traps focus while open and restores it when closed.
- Contrast meets the target on the real background; information is never carried by color, animation or icon alone; text zoom and reflow keep the task usable.
- Live updates announce what a person needs and nothing else; reduced motion is honored where motion carries state.

## Validation and evidence

- Minimum: a keyboard-only transcript of the task through at least one error state and one asynchronous completion: step, focus location, announcement.
- When turns allow: the accessibility tree (or snapshot) at the fixed states, showing names, roles and relationships.
- When turns allow: contrast ratios for the changed text and controls, and the zoom or reflow check.
- When turns allow: the list of what was not exercised: screen readers, browsers, touch devices, physical devices.

## Avoid

- Do not declare a surface accessible because a scanner passed or an `aria-label` exists.
- Do not add ARIA roles or states that contradict the native element, and do not replace a native control with a `<div>` plus handlers.
- Do not announce every patch, poll or stream update; a chatty live region is as exclusionary as a silent one.
- Do not trap focus outside a dialog or leave it on a removed element.
- Do not fix the visible button and leave the same operation unreachable in the keyboard path, the mobile layout or the fallback render.

## Completion

The task is completable with the keyboard alone through its error and asynchronous states, with evidence from the running application and a bounded list of what was not exercised. For layout and reading order use [layout-density](../layout-density/SKILL.md); for a journey across screens use [navigation-ux](../navigation-ux/SKILL.md); for a canvas or game scene add the external skill named in the [routing guide](../../ROUTING.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
