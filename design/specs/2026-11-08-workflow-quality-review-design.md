---
status: proposed
date: 2026-11-08
tags: [workflows, quality, review, elixir]
---

# Quality review of the 38 workflows

## Problem

The workflows were deepened over several releases and now each has task-specific
inputs, decisions, quality criteria and evidence. No single pass has checked all
38 against the current Elixir, Phoenix, Ecto and Oban versions and against the
shared contract, so small drift can accumulate: an obsolete command, a step whose
completion is not observable, a trigger that overlaps a neighbor, mechanics
copied instead of pointing at an `elixir/*.md` reference, or advice that
contradicts `CONTRACT.md`. This front applies one written yardstick to every
workflow, fixes what it finds, and strengthens the machine checks that can catch
regression.

This is the second 1.0 front. It runs after front 1 (size guides) because both
edit the same `SKILL.md` bodies, and it reads the new `## Size` sections as part
of the review.

## The yardstick

Every workflow is judged against six checks, in order:

1. **Current Elixir and commands.** Every command, API and library name is
   correct for Elixir 1.15+ through 1.19/1.20, Phoenix 1.8, Ecto, Oban and
   Broadway as locked. Examples of the kind of drift to catch: `mix xref
   callers` (rejected in 1.19, use `mix xref graph --sink`), `Repo.transaction/2`
   for multi-write steps (use `Repo.transact/2` or `Ecto.Multi`), or a LiveView
   test asserted on raw HTML instead of DOM ids.
2. **Observable completion.** Each workflow step ends in a `Done when` condition
   a reviewer could check, not a vague "review it" or "improve it".
3. **Distinct trigger.** The "When to use" trigger and its separating rule
   distinguish this workflow from every neighbor named in the same area, without
   overlapping scope.
4. **Point, don't repeat.** Mechanics that already live in an `elixir/*.md`
   reference are pointed at, not restated inline, unless the workflow needs the
   exact rule at the decision point.
5. **Contract coherence.** Nothing authorizes changing persisted data, a public
   contract or scope without the stop-and-ask trigger; behavior preservation and
   approval rules match `CONTRACT.md`.
6. **Size adaptation.** The `## Size` section is specific to the workflow, does
   not restate the contract, and matches its steps and neighbors.

## Fixes and machine checks

Each finding is fixed in the same pass, one workflow at a time, with no unrelated
refactor. `scripts/check_library.py` is strengthened only where a rule can be
checked by machine without false positives; candidates are a grep for known
obsolete commands in `priv/library/` and a check that every `elixir/*.md`
reference is indexed in `ELIXIR.md`. Findings from Linha B are fixed first.

## Delivery

One pull request, then release 0.10.0. A written record of every finding and its
fix goes in the PR; nothing is silently changed.

## Out of scope

Frentes 1 and 4, live evaluations, and new workflows.
