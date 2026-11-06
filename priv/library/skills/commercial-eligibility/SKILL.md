---
name: commercial-eligibility
description: "Use when an offering is presented without evidence that its exact variant and destination are supported."
---

# Commercial Eligibility

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when an offering is presented without evidence that its exact variant and destination are supported.

## Inputs to inspect

- Product, exact variant, supplier SKU/method, destination country/channel and the evidence linking each combination.
- Publication and purchase contracts, account/tenant scope, unknown states and older stored offers.

## Workflow

1. Identify the exact product, variant, supplier, market and destination combination. Locate the authoritative provider data and record when it was checked.

2. Separate supported, unsupported, unknown and stale eligibility. A general provider capability does not prove support for a specific combination.

3. Trace eligibility through catalog, selection, pricing and fulfillment. Prevent presentation layers from replacing unknown data with an optimistic default.

4. Test unsupported and expired information alongside a supported combination. Preserve the evidence and reason for a block; avoid guarantees beyond the provider's confirmed contract.

## Decision points

- An available parent product does not make every color, size, artwork or country eligible.
- Represent unknown, blocked and verified distinctly; eligibility may differ by account and fulfillment route.

## Quality criteria

- A single domain rule answers whether the exact offer can be produced, sold and fulfilled at its destination.
- Registration, catalog, publication and order paths consume the same decision or explicitly documented variants.
- Identifiers and source evidence survive revisions so a later supplier change cannot silently rewrite an older offer.
- The UI exposes why a combination is unavailable without suggesting a purchase that the backend will reject.

## Validation and evidence

- Test one eligible combination, an unavailable sibling variant, missing evidence and a destination/account mismatch.
- Trace a displayed offer through publication or a safe fixture purchase to show the same eligibility result.

## Avoid

- Do not infer eligibility from a generic item’s presence.
- Do not treat a marketplace image as evidence of a supplier link.

## Completion

Eligibility decisions backed by scoped, dated evidence and consistently enforced across the purchase or production flow.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
