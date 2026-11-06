---
name: design-system
description: "Use when teams repeat interface mistakes or create incompatible component and token variations."
---

# Design System

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when teams repeat interface mistakes or create incompatible component and token variations.

## Inputs to inspect

- Current DESIGN.md, tokens, components, representative pages and the inconsistencies teams actually repeat.
- The product’s identity, consuming component APIs, states, themes and accessibility constraints.

## Workflow

1. Inventory the components, tokens and documentation actually used by the project. Distinguish intentional exceptions from accidental divergence.

2. Choose a canonical source for each rule and component. Consolidate repeated patterns without forcing distinct product needs into one abstraction.

3. Document behavior, states, accessibility and responsive expectations alongside visual values. Make project instructions point to canonical guidance rather than duplicating it.

4. Validate representative consumers after changing a shared component. Provide examples that exist and name unresolved migration work.

## Decision points

- Keep a one-off style local when reuse is speculative; create or refine a shared token/component when a repeated decision needs a stable owner.
- If the issue is a single screen’s composition, route to ui-identity rather than rebuilding the entire system.

## Quality criteria

- Describe principles by purpose: hierarchy, density, typography, color role, motion, imagery and interaction states, not a fashionable fixed palette.
- Tie guidance to existing implementation and a real example so a future agent can choose correctly without guessing.
- Give reusable components clear variants and state contracts; avoid a single component with many unrelated flags.
- Record exceptions where product meaning requires them, and keep docs, tokens and consumers aligned as the system evolves.

## Validation and evidence

- Apply a changed rule to representative pages and verify a component’s default, error, selected, disabled and responsive states as relevant.
- Show where the rule lives, which consumers changed and what evidence demonstrates improved consistency.

## Avoid

- Do not import blanket bans on fonts, cards, gradients or motion from another design skill.
- Do not declare a DESIGN.md authoritative when the implementation and product direction disagree.

## Completion

A usable design system and operational guidance with tested consumers, not a document disconnected from implementation.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
