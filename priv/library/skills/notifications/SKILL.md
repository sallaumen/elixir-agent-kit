---
name: notifications
description: "Use when bots or notifications fail, repeat or produce unexplained message volume."
---

# Notifications

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when bots or notifications fail, repeat or produce unexplained message volume.

## Inputs to inspect

- Provider account, inbound polling/webhook route, outbound send path, schedule, retry policy and message logs or counters.
- The provider’s current official API contract and the exact library version used by this project.

## Workflow

1. Trace event creation, routing, delivery attempts and provider responses. Separate configured, connected and successfully delivered states.

2. Investigate duplicate pollers, repeated subscriptions, stale credentials, conflicting endpoints and provider limits using evidence. Do not infer a provider ban from a missing response.

3. Define deduplication, retry and ordering behavior for the actual delivery semantics. Avoid contacting real recipients during tests unless explicitly authorized.

4. Verify one successful and one failed delivery with controlled fixtures. Keep secrets out of logs and expose a useful diagnostic reason.

## Decision points

- Distinguish receiving, processing and sending before explaining volume; a polling error is not evidence of messages sent.
- Treat provider bans or rate limits as hypotheses until response codes, send records and official guidance support them.

## Quality criteria

- A source event has stable identity through delivery so duplicate callbacks/retries do not create unexplained sends.
- Backoff and recovery respect provider limits without hiding permanent authorization/configuration failures.
- Operational status separates configured, receiving, processing and delivering; failures state the next action.
- Redaction keeps tokens, personal data and private message content out of logs and reports.

## Validation and evidence

- Use controlled responses to cover accepted send, rejection, timeout, duplicate event and recovery without contacting real recipients.
- Report observed counts by direction and source, including uncertainty about provider state.

## Avoid

- Do not hardcode a current provider limit from memory.
- Do not send a real notification or rotate credentials as an implicit diagnostic step.

## Completion

A grounded transport diagnosis and reliable delivery behavior. The lifecycle of the underlying operational problem belongs to operational-alerts.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
