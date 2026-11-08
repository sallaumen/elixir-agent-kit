---
name: metrics-costs
description: "Use when totals, model costs or operational metrics have unclear scope, origin or meaning."
---

# Metrics Costs

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when the dashboard's "cost this month" differs from the provider invoice and nobody can say which rows it sums; when a total mixes BRL and USD, or tokens and requests, into one number; when a retried job counts its call twice while a cached answer counts as zero; when two screens show different "active jobs" because each wrote its own query; when a metric shows 0 for a period whose records are missing rather than empty; or when a historical cost was recomputed with today's price and shown without a label.

This workflow owns metric definitions and the aggregation from source rows to a displayed number. The per-call row with cost, units and outcome is produced by [provider-calls](../provider-calls/SKILL.md); the capacity counters it reads are owned by [ai-orchestration](../ai-orchestration/SKILL.md); a rule duplicated between a context and a screen is also [data-contracts](../data-contracts/SKILL.md); if the number is right but the screen is hard to scan, that is [layout-density](../layout-density/SKILL.md).

## Size

- **Small**: correct one aggregation rule (one dedupe or one currency boundary) with one test; skip the full metric definition table.
- **Medium**: run the workflow as written for one metric: the definition table, the hand recomputation and the aggregation test.
- **Large**: many metrics or screens; slice per metric, and route the per-call row to provider-calls or the capacity counters to ai-orchestration as later slices.

## Inputs to inspect

- Start at: the query or function behind the one number in question (`grep -rn "sum(\|count(\|aggregate" lib/` in the context that feeds the screen) and the screen or report that shows it.
- The source rows: the audit or event table each metric reads, its unit and currency columns, timestamps and timezone, and the markers for retries, duplicates, cache hits and estimates.
- The decision each metric supports and who reads it (operator, finance, a scheduling rule), since that fixes window, unit and tolerance.
- Provider prices used for cost: where they are stored, their effective dates, and whether a row stores the price at call time or only units.
- Telemetry events and any existing reconciliation against an invoice or console export. See [Telemetry and observability](../../elixir/telemetry.md) and [Ecto and migrations](../../elixir/ecto.md).

## Workflow

1. Write the metric definition table: one row per displayed number with columns for name, source rows (table and filter), window and timezone, unit or currency, aggregation rule, exclusions (retries, duplicates, cache hits), and who reads it. Done when every number on the screen has a row and every row names a concrete table and filter.

2. Trace one displayed total back to its rows for a small window (one day, one tenant) and recompute it by hand or in a test. Done when the recomputation matches, or the first row that explains the difference is identified.

3. Classify every value as measured, estimated, unavailable or zero, in the data and on the screen: a price stored at call time is measured, a price applied later is estimated, a missing row is unavailable, and zero is a real sum over present rows. Done when no code path turns a missing price or missing row into 0.

4. Fix aggregation at the source: deduplicate by call or event id, exclude retried attempts that did not charge, keep tenant and currency as grouping keys, and never sum across currencies without a stored rate with its source and time. Done when one function in the context implements the rule and every screen calls it instead of writing its own query.

5. Handle windows truthfully: partial current periods are labeled, delayed rows move the last-complete marker, and the screen shows the last update time and any data gap. Done when a period with missing data renders as incomplete, not as a low total.

6. Reconcile a small known sample against the provider console or invoice when available, record the result with the date, and run the project gate. Done when the sample matches within the stated tolerance or the discrepancy is attributed to a named cause.

## Decision points

- Measured usage, estimated cost, quoted price and confirmed charge are four values; the screen says which one it shows.
- A missing price or row is unknown, never zero; a zero requires present rows that sum to zero.
- One aggregation function per metric in the context; screens render it and never reimplement it.
- Retries that did not charge are excluded; delegated calls count at the leaf once; a cache hit counts as a request with zero cost only if the definition says so.
- Currency and tenant are grouping keys; conversion is a separate, labeled step with rate source and time.
- Historical cost uses the price stored on the row; recomputing with a later price is an estimate and is labeled on screen.

## Quality criteria

- Every displayed metric has a definition row naming source, window, unit, rule and exclusions, and two screens showing the same name show the same number.
- Aggregation deduplicates by call or event id and preserves tenant and currency boundaries; the test suite proves it with a retried and a duplicated row.
- Measured, estimated, unavailable and zero are distinguishable in the data and on the screen.
- Partial periods, delayed rows and last-update time are visible where they affect a decision.
- A sampled reconciliation against the provider is recorded with date and tolerance, or its absence is stated.

## Validation and evidence

- Minimum: a test that inserts a known set of source rows (one normal call, one retried attempt that did not charge, one duplicated event id, one row without a price, two currencies) and asserts the aggregation returns the expected per-currency totals with the priceless row reported as unknown.
- When turns allow: the hand recomputation of one displayed total for a small window, with the row-level difference if any.
- When turns allow: the screen rendering of a partial period and of a window with missing rows, asserting the incomplete label in a LiveView test.
- When the session has console or invoice access: a sample of audit rows reconciled against the provider, with the date and tolerance; otherwise say it was not done.

## Avoid

- Do not sum BRL and USD, or tokens and requests, into one raw total.
- Do not apply today's price to a historical call without labeling the result an estimate.
- Do not let a screen or LiveView write its own aggregation query for a metric the context already defines.
- Do not render unknown or missing as 0, or a partial period as complete.
- Do not count a retried attempt, a delegated parent or a cache hit as a charged call unless the definition says so.

## Completion

A metric definition table covering every displayed number, one aggregation function per metric that deduplicates and preserves tenant and currency, measured, estimated and unknown kept distinct in data and on screen, labeled partial windows, and a recorded reconciliation sample. For the per-call row use [provider-calls](../provider-calls/SKILL.md); for capacity numbers use [ai-orchestration](../ai-orchestration/SKILL.md); for rules duplicated across layers use [data-contracts](../data-contracts/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
