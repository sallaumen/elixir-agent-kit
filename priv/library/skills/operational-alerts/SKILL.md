---
name: operational-alerts
description: "Use when alerts repeat, historical incidents look current or acknowledging an alert appears to resolve it."
---

# Operational Alerts

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when the operator receives a new alert every minute for one failing job instead of one alert that stays open; when a restart or a replay of old events makes last week's incident appear as current on the status screen; when clicking "acknowledge" or opening the alert marks it resolved although the queue is still failing; when the same condition is reported by two detectors as two unrelated incidents; or when a recovered condition never closes because nothing emits a recovery signal.

This workflow owns the incident lifecycle: detection, acknowledgement, escalation, resolution and recurrence as persisted state with a dedup window and resolution evidence. The rule that separates it from [notifications](../notifications/SKILL.md): if the question is "why does this alert repeat, look current when it is historical, or appear resolved on acknowledgement", it is lifecycle and belongs here; if the question is "why did this message fail, repeat or multiply in the channel", it is transport and belongs there. The stuck job itself belongs to [async-state](../async-state/SKILL.md) or [process-lifecycle](../process-lifecycle/SKILL.md).

## Size

- **Small**: separate one attention field from resolved_at so acknowledgement leaves the episode open, with one test; skip the full lifecycle table.
- **Medium**: run the workflow as written for one alert type: the lifecycle table, the condition key and the open, repeat, acknowledge, recover and recur tests.
- **Large**: several alert types or detectors; slice per alert type, and route message delivery to notifications or the stuck job to async-state or process-lifecycle as later slices.

## Inputs to inspect

- Start at: the module that creates or updates the alert record (`grep -rln "alert\|incident" lib/`) and the status screen or channel where the wrong state was seen.
- The detectors: which jobs, telemetry handlers or health checks emit the source events, what each event carries (condition key, scope, severity, timestamp), and whether two detectors can describe one condition.
- The persisted alert schema: identity key, state field, opened and last-seen timestamps, acknowledged-by, resolved-at, and which transitions write which fields.
- The recovery signal: what observation proves the condition is gone, and whether anything in the system produces it.
- The routes from an alert state change to a person: which transitions notify, the dedup window, and what happens on restart or event replay. See [Oban](../../elixir/oban.md), [Ecto and migrations](../../elixir/ecto.md) and [Telemetry and observability](../../elixir/telemetry.md).

## Workflow

1. Write the lifecycle table for the alert type: one row per state (detected, open, acknowledged, escalated, resolved, recurred) with the transition that enters it, the component allowed to perform it, the evidence it requires, and the fields it writes. Done when every state has exactly one owner and the resolved row names an observed recovery signal, or says that none exists.

2. Define the condition identity: the key that makes repeated detections of one condition the same incident (condition type plus scope such as queue, tenant or provider), and the dedup window after which a new detection opens a new episode. Done when two detections inside the window update one row in a test and a detection after resolution opens a new row.

3. Separate human attention from system state: acknowledge, seen, snoozed and silenced write attention fields and suppress further messages to people; they never write `resolved_at`. Done when the only writer of `resolved_at` is the recovery path.

4. Make resolution evidence-based: resolve when the detector observes the condition absent for the configured quiet period, or when an operator resolves with a reason that is stored. Done when a failing condition with a clicked acknowledgement still shows open.

5. Make history survive restart and replay: episodes carry opened and resolved timestamps, replayed events older than the last-seen timestamp update nothing, and the status screen derives current from open episodes only. Done when a replay of last week's events changes no current status in a test.

6. Route notifications per transition through [notifications](../notifications/SKILL.md): open and escalate notify, repeat inside the window does not, recovery notifies once; a failing notifier raises its own alert at most once per window. Done when the transition-to-notification map is written and tested.

7. Exercise open, repeat, acknowledge, recover and recur in order, plus a restart between steps, and run the project gate. Done when the tests pass and the status screen shows the expected state at each step.

## Decision points

- A failure event, an ongoing incident and a message to a person are three things; one event updates one incident and may produce zero messages.
- Acknowledged, seen, snoozed and silenced describe attention and never prove recovery.
- The condition key is stable across detectors; two detectors for one condition write one episode.
- Resolution requires evidence from the system or a stored operator reason; absence of new events is not evidence until the configured quiet period has passed.
- Severity derives from impact, urgency and actionability of the condition, never from the event count.
- Replayed or late events update last-seen only when they are newer than what is stored.

## Quality criteria

- Repeated events for one active condition update a single open episode; the test suite proves the count stays at one inside the window.
- `resolved_at` is written only on observed recovery or an operator resolution with a stored reason; acknowledgement leaves the episode open.
- A restart or replay never makes a resolved episode current, and history still shows each past episode with its timestamps and owner actions.
- Each transition has a defined notification behavior, and a failing notifier cannot loop into alerting about itself.
- Severity and current status on screen match the persisted episode, with the recovery signal named on the episode.

## Validation and evidence

- Minimum: a test that emits the same condition three times inside the window, acknowledges, emits again, then emits recovery, asserting one episode, `resolved_at` nil after acknowledgement, and `resolved_at` set only after recovery.
- When turns allow: a recurrence after resolution opening a second episode, and a replayed old event changing nothing.
- When turns allow: a restart between open and recovery (a fresh process or a new test reading the persisted row), asserting the status screen still shows the episode open.
- When the project has a real channel: the transition-to-notification map exercised against a fake transport, with counts per transition.

## Avoid

- Do not convert "mark as read", "seen" or "acknowledged" into "resolved".
- Do not notify about the same failing notifier in an uncontrolled loop.
- Do not derive severity or current status from the number of events received.
- Do not debug message delivery here; a channel that drops or duplicates messages is [notifications](../notifications/SKILL.md).
- Do not create a new episode per detector for one condition.

## Completion

A persisted incident lifecycle with one owner per transition, a stable condition key with a dedup window, acknowledgement separated from resolution, resolution backed by an observed signal or a stored reason, history that survives restart and replay, and tests for open, repeat, acknowledge, recover and recur. For message delivery use [notifications](../notifications/SKILL.md); for the stuck job behind the alert use [async-state](../async-state/SKILL.md); for the counts that feed a status dashboard use [metrics-costs](../metrics-costs/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
