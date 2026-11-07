---
name: commercial-eligibility
description: "Use when an offering is presented without evidence that its exact variant and destination are supported."
---

# Commercial Eligibility

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when the catalog shows a size or color that the supplier's current data does not list for that product; when a listing is published to a country the fulfillment route cannot ship to and the order fails after payment; when the storefront offers every variant of a parent product because the parent is "available"; when a supplier changed its catalog and offers stored months ago still claim support with no date; or when the UI, the publication job and the order path each decide eligibility with their own query and disagree.

This workflow owns the evidence that an exact variant and destination are supported before the offering is presented. Whether the supplier integration is connected and its credentials valid belongs to [integration-setup](../integration-setup/SKILL.md); which revision of the product an artifact belongs to is [revision-lineage](../revision-lineage/SKILL.md); the supplier request itself is [provider-calls](../provider-calls/SKILL.md).

## Inputs to inspect

- Start at: the function that decides whether an offer can be shown or sold (`grep -rn "eligib\|available?\|can_sell\|supported" lib/`) and the one offer whose support is in doubt.
- The identity of the offer: product, exact variant (size, color, material, artwork), supplier identifier for that variant, fulfillment route, and destination (country, channel, account).
- The supplier's authoritative data for that combination: endpoint or export, the fields that say supported, the field that says when, and how the project stores and refreshes it. See [HTTP clients and provider APIs](../../elixir/http-clients.md).
- Every consumer of the decision: catalog, variant selection, pricing, publication job, checkout and fulfillment, and which query each uses today.
- Stored offers and their evidence columns: source, checked-at date, and what happens when the supplier data changes. See [Ecto and migrations](../../elixir/ecto.md) and [Oban](../../elixir/oban.md) for refresh jobs.

## Workflow

1. Write the eligibility table for the offers in scope: one row per combination with columns for variant, destination (country, channel, account), fulfillment route, source of truth (the supplier endpoint or export), the evidence found there, the date checked, and the resulting state (supported, unsupported, unknown, stale). Done when the doubted offer and one sibling variant each have a row and no row says supported without evidence and a date.

2. Trace the decision through each consumer: where the catalog, selection, pricing, publication and order paths read eligibility, and which of them substitutes a default when the data is missing. Done when every consumer is mapped to a query or to "assumes supported".

3. Define one domain rule in the context that returns supported, unsupported, unknown or stale with the evidence and date, keyed by exact variant, route and destination. Done when the rule exists, is tested, and parent-level availability cannot make it return supported for a child variant.

4. Make every consumer call that rule or a documented derivation of it; presentation layers render unknown and stale as such and never as available. Done when the catalog, publication and order paths produce the same answer for the eligibility table rows in a test.

5. Persist the evidence with the offer: supplier identifier, source, date checked, and the rule version, so a later supplier change marks the offer stale rather than rewriting it; schedule the refresh and define staleness. Done when an offer older than the staleness window renders as stale and a block records its reason.

6. Test one supported combination, an unsupported sibling variant, a missing-evidence case and a destination or account mismatch through catalog, publication and a fixture order, then run the project gate. Done when all four give consistent results in every consumer and the tests pass.

## Decision points

- A supported parent product does not make any color, size, artwork or country supported; evidence is per exact combination.
- Supported, unsupported, unknown and stale are four states; the UI shows unknown and stale and never promotes them to available.
- One rule in the domain decides; catalog, publication and order consume it, or consume a derivation that is documented and tested against it.
- Eligibility may differ by account and fulfillment route; the key includes both.
- Evidence carries its source and date; a claim without a date is unknown.
- A marketplace image, a cached listing or a previous sale is not evidence of current supplier support.

## Quality criteria

- A single domain rule answers whether the exact offer can be produced, sold and fulfilled at its destination, and its result carries evidence and a date.
- Catalog, selection, pricing, publication and order paths consume that rule, and the test suite proves they agree on the eligibility table rows.
- Identifiers and evidence survive revisions and supplier refreshes; an older offer becomes stale, never silently rewritten.
- The UI states why a combination is unavailable and offers no purchase the backend will reject.
- Unknown and stale are visible states with a refresh path, and a block records its reason.

## Validation and evidence

- Minimum: a test that feeds the domain rule a supported combination, its unsupported sibling variant, a missing-evidence case and a destination mismatch, asserting the four states with their evidence and date, and that a supported parent does not make the sibling supported.
- When turns allow: the same four cases through the catalog render, the publication job and a fixture order, asserting consistent results.
- When turns allow: a stored offer older than the staleness window rendering as stale after a supplier refresh changes its data.
- When the session has supplier access: the eligibility table rows compared against the supplier's current data, with the date; otherwise state that the rows were built from stored data only.

## Avoid

- Do not infer eligibility from a generic item's presence or from the parent product.
- Do not treat a marketplace image, a cached listing or a past sale as evidence of a supplier link.
- Do not let a template or a publication job fall back to "available" when the data is missing.
- Do not make a real purchase or a public publication to test eligibility; use fixtures and sandbox routes.
- Do not decide here whether the supplier integration is configured; that is [integration-setup](../integration-setup/SKILL.md).

## Completion

An eligibility table with evidence and date per combination, one domain rule returning supported, unsupported, unknown or stale, every consumer reading it, evidence persisted with the offer so supplier changes mark it stale, and tests that prove catalog, publication and order agree. For the integration's readiness use [integration-setup](../integration-setup/SKILL.md); for which revision the offer's artifacts belong to use [revision-lineage](../revision-lineage/SKILL.md); for the supplier request use [provider-calls](../provider-calls/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
