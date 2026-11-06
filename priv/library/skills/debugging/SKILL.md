---
name: debugging
description: "Use when a wrong result, exception or intermittent failure has no demonstrated root cause."
---

# Debugging

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a wrong result, exception or intermittent failure has no demonstrated root cause.

## Inputs to inspect

- Observed symptom, exact error or wrong output, occurrence time, environment and a minimal reproduction if available.
- Recent changes, logs, traces, persisted state and the path from entry point to effect.

## Workflow

1. Capture the symptom, expected behavior and conditions needed to reproduce it. Establish whether the failure is current and distinguish it from unrelated baseline problems.

2. Form a small set of competing hypotheses. Use logs, traces or targeted experiments that discriminate among them, avoiding broad changes that hide the cause.

3. Trace the failing value or transition to its owner. Fix the responsible boundary and preserve the intended error behavior.

4. Verify the original reproduction and add a meaningful regression test when justified. Record untested intermittent conditions and the evidence supporting the root cause.

## Decision points

- Form competing hypotheses and select the next observation that most efficiently distinguishes them.
- Separate root cause, trigger and downstream symptom before changing code.

## Quality criteria

- The fix addresses the mechanism at the owning layer and preserves neighboring behavior.
- Logs and diagnostic output avoid secrets and identify correlation IDs or boundaries needed to trace the case.
- A regression check reproduces the original symptom before the fix and passes afterward when feasible.
- The explanation states why this case happened and what remains unknown.

## Validation and evidence

- Capture a failing trace or minimal fixture, then repeat it after the change.
- Run the focused regression and any adjacent check justified by the blast radius.

## Avoid

- Do not patch the first stack frame without tracing the source of its bad input.
- Do not turn an intermittent failure into a longer arbitrary sleep.

## Completion

A reproduced failure, supported causal explanation and verified correction, or a precise blocker and next diagnostic step.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
