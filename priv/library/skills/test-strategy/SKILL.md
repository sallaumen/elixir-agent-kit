---
name: test-strategy
description: "Use when a passing suite misses important bugs, the required regression coverage is unclear, or duplicated tests protect nothing distinct."
---

# Test Strategy

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a bug shipped through a green suite, when a change touches authorization, concurrency, persistence or an external contract and nobody can say which test would catch a regression, when a new feature needs its tests chosen, or when a test exists but it is not clear what it protects. Use it before writing the tests, not after.

The output is a short list of risks, each with the cheapest test that can observe it failing, and the tests themselves.

## Inputs to inspect

- Start at: the test directory for the changed module and `mix test --cover` on it, to see which existing tests reach the boundary and what they leave unreached.
- The changed behavior and its public contract: the function, endpoint, LiveView event, job or message that a caller depends on.
- Likely failure modes, ranked by consequence: wrong result, unauthorized access, lost or duplicated write, race, silent failure, broken compatibility with stored data.
- Existing tests around the boundary: what they assert, what fixtures they build, whether any of them would fail if the behavior broke.
- The test environment: sandbox, `async` settings, fakes for external services, time control, and the cost of a full run. See [ExUnit and diagnostics](../../elixir/exunit.md).

## Workflow

1. List the behaviors that can break, one line each: trigger, wrong outcome, who notices. Rank by consequence and likelihood using real incidents and the code paths that exist, not a generic checklist.

2. For each risk choose the smallest seam that can observe the failure: a pure function for a calculation, the context function for a rule, the persistence boundary for constraints and races, the LiveView or controller for authorization and rendering, an integration test only where mocks would hide a contract mismatch.

3. Write each test from an independent oracle: a known-good literal, a worked example, the spec, a stored fixture. If the expected value is computed the way the code computes it, the test cannot disagree with the code; rewrite it.

4. Control what makes failures intermittent: time (inject the clock), concurrency (send the messages yourself, assert with `assert_receive` and a bounded timeout), persistence (sandbox per test), external responses (a behaviour with `Mox`, plus one real contract check where authorized), global configuration (save and restore application env in `on_exit/1`; `async: false` only for the module that changes it) and background processes (stretch their interval in the test config and call the tick yourself). See [ExUnit and diagnostics](../../elixir/exunit.md).

5. Prove that a regression test reaches the behavior: run it against the unfixed code, or against a one-line mutation of the contract, and watch it fail. Record that run. If it cannot be made to fail, it protects nothing; replace it.

6. Run the focused tests, then the project gate. Report the risks covered, the tests added, and the risks left uncovered with the reason.

## Decision points

- Cheapest observing seam first; add a slower integration test only for an interaction the cheaper seam cannot see (query shape, constraint, authorization plug, serialization).
- Success, denial, failure and retry are selected by risk, not by quota. A boundary with no denial path needs no denial test; an authorization boundary with only a success test is untested.
- Fixtures use the production contract (the same changeset, the same factory the app uses); a fixture that bypasses validation tests a state the application cannot reach.
- Keep one real contract check for an external provider when the session authorizes it and a safe path exists; otherwise fake it and say the provider's behavior is assumed, not verified.
- A test that must be rewritten after a refactor that preserved behavior was coupled to implementation; move it to the public seam.
- A pure function with an invariant (a parser and its printer round trip, an ordering, idempotence) gets a property test with generated inputs when the project has `StreamData`; examples alone pin only the cases someone thought of. LiveView tests assert on elements by DOM id (`has_element?/2`), not on raw HTML.

## Quality criteria

- Each test names the risk it protects in its description and asserts an observable result at a public seam.
- Expected values come from an independent source; no assertion recomputes the result the way the code does.
- Tests run in any order and in parallel where the sandbox allows, with no sleeps, no shared mutable state, no outside network.
- Every regression test has been seen failing once; the handoff says where.
- The suite's cost grew in proportion to the risk covered, not to the number of assertions.

## Validation and evidence

- Minimum: output of the failing run (unfixed code or a one-line mutation) and of the passing run for the new test.
- When turns allow: the risk list with the chosen seam per risk, and the mapping from each new test to the behavior it protects.
- When turns allow: the focused suite and the project gate, with skips, fakes and unverified provider behavior named.

## Removing duplicates

The risk list also shows which existing tests protect nothing distinct. Remove or merge one duplicate at a time, only where two tests detect the same regression at the same seam; keep separate coverage for distinct paths, roles, retries or failure mechanisms even when the fixtures look alike. The surviving test states its oracle and still fails when the contract breaks: when that is in doubt, make a one-line mutation and watch it fail. Run the focused suite and record any coverage dropped on purpose and why the remaining tests still catch the regression.

## Avoid

- Do not write tests that mirror the implementation line by line or that assert on private functions.
- Do not accept a tautological assertion, a snapshot nobody read, or a mock expectation as proof of behavior.
- Do not raise coverage with redundant assertions on the same path; one test per distinct failure mode.
- Do not use `Process.sleep` or a longer timeout to stabilize a race; make the ordering explicit.
- Do not claim a regression is covered by a test that never failed.
- Do not delete the only failure-path check to speed up a suite, or replace several assertions with one snapshot that misses the important condition.

## Completion

A ranked risk list, one test per risk at the cheapest observing seam, each seen failing before passing, duplicates that protected nothing distinct removed, and the remaining gaps stated. For a failure with no known cause use [debugging](../debugging/SKILL.md) first.

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
