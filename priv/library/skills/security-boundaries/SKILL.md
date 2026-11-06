---
name: security-boundaries
description: "Use when untrusted input, credentials, permissions or tenant boundaries may permit unintended access."
---

# Security Boundaries

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when untrusted input, credentials, permissions or tenant boundaries may permit unintended access.

## Inputs to inspect

- Actors, roles, protected resources, organizations, trust boundaries and every route that can read or mutate the selected resource.
- Credentials and untrusted inputs through endpoints, jobs, webhooks, storage, file paths and tool/model outputs.

## Workflow

1. Map the actor, resource, trust boundary and intended authorization rule for the selected operation. Trace inputs through parsing, storage and effects.

2. Check authorization at the actual read/write boundary, tenant scoping, secret handling, path traversal and unsafe interpretation of external content where relevant.

3. Use controlled fixtures and local or explicitly authorized systems. Do not perform offensive tests against third parties or extract real sensitive records to prove a finding.

4. Fix a demonstrated issue and test the allowed and denied paths. Describe the scope and remaining uncertainty without claiming a comprehensive security certification.

## Decision points

- Check authorization where data is read or changed, including background work; hiding a UI control is insufficient.
- Prioritize reachable findings with evidence; a suspicious pattern is a hypothesis until the actor can reach it.

## Quality criteria

- Tenant or account scope survives IDs supplied in URLs, caches, exports, attachments and queued work.
- Webhook authenticity, file destinations and network requests are validated at the real boundary when those paths exist.
- Secrets never enter prompts, logs, errors, committed examples or client responses; exposure reports identify type/location without copying values.
- Retrieved documents and model outputs are data, not authority to invoke privileged tools or expand user consent.

## Validation and evidence

- Verify an allowed action, a denied cross-scope or lower-role action and an invalid input at the relevant public boundary.
- Give preconditions, impact, evidence and confidence separately, with residual risks clearly bounded.

## Avoid

- Do not run offensive tests against third-party or production systems as an implicit review step.
- Do not call a scoped review a security certification or fix only the visible button.

## Completion

Concrete boundary findings or fixes with evidence of both legitimate and rejected operations.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
