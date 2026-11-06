---
name: module-design
description: "Use when module names, locations or public APIs obscure responsibilities that are already understood."
---

# Module Design

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when module names, locations or public APIs obscure responsibilities that are already understood.

## Inputs to inspect

- Current module names, exported functions, direct/dynamic callers, configuration, behaviours and persisted references.
- Project vocabulary, domain ownership decisions, compilation path and version compatibility requirements.

## Workflow

1. Map the selected modules, their callers and the project naming conventions. State the responsibility each public API is meant to expose.

2. Find misleading names, helpers placed under the wrong owner and public functions without a genuine consumer. Choose names that describe behavior and domain meaning.

3. Before moving or renaming, search aliases, callbacks, configuration, supervision children, dynamic dispatch, serialized module names and persisted jobs. Direct call search alone is insufficient.

4. Make the smallest coherent move and update consumers together. Preserve compatibility for persisted identifiers or publish a migration path. Do not expose private functions solely to make tests easier.

## Decision points

- If the responsibility itself is unclear, use architecture-review before naming; if ownership is already understood, fix the smallest misleading API.
- Treat a rename touching persisted workers, serialized module names or external payloads as migration-compatibility work.

## Quality criteria

- Each public module name predicts its responsibility, and exported operations form a coherent promise to consumers.
- Errors, inputs and side effects are discoverable at the API boundary; callers do not reach through a module to manipulate another owner’s state.
- Internal helpers remain private unless a real consumer needs them; tests alone do not justify expanding a public API.
- Renames update documentation, configuration, dynamic dispatch and import/call sites without changing domain behavior accidentally.

## Validation and evidence

- Build a current-name to target-name map and trace representative callers before and after.
- Compile and exercise an affected public operation, including one failure path; record any compatibility alias and removal condition.

## Avoid

- Do not move files because a directory looks crowded without understanding consumers.
- Do not treat a text search as proof that dynamic or persisted references are absent.

## Completion

An understandable module/API arrangement with consumers and compatibility checked. If ownership is not established, use architecture-review first.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
