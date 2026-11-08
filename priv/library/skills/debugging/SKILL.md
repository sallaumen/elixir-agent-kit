---
name: debugging
description: "Use when a wrong result, exception or intermittent failure has no demonstrated root cause."
---

# Debugging

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a test fails with an exception or a wrong value and nobody has shown why; when a request returns a wrong result for one record but not another; when a failure appears only under a particular `--seed` or only in CI; when a log line reports an error with no matching code path in the obvious place; or when a fix was applied and the symptom came back.

This workflow applies only when no area workflow names the symptom. A stale or duplicated asynchronous result that overwrites current state is [async-state](../async-state/SKILL.md). A GenServer, Task or poller that leaks, blocks callers or behaves differently after a restart is [process-lifecycle](../process-lifecycle/SKILL.md). A build or test run that differs by environment, OTP version or cache is [build-dependencies](../build-dependencies/SKILL.md). A measured slow path with a correct result is [performance](../performance/SKILL.md). Route there first; come back here when the symptom survives the routing.

## Size

- **Small**: reproduce one failing test, confirm one hypothesis and fix at the owner with one regression test; skip the full hypothesis table.
- **Medium**: run the workflow as written for one intermittent failure: the reproduction, the hypothesis table and the fix at the owner.
- **Large**: a failure across a whole path or several environments; slice per boundary, and route an environment difference to build-dependencies or a stale async result to async-state.

## Inputs to inspect

- Start at: the failing test, log line or reproduction, then `mix test path:line` (add `--seed N` from the failing run, `--trace` if it hangs). See [ExUnit and diagnostics](../../elixir/exunit.md).
- The exact error and stack trace: the innermost frame in project code and the value it received, not only the frame that raised.
- The path from entry point to effect: router or job, context function, query, persisted result; and which boundary owns the wrong value.
- Recent changes to the files on that path (`git log -p` on them) and whether the failure predates them.
- Persisted state the reproduction depends on: fixtures, seeds, sandbox ownership, a row that exists in one environment only.
- Any correlation id (request id, job id, `Logger.metadata`) that links the log line to the code path.

## Workflow

1. Reproduce. Run the failing test or replay the request, and write the reproduction as a command plus the observed and expected output. If it fails only sometimes, run `mix test path:line --repeat-until-failure 50` and record the failing seed. Then write a hypothesis table: hypothesis, the observation that would confirm it, the observation that would rule it out. Done when the reproduction fails on demand and the table has at least two rows.

2. Pick the observation that separates the most hypotheses and make it: `dbg/1` or `IO.inspect(label:)` at the boundary, `:sys.get_state/1` on a process, a query logged with its params, `:observer` for a mailbox or memory shape. Done when at least one row is ruled out and the table is updated.

3. Repeat step 2 until one hypothesis remains or the table is empty. If empty, widen the inputs (adjacent boundary, earlier change) and add rows; do not widen the code change. Done when one row is confirmed by an observation, not by reasoning alone.

4. Trace the confirmed mechanism to its owner: the function or boundary that produced the bad value, not the frame that crashed on it. Separate root cause, trigger and downstream symptom in writing. Done when the owning line is named.

5. Write the regression test first and watch it fail for the reported reason. Then fix at the owner, preserving the intended error behavior for other inputs. Done when the new test passes and the original reproduction passes.

6. Remove diagnostic output, run the tests for the changed module and the project gate, and record what remains unknown (an intermittent path not exercised, an environment not available). Done when the gate is green and the unknowns are written down.

## Decision points

- One observation at a time, chosen to split the hypothesis table; a change that tests two hypotheses proves neither.
- The owner of the bad value is where the fix goes; a guard at the crash site is a workaround and is labeled as one.
- An intermittent failure is a seed or an ordering until proven otherwise; `--seed` and `--repeat-until-failure` come before any code change.
- If the symptom matches an area workflow after reproduction, stop and route there with the reproduction attached.
- A regression test that cannot be shown failing before the fix is reported as such, not presented as proof.

## Quality criteria

- The reproduction is a command anyone can run, with the seed when order matters.
- The hypothesis table records which observation ruled out each row.
- The fix is at the owning boundary and preserves neighboring behavior; the diff is as small as the mechanism.
- Diagnostic output is gone from the committed change; logs that stay carry a correlation id and no secrets.
- The explanation says why this case happened and what is still unknown.

## Validation and evidence

- Minimum: the regression test at `path:line` that failed before the fix and passes after, with the failing seed when the failure was order-dependent.
- When turns allow: the project gate (`mix test`, `precommit` or the project's alias) after the fix.
- When the failure was intermittent: `mix test path:line --repeat-until-failure N` green after the fix, with N stated.
- When the symptom came from a log line: the same request or job replayed with its correlation id and the log now clean.

## Avoid

- Do not patch the first stack frame without tracing the input to its owner.
- Do not turn an intermittent failure into a longer sleep or a retry; find the ordering.
- Do not change two things between observations.
- Do not investigate a symptom another workflow names; route it with the reproduction.
- Do not leave `dbg/1` or `IO.inspect` in the change.

## Completion

A reproduction that fails on demand, a hypothesis table showing which observation confirmed the cause, a fix at the owning boundary and a regression test that failed before it; or a precise blocker with the next discriminating observation. For a stale result in the view use [async-state](../async-state/SKILL.md); for a process that misbehaves after restart use [process-lifecycle](../process-lifecycle/SKILL.md); for a failure that differs by environment use [build-dependencies](../build-dependencies/SKILL.md); for the coverage the fix exposed as missing use [test-strategy](../test-strategy/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
