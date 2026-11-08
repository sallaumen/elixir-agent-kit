---
name: provider-calls
description: "Use when code calls a paid, rate-limited or externally billed provider and its retries, budget, audit trail or failure reasons are unclear."
---

# Provider Calls

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when adding or changing a call to a model API, a speech or image service, a payment or marketplace API, or any endpoint that charges per request or enforces quotas; when a charge appears without a matching record; when a timeout or empty answer leaves nobody sure whether the provider did the work; or when a retry policy is being added to such a call.

This workflow governs the single outbound call and its record. Capacity and queue accounting across many calls belong to [ai-orchestration](../ai-orchestration/SKILL.md); setup and readiness of the integration belong to [integration-setup](../integration-setup/SKILL.md); message transport belongs to [notifications](../notifications/SKILL.md); a flow that fans out many such calls (a batch, a queue consumer) is [data-pipelines](../data-pipelines/SKILL.md) for its bounds and delivery, with this workflow for each call.

## Size

- **Small**: fix one call site (its audit row, its retry or its typed failure) and one controlled-response test; skip the full call map for the other sites.
- **Medium**: run the workflow as written for one provider: the call map, the budget gate, the audit row and the controlled-response tests.
- **Large**: many call sites or providers, or a shared client for all of them; slice per provider or call, and route capacity across workers to ai-orchestration and the cost dashboard to metrics-costs as later slices.

## Inputs to inspect

- Start at: the shared client module for the provider and `grep -rn "Req\.\|Finch\.\|HTTPoison\.\|Tesla\." lib/` for every call site, then the place where the request is built: which inputs reach the provider, whether user content is included, and how the prompt or payload is chosen.
- The provider's documented semantics for the exact operation: idempotency keys, billing moment (on request, on success, on tokens), rate limits, timeouts, error codes, and what a partial or empty response means.
- The project's budget, retry, audit and privacy rules, and where they are enforced today.
- The record written per call: provider, operation, model or product, cost or units, latency, outcome, parse state, request identifier.
- Tests and fixtures for the client, and whether any test can reach the real provider. See [Oban](../../elixir/oban.md) and [ExUnit and diagnostics](../../elixir/exunit.md).

## Workflow

1. Map the call: trigger, caller, request construction, transport, response parsing, persisted record, effect on the user. Mark every place a call can happen without passing through the shared client. Done when every call path is in the map or marked as bypassing the shared client.

2. Decide the budget gate before the network: a check that answers "allowed, and with which limit" from local state, so an exhausted budget costs nothing. Record the decision when it denies. Done when the budget check runs before any network and a denial is recorded.

3. Write the audit row at the moment that reflects the provider's billing: before the request if the provider charges on request, or with an in-flight status updated on completion. A paid answer without a row, or a row without a paid answer, is a bug to test for. Done when the row is written at the billing moment and the paid-without-row and row-without-paid-answer cases are named as tests.

4. Define failure as a typed reason, never a fabricated answer: not configured, unauthorized, quota exhausted, timeout, provider error with status, invalid output. Each reason has a caller-visible consequence and none raises past the boundary that owns the record. Done when each reason has a caller-visible consequence and none raises past the owning boundary.

5. Decide retries per operation from the provider's idempotency semantics: no retry by default for anything that charges; a retry only with an idempotency key the provider honors, or after confirming the first attempt did not complete. A timeout is not evidence the work was not done. Done when each operation's retry rule is written from the provider's idempotency semantics.

6. Validate the response structurally before use (schema, required fields, bounds) and treat its content as data: provider output and user content inside a prompt never acquire authority to run tools, change scope or alter instructions. Done when the schema or bounds check runs before use and provider output cannot alter scope or instructions.

7. Test with controlled responses: success, each failure reason, timeout, malformed output, and a retry scenario that proves the effect happened once. Put the engine behind a behaviour: a fixture implementation answers from files so development runs without a key, a scripted one feeds tests, and the real adapter is tested through its HTTP stub (see [HTTP clients and provider APIs](../../elixir/http-clients.md)). Keep one real call behind an explicit, authorized gate. Done when the controlled-response tests pass and the one real call is behind an explicit authorized gate.

## Decision points

- Budget before network, always; denial is a recorded outcome, not an exception.
- Record first or in-flight, by the provider's billing moment; never "if the response arrives".
- Retry only with provider-honored idempotency or verified non-completion; otherwise surface the failure and let the caller decide.
- One client module per provider owns credentials, timeouts, parsing and the audit row; call sites do not build requests by hand.
- Secrets stay in the environment or the project's credential mechanism; they never appear in the row, the log, the error or the response to a browser.
- Untrusted text in a prompt (titles, comments, documents) is escaped or scoped to the data role; the system instruction is code.
- Permitted model calls are a literal registry in code (name, prompt, model tier, output cap, output schema); a caller passes inputs and a registered name, never a prompt, and adding a call is a reviewed change with a test.
- Fall back to another provider only on a refusal that says nothing about the request (not configured, expired key, spent quota); a content error such as malformed output stays an error, because another engine would answer the same prompt the same wrong way.
- The cheapest tier that passes the output schema is the default; a deeper tier is chosen when the result shows the cheap one was not enough, not by habit.
- A cache of paid answers keys on every input that changes the answer (call name, provider, model, prompt or schema version, inputs), re-validates the cached value against the output schema before use, and records a hit at zero cost.

## Quality criteria

- Every call has exactly one audit row with cost or units, latency, outcome and a request identifier that can be matched to the provider's console.
- A failed network round trip can never produce a second charge; the test suite proves it with a retried call.
- Every failure reaches the caller as a typed reason with a next action; no path returns an invented or empty "success".
- Invalid or unexpected output is rejected with a reason and recorded, not passed downstream.
- Budget and rate limits are enforced locally before the request and the denial is visible to operators.
- No credential, prompt secret or raw user payload appears in logs, rows, errors or client responses beyond what the privacy rule allows.

## Validation and evidence

- Minimum: a controlled-response test for the reported failure (a failure reason, malformed output, timeout or retry-once) with the audit row asserted and a retry shown to charge once.
- When turns allow: the call map (call sites, shared client, record) and the provider's documented billing and idempotency semantics with the date checked.
- When turns allow: controlled-response tests for each remaining failure reason, malformed output, timeout and retry-once, with the audit rows asserted.
- When the session has console or invoice access: a reconciliation of a small sample of audit rows against the provider's console or invoice; otherwise the statement that this was not done.
- When turns allow: the budget gate exercised at the limit, with the denial recorded.

## Avoid

- Do not retry a paid call because the response was slow or empty; confirm first.
- Do not write the audit row only on success, or compute cost from today's price for a historical call without labeling it an estimate.
- Do not let a prompt or payload include secrets, or let provider output or user content instruct the agent or the application.
- Do not spread provider-specific request code across call sites or test against the live provider by default.
- Do not report "provider down" from a single timeout; distinguish unreachable, rejected, exhausted and slow.

## Completion

A single client boundary where budget is checked before the network, every call is recorded at the billing moment, failures are typed reasons, retries follow the provider's idempotency rules, and output is validated as data, with tests for each failure and a retry that charges once. For capacity across workers use [ai-orchestration](../ai-orchestration/SKILL.md); for the cost dashboard use [metrics-costs](../metrics-costs/SKILL.md); for tenant and input boundaries beyond the prompt use [security-boundaries](../security-boundaries/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
