---
name: notifications
description: "Use when bots or notifications fail, repeat or produce unexplained message volume."
---

# Notifications

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a chat bot or email sender stops delivering and the logs show only timeouts; when the same message reaches a recipient twice after an Oban retry or a webhook redelivery; when a channel receives hundreds of messages in an hour and nobody can say which event produced them; when two nodes of the application both poll the provider and answer the same inbound update; or when a provider starts returning 429 or 403 and the team suspects a ban.

This workflow owns transport: the path from an emitted event to a delivered message, with its dedup key, retries and rate limits. The rule that separates it from [operational-alerts](../operational-alerts/SKILL.md): if the question is "why did this message fail, repeat or multiply", it is transport and belongs here; if the question is "why does this alert repeat, look current when it is historical, or appear resolved when someone acknowledged it", it is incident lifecycle and belongs there. The single paid provider request and its audit row belong to [provider-calls](../provider-calls/SKILL.md); whether the bot is configured at all belongs to [integration-setup](../integration-setup/SKILL.md).

## Size

- **Small**: give one message a stable delivery key and prove a duplicate sends once; skip the full delivery table.
- **Medium**: run the workflow as written for one channel: the delivery table, the duplicate producer and the retry policy mapped to provider responses.
- **Large**: several channels or a whole delivery chain; slice per channel, and route the incident lifecycle to operational-alerts or the paid send to provider-calls as later slices.

## Inputs to inspect

- Start at: the send function for the affected channel (`grep -rn "deliver\|send_message\|notify" lib/`) and the first log line or counter that showed the failure or the volume.
- The inbound side: webhook route or poller, how many processes run it (one per node, one per cluster, a GenServer under each supervisor), and what identifies an inbound update.
- The outbound chain: event emitted, Oban job or process, provider client, provider response, persisted delivery record; which identifier travels the whole chain.
- Retry and uniqueness settings on the delivery worker (`unique`, `max_attempts`, backoff) and what the provider does with a repeated send.
- The provider's current documented limits and error codes for the operations used, read today, and the exact library version in `mix.lock`. See [Oban](../../elixir/oban.md), [OTP processes and supervision](../../elixir/otp.md) and [HTTP clients and provider APIs](../../elixir/http-clients.md).

## Workflow

1. Write the delivery table for the affected channel: one row per stage (event created, routed, enqueued, sent, provider accepted, delivered or failed) with the identifier present at that stage, the record or log that proves it, and the count observed in the incident window. Done when every stage has a row and the stage where counts stop matching is marked.

2. Count by direction: inbound updates received, events processed, sends attempted, sends accepted. Done when the unexplained volume is attributed to one stage (duplicate inbound, fan-out in routing, or retried sends) with the numbers that show it.

3. Find the duplicate producer: a second poller or subscription, a webhook registered twice, a job without a unique key, a retry after a timeout that the provider had already accepted. Done when the producer is named with the evidence (process list, provider webhook list, job rows) or ruled out.

4. Give every message a stable delivery key derived from the source event (event id plus recipient plus channel), enforce it at the job (`unique`) and at the delivery record, and make a retry look up the record before sending. Done when a repeated job and a redelivered webhook each produce one send in a test.

5. Define retry and backoff per provider response: retry transient failures with backoff under the documented limit; stop on authorization and configuration errors and surface them as a typed reason; treat 429 as a limiter signal for that channel. Done when every provider status the client handles maps to one of retry, stop or slow.

6. Verify one accepted send, one rejected send, one timeout and one duplicate with controlled responses, with tokens and recipient content redacted in logs. Done when the focused tests pass and the project gate is green.

## Decision points

- Separate received, processed and sent before explaining volume; a polling error is not evidence that anything was sent.
- The delivery key comes from the source event, not from the send attempt; a retry reuses it.
- A timeout is not a failed send; check the delivery record or the provider before resending.
- Treat a ban or rate limit as a hypothesis until response codes, send records and current provider documentation agree.
- One inbound consumer per cluster for a polled provider; a second node must not start a second poller without a lock or leader election.
- Authorization and configuration failures are terminal and visible; they are never retried into silence.

## Quality criteria

- A source event has one stable identity through routing, enqueue, send and record; the test suite proves that a duplicate webhook and a retried job each send once.
- Backoff respects the provider's documented limit, and permanent failures stop with a typed reason that names the next action.
- Status separates configured, receiving, processing and delivering, and each failure state says what to do next.
- Tokens, personal data and message content never appear in logs, rows or error messages beyond what the privacy rule allows.
- Only one poller or subscription exists per provider per cluster, and the test or runtime check that proves it is named.

## Validation and evidence

- Minimum: a test that delivers the same source event twice (a retried `perform_job/3` with `Oban.Testing`, or the same webhook payload posted twice) against a fake provider client and asserts one send and one delivery record.
- When turns allow: accepted, rejected, timeout and 429 responses from the fake client, asserting the retry, stop or slow decision for each.
- When turns allow: the observed counts by stage from the delivery table for the incident window, with the stage where they diverge.
- When the session has provider console access: the registered webhooks or active sessions compared with what the application expects; otherwise state that this was not checked.

## Avoid

- Do not hardcode a provider limit from memory; read the current documentation and note the date.
- Do not send a real notification, rotate a credential or re-register a webhook as a diagnostic step.
- Do not resend after a timeout without checking the delivery record.
- Do not explain an alert's repetition here; that is the incident lifecycle in [operational-alerts](../operational-alerts/SKILL.md).
- Do not let two nodes each poll the same provider account.

## Completion

A delivery table with counts per stage, one stable delivery key enforced at the job and the record, a retry policy mapped to provider responses, a single inbound consumer, and tests that prove a duplicate event sends once. For the incident lifecycle behind a repeated alert use [operational-alerts](../operational-alerts/SKILL.md); for a bot that is not yet ready use [integration-setup](../integration-setup/SKILL.md); for a paid message provider's budget and audit row use [provider-calls](../provider-calls/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
