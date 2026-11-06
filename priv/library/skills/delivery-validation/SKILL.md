---
name: delivery-validation
description: "Use when checking whether an integrated change actually satisfies its acceptance criteria."
---

# Delivery Validation

Default mode: **analyze**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when checking whether an integrated change actually satisfies its acceptance criteria.

## Inputs to inspect

- Requested user outcome, changed files, required repository gates and release or deployment target.
- Manual flows, docs, generated artifacts and downstream consumers that the change affects.

## Workflow

1. Read the requested outcome, scope and acceptance criteria. Identify the exact revision and changes being validated.

2. Choose evidence proportional to the changed risk: tests, integration exercises, browser flows or artifact inspection. Check at least the critical completion path and relevant failure/recovery behavior.

3. Compare the integrated result with the mandate, not only a worker's report. Separate inspected, simulated, executed, published and unverified claims.

4. Report passed, failed, blocked and deferred criteria with reproducible evidence. Do not silently switch from validation to repair, publish, merge or deploy without the necessary authority.

## Decision points

- Pick checks that prove the requested behavior and required contracts, then stop when remaining risk is clearly stated.
- Separate merged, released, installed and actually observed-in-use states.

## Quality criteria

- The final evidence links each acceptance condition to a check or a clearly stated limitation.
- A versioned package is tagged and installable from the documented reference before consumer pins are updated.
- Documentation, examples and generated indexes match the shipped code.
- The handoff names any external action or monitoring that still has to occur.

## Validation and evidence

- Run required project gates plus a representative end-to-end or consumer smoke path when distribution changes.
- Check final commit, tag, PR merge and consumer version pins from the integrated state.

## Avoid

- Do not claim live agent compliance from repository structure alone.
- Do not leave a release described as complete when consumers still point at the old version.

## Completion

A precise acceptance assessment and handoff. A passing test suite alone does not prove every requested behavior was delivered.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
