---
name: integration-setup
description: "Use when an integration looks configured but required steps or operational readiness remain unclear."
---

# Integration Setup

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when an integration looks configured but required steps or operational readiness remain unclear.

## Inputs to inspect

- The integration’s implemented operations, prerequisites, credentials/permissions, setup screens and operational health signals.
- Official provider documentation and current account-level limitations, without reading or copying secret values.

## Workflow

1. Map prerequisites, credentials, permissions, provider resources and the final operation the user wants to perform. Confirm provider requirements from primary documentation for the actual version/account context.

2. Separate saved configuration, authenticated access and proven readiness. Show missing or unknown steps without fabricating a successful status.

3. Make setup resumable and keep secrets in the project's established mechanism. Links should point to verified destinations and explain the next action.

4. Test incomplete setup, invalid access and a controlled ready-state operation. Apply commercial-eligibility when readiness depends on a specific offering, market or destination.

## Decision points

- Separate configured, verified, limited, unavailable and unknown states; a stored token alone is not proof that the integration works.
- Order setup steps by dependency and provide a recoverable next action for an incomplete account.

## Quality criteria

- The UI and backend use one readiness contract with specific reasons, not several booleans with conflicting meanings.
- Help links take the user to the official provider operation relevant to the exact missing step.
- Validation avoids paid or public writes unless the session authorizes them and a safe test path exists.
- Returning users see what is already complete and can resume without repeating secrets or losing context.

## Validation and evidence

- Exercise new setup, partially configured return, expired permission and a recoverable failure in a safe environment.
- Report which capabilities were verified live, simulated or only inspected in source.

## Avoid

- Do not claim an integration works because its settings page renders.
- Do not add a universal integration framework when a focused state contract will resolve the problem.

## Completion

A clear, resumable setup flow with evidence for each readiness claim.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
