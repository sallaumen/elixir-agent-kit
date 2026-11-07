---
name: design-system
description: "Use when teams repeat interface mistakes or create incompatible component and token variations."
---

# Design System

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a Phoenix project has three button styles because each LiveView restyles the core component inline; when a new screen cannot be built without guessing which spacing, color or type value is "ours"; when the design guidance (DESIGN.md or its equivalent) describes a system the templates do not follow; when a shared component grows a flag per caller (`variant`, `compact`, `inverted`, `legacy`) and nobody knows which combinations exist; when a fix made on one screen must be repeated on others because the rule has no owner; or when the user asks to "set up a design system" or "make the components consistent".

This workflow owns tokens, shared components, the rules that hold across screens and the guidance that names them. One screen's hierarchy and identity belong to [ui-identity](../ui-identity/SKILL.md): fix the screen there, promote the rule here. Spacing within one screen belongs to [layout-density](../layout-density/SKILL.md); a shared component's keyboard and announcement contract is checked with [accessibility](../accessibility/SKILL.md); its motion with [motion-design](../motion-design/SKILL.md); duplicated behavior beyond the interface with [code-consolidation](../code-consolidation/SKILL.md).

## Inputs to inspect

- Start at: the project's design guidance and the component module (`core_components.ex` or the project's equivalent), then a grep across `lib/*_web` for the component names and for the raw utility classes they are meant to replace.
- The token sources: the CSS configuration (theme, scale, color roles), any CSS variables, and the templates that use raw values instead of them.
- Three representative pages (a list, a form, a detail or dashboard) rendered in the running application, to see which inconsistencies actually repeat and which differences are intentional.
- The shared components' APIs: attributes and slots (`attr/3`, `slot/2`), variants, states (default, hover, focus, disabled, error, selected, loading), themes and the consumers of each. See [Phoenix and LiveView](../../elixir/phoenix-liveview.md).
- The accessibility constraints the components must keep (names, focus, contrast) and the project's test setup for components.

## Workflow

1. Write an inventory table: each token or component, where it is defined, how many consumers use it, how many bypass it with raw values or inline overrides, and whether each divergence is intentional (product meaning) or accidental. Done when every shared component and every color, spacing and type value seen on the three pages has a row.

2. Choose one canonical source per rule and component from the inventory: the existing token or component where it already serves most consumers, a new one only where a repeated decision has no owner. Done when every row names its canonical source and the intentional exceptions are listed separately with their reason.

3. Consolidate the accidental divergences: consumers call the canonical component or token; overrides that encode a real variant become a named attribute with a bounded set of values; flags with no remaining caller are removed. Done when a grep for the raw values and the removed flags returns only the listed exceptions.

4. Document each component and token by purpose next to its implementation: the role it plays (hierarchy, density, color role, interaction state), its variants, its states, its keyboard and announcement contract, and one existing screen that uses it. Make the project instructions point to this guidance instead of restating it. Done when a new screen can be composed from the guidance without guessing.

5. Render every consumer of each changed component in its default, error, selected, disabled and loading states, and run the project's component or LiveView tests. Done when every consumer renders without a new defect, or the ones not checked are named.

6. Record the unresolved migration work: consumers still on raw values, exceptions awaiting a product decision, tokens that still need a value. Done when the list is in the guidance or the handoff with an owner for each item.

## Decision points

- A one-off style stays local while reuse is speculative; it becomes a token or component when the same decision appears on a second screen.
- A component gains a variant when the difference has product meaning and a bounded set of values; it never gains a free-form class or style attribute that lets callers do anything.
- When the guidance and the implementation disagree, the shipped implementation is the current truth; the guidance is corrected or the implementation migrated, and the choice is recorded, never silently assumed.
- Principles are described by purpose (hierarchy, density, type role, color role, motion, state), not by a fixed palette or a ban list copied from elsewhere.
- A single screen's composition problem is routed to [ui-identity](../ui-identity/SKILL.md); this workflow does not redesign screens.

## Quality criteria

- Every token and component has one canonical source, a purpose, named variants and states, and one real consumer cited as the example.
- Accidental divergences are gone from the consumers; the remaining exceptions are listed with their reason.
- Shared components keep their accessibility contract (name, focus, contrast, keyboard) across every variant and state.
- The guidance matches the implementation, and the project instructions point to it instead of duplicating it.
- Every changed component's consumers were rendered, or the unchecked ones are named in the migration list.

## Validation and evidence

- Minimum: the inventory table before and after, plus a grep showing the raw values and removed flags appear only in the listed exceptions.
- When turns allow: each changed component rendered on its consumers in the default, error, selected, disabled and loading states, in the running application or the project's component tests.
- When turns allow: the accessibility tree of one changed component per variant, showing name, role and state survived the consolidation.
- When the project has a component test suite: the suite run green after the change.

## Avoid

- Do not import blanket bans on fonts, cards, gradients or motion from another design source; describe purpose instead.
- Do not declare the guidance authoritative when the implementation disagrees; reconcile and record.
- Do not add a free-form style escape hatch or a flag per caller to a shared component; name the variant or keep the style local.
- Do not redesign screens from here; fix one screen in [ui-identity](../ui-identity/SKILL.md) and promote the rule.
- Do not leave a migration half done without a written list of what remains and who owns it.

## Completion

One canonical source per token and component, consumers consolidated onto them with exceptions listed, guidance written by purpose with a real example per rule, every changed consumer rendered, and the remaining migration recorded. For a single screen's hierarchy use [ui-identity](../ui-identity/SKILL.md); for spacing within a screen use [layout-density](../layout-density/SKILL.md); for a component's keyboard and announcement contract use [accessibility](../accessibility/SKILL.md); for its motion use [motion-design](../motion-design/SKILL.md); for duplicated code beyond the interface use [code-consolidation](../code-consolidation/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
