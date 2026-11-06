---
name: metrics-costs
description: "Use when totals, model costs or operational metrics have unclear scope, origin or meaning."
---

# Metrics Costs

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when totals, model costs or operational metrics have unclear scope, origin or meaning.

## Inputs to inspect

- The decision each metric supports, source records, currency/unit, timezone, period, aggregation dimensions and completeness markers.
- Retries, duplicated events, provider prices, caches and reconciliation examples.

## Workflow

1. Define each metric's unit, population, time window, source and aggregation rule. Trace displayed totals back to underlying events or provider records.

2. Distinguish measured, estimated, unavailable and zero. Keep model usage, provider billing and application operations separate unless their relationship is explicitly defined.

3. Check duplicates, currency or unit conversion, partial periods and delayed records. Reconcile a small known sample before changing a whole dashboard.

4. Expose limitations and last-update context where they affect interpretation. Never manufacture precise costs from incomplete token or pricing information.

## Decision points

- Separate measured usage, estimated cost, quoted price and confirmed charge; these are not interchangeable.
- A missing price or record is unknown/partial, not zero; compare only values with compatible units and scope.

## Quality criteria

- A metric definition states numerator, denominator, unit, period, source and exclusions so two screens mean the same thing.
- Aggregation deduplicates source events and preserves tenant/currency boundaries.
- Stale or incomplete data is labeled with enough context to prevent a false operational decision.
- Currency conversion, when authorized and relevant, records rate source and time rather than silently summing raw amounts.

## Validation and evidence

- Recompute a small known set from source events and compare the displayed total, including duplicate/retry and missing-price cases.
- Report the exact period, unit, source and known gaps behind each value claimed.

## Avoid

- Do not sum BRL and USD as one raw total.
- Do not fabricate a historical cost by applying today’s price without labeling the estimate.

## Completion

Reproducible metrics with clear provenance and honest handling of missing or estimated data.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
