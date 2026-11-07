---
name: integration-setup
description: "Use when an integration looks configured but required steps or operational readiness remain unclear."
---

# Integration Setup

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when the settings page shows a green "connected" badge but the first real operation fails with 401 or 403; when a token is stored in the database but nobody knows whether the scope it was granted covers the operation the product needs; when a webhook URL is saved in the form but the provider has never called it; when a returning user is asked to paste the same credential again because the flow cannot tell which steps are complete; or when the only readiness signal is "the settings LiveView renders without error".

This workflow owns readiness: the ordered prerequisites of an integration and the evidence that each one holds. Whether the provider supports this exact product variant and destination at all belongs to [commercial-eligibility](../commercial-eligibility/SKILL.md); the single outbound request, its budget and its audit row belong to [provider-calls](../provider-calls/SKILL.md); a bot that is ready but drops or duplicates messages belongs to [notifications](../notifications/SKILL.md).

## Inputs to inspect

- Start at: the settings or connection module for the integration (`grep -rn "connected\|configured\|ready" lib/`) and the operation that failed or is in doubt.
- Every boolean or status field that claims readiness, in the schema, the context module and the templates, and the condition behind each one.
- The provider's documented prerequisites for the exact operation and account type: credential kind, scopes or permissions, webhook registration, verification steps, sandbox versus live; note the date read. See [HTTP clients and provider APIs](../../elixir/http-clients.md).
- Where credentials live (environment, encrypted column, secrets manager) and how the code reads them, without printing their values.
- The inbound path: webhook route, signature verification, and the record or log that proves a provider event has arrived. See [Phoenix and LiveView](../../elixir/phoenix-liveview.md) and [Security](../../elixir/security.md).

## Workflow

1. Write the readiness checklist: one row per prerequisite in dependency order (credential present, credential valid, scope or permission granted, provider resource created, webhook reachable, first real event observed, operation performed) with columns for the evidence that proves it, where that evidence is stored, and the current value (verified, configured only, failed, unknown). Done when every row has a named evidence source and no row says verified without one.

2. Trace the code path for each row: which check produces the status today and whether it reads stored configuration or performs a live verification. Done when every "connected" badge in the UI is mapped to a checklist row or marked as unbacked.

3. Replace the loose booleans with one readiness contract: a function in the context that returns the ordered rows with their state and a reason, used by both the UI and the operation guard. Done when the operation refuses to run on a non-ready contract with the first failing row as its reason.

4. Make verification steps real and safe: credential validity via the provider's cheapest read operation, scope via the documented introspection or a scoped read, webhook reachability via the provider's test ping or the first signed event recorded. Done when each verifying call is named and none performs a paid or public write.

5. Make the flow resumable: a returning user sees completed rows, is sent to the first incomplete one with a link to the exact provider page for that step, and never re-enters a stored secret. Done when a partially configured fixture account resumes at the right step in a test.

6. Test incomplete setup, expired or revoked access, an unreachable webhook and a fully ready operation with a fake provider, then run the project gate. Done when the tests pass and the checklist values match what the UI shows.

## Decision points

- Configured, verified, limited, unavailable and unknown are distinct; a stored token proves only "credential present".
- Readiness is checked at the operation boundary, not only on the settings page; the badge and the guard read the same contract.
- Verification uses the least costly and least visible provider operation; a paid or public write is never a readiness probe.
- Steps are ordered by dependency and the first failing row is the next action; later rows are reported as unknown, not failed.
- Secrets are read through the project's credential mechanism and never logged, rendered or compared in plain text in a test assertion.
- When the provider's documentation and the account's behavior disagree, record both and mark the row unknown.

## Quality criteria

- The UI and the backend consume one readiness contract with ordered rows and specific reasons, and no template computes readiness on its own.
- Every verified row names the live check or recorded event that proved it, and a revoked credential flips the row within one check cycle.
- Help links lead to the official provider page for the exact missing step and state the next action.
- Returning users resume without repeating secrets or losing completed rows.
- The operation guard refuses a non-ready integration with the first failing row, and the test suite proves it.

## Validation and evidence

- Minimum: a test with a fake provider that drives the readiness contract through credential present, credential invalid (401), scope missing (403) and fully ready, asserting the ordered rows, the first failing reason, and that the guarded operation runs only in the ready case.
- When turns allow: a partially configured fixture account resuming at the first incomplete step in a LiveView test, and an unreachable webhook rendering as unknown rather than failed.
- When turns allow: the filled checklist with each row's evidence source and current value for the real account, with secret values omitted.
- When the session has a sandbox account: one live verifying read per row, with the provider response status recorded; otherwise state which rows were only inspected in source.

## Avoid

- Do not claim an integration works because its settings page renders or a token row exists.
- Do not add a universal integration framework when one readiness contract for this provider resolves the problem.
- Do not probe readiness with a paid, public or irreversible provider write.
- Do not print, log or diff secret values while diagnosing, even in a test.
- Do not decide here whether a specific product, variant or destination is supported; that is [commercial-eligibility](../commercial-eligibility/SKILL.md).

## Completion

A readiness checklist in dependency order with evidence per row, one contract consumed by the UI and the operation guard, safe live verification per step, a resumable flow that never asks for a secret twice, and tests for incomplete, revoked, unreachable and ready states. For whether the offering is supported at this destination use [commercial-eligibility](../commercial-eligibility/SKILL.md); for the request itself use [provider-calls](../provider-calls/SKILL.md); for delivery problems after readiness use [notifications](../notifications/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
