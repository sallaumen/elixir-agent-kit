---
name: security-boundaries
description: "Use when untrusted input, credentials, permissions or tenant boundaries may permit unintended access."
---

# Security Boundaries

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a LiveView `mount/3` or `handle_event/3` loads a record by the id in params without the organization or user from `current_scope`; when a context function calls `Repo.get/2` where a scoped query was intended; when a `live_session` or router pipeline lacks the `on_mount` or plug that enforces authentication; when `String.to_atom/1` is applied to a param, an upload path is built from the client filename, or a webhook or token is accepted without verifying its signature; or when a credential appears in a log line, an error page or a response.

This workflow asks which actor may reach which resource through which boundary. When the question is whether layers agree on a value, use [data-contracts](../data-contracts/SKILL.md). When the untrusted content is a prompt, a provider response or a budget for a paid call, use [provider-calls](../provider-calls/SKILL.md); it treats that content as data. When a wrong result has no actor or boundary dimension, use [debugging](../debugging/SKILL.md). Setup of credentials for a new integration belongs to [integration-setup](../integration-setup/SKILL.md).

## Inputs to inspect

- Start at: the route or event named in the report; run `mix phx.routes | grep <path>` to find its pipeline and `live_session`, then open the mount, event handler or controller action it reaches.
- The scope mechanism: `current_scope` or the equivalent assign, the `on_mount` hooks and plugs that set it, and which pipelines skip them. See [Phoenix and LiveView](../../elixir/phoenix-liveview.md) and [Security](../../elixir/security.md).
- The context functions for the resource and whether every read and write takes the scope as an argument and filters the query by it.
- Input handling: params turned into atoms, uploads and their accepted types and destinations, file paths, query fragments, redirect targets, tokens and webhook signatures.
- Background and side paths: Oban job arguments carrying an id without its scope, exports, PubSub topics and caches keyed by id alone. See [Oban](../../elixir/oban.md).
- Logs, error messages and telemetry metadata for credentials, tokens or raw user payloads.

## Workflow

1. Write the boundary table for the operations in scope: operation, actor (role and scope), resource, trust boundary (pipeline, `on_mount`, context, job), intended rule, and where it is enforced today. This table is the artifact every later step reports against. Done when every route and event in scope has a row that says "enforced at" or "none".

2. Trace one operation from params through parsing, authorization, query and effect. Mark the first hop where an input id is used without scope, or where input becomes an atom, a path, a query or a redirect. Done when every row has its first unscoped hop or is cleared.

3. Reproduce with a controlled test: a user from a second tenant or a lower role requests the resource, expecting a redirect, a 403 or a not-found; add one malformed input case. Use local fixtures only; never probe a third-party or production system. Done when the test fails for the stated reason.

4. Fix at the read or write boundary: the context function takes the scope and the query filters by it, the mount reads the resource through that function, atoms come from an explicit mapping, uploads use `allow_upload/3` with accepted types and a server-chosen destination, tokens are verified with the project's signing mechanism and compared in constant time. Done when the allowed test and the denied test both pass.

5. Apply the same rule to the side paths in the table: jobs, exports, topics and caches that carry the id. Done when each row's rule holds in background work as well as in the request.

6. Record findings with preconditions, impact, evidence and confidence, and name the remaining uncertainty. Done when the report claims only the boundaries that were exercised and no certification.

## Decision points

- Authorize where data is read or changed, in the context function with the scope as an argument; a hidden button or a guarded route alone is not enforcement.
- A resource id from params is untrusted until it is loaded through a scoped query; `Repo.get/2` by id is a finding in any multi-tenant context.
- Atoms, paths, redirect targets and query fragments are never built from raw input; use an explicit allow-list or mapping.
- A finding needs a reachable actor; a suspicious pattern with no path from an actor is a hypothesis, recorded as such.
- Secrets live in the environment or the project's credential mechanism and never in rows, logs, errors, prompts or client responses.

## Quality criteria

- Tenant or account scope survives ids supplied in URLs, events, caches, exports, attachments and queued jobs.
- Each operation in the table has its rule enforced at the context boundary and tested with one allowed and one denied actor.
- Webhook authenticity, upload types and destinations, and outbound request targets are validated at the real boundary when those paths exist.
- No credential or raw user payload reaches logs, error pages, telemetry metadata or responses beyond what the privacy rule allows; exposure reports name type and location without copying values.
- Retrieved documents, uploads and model outputs are treated as data and never gain authority to run privileged code or widen consent.

## Validation and evidence

- Minimum: a test at the public boundary (`Phoenix.ConnTest` or `Phoenix.LiveViewTest`) with one allowed actor and one denied cross-scope or lower-role actor for the operation in scope. See [ExUnit and diagnostics](../../elixir/exunit.md).
- When turns allow: a malformed input case per input type found in step 2 (atom, path, upload, token) asserting rejection without a crash.
- When background work carries the id: an `Oban.Testing` run of the job with a foreign-scope id asserting no effect.
- When a credential exposure was found: the log or response line, with the value redacted, and the test that proves it is gone.

## Avoid

- Do not run offensive tests against third-party or production systems as an implicit review step.
- Do not fix only the visible control, the route guard or the LiveView and leave the context function unscoped.
- Do not call a scoped review a security certification or extend findings beyond the boundaries exercised.
- Do not extract real sensitive records to prove a finding; a fixture that demonstrates the path is enough.
- Do not convert input to atoms, paths or redirects "temporarily" while the real fix is pending.

## Completion

A boundary table with each operation's rule enforced at the read or write boundary, tests for an allowed and a denied actor, inputs mapped through explicit allow-lists, side paths scoped the same way, and a findings report that separates evidence from hypothesis. For prompt content and paid providers use [provider-calls](../provider-calls/SKILL.md); for a field that layers disagree about use [data-contracts](../data-contracts/SKILL.md); for credential setup use [integration-setup](../integration-setup/SKILL.md); for a review-only pass on a bounded diff use [code-review](../code-review/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
