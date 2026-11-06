# Live evaluation: Claude Code, 2026-11-06

This is the first fresh-session evidence for the kit. It measures whether a real
client discovers, reads and applies a workflow; nothing here is inferred from the
structural checks. Transcripts are kept outside the repository; the tables below
are extracted from them mechanically (tool calls and final answers), with the
judgment calls marked as such.

## Setup

| Item | Value |
|---|---|
| Consumer | agent-board `main` `55ed515`, Elixir Agent Kit v0.5.0, `skills: :all`, adapters codex, claude, generic |
| Client | Claude Code CLI 2.1.311, model `claude-opus-4-8` (CLI default), `claude -p`, one fresh session per run, `--no-session-persistence` |
| Context loaded | Project `CLAUDE.md` (kit block importing `AGENTS.md`), the generated `.claude/skills/elixir-agent-kit` (listed in every session's `skills`), and the operator's global `~/.claude/CLAUDE.md`. `--setting-sources project` excluded user settings, plugins and MCP servers but did not exclude the global instructions file, so every run also carried the operator's rule to resolve skills through `mcptoon` first. |
| Permissions | `--permission-mode acceptEdits`; Bash allowed only for read-only git, grep, `mix test`, `mix compile`, `mix format`, `mix credo`, `mix deps.get`, `mix agent_kit.check`; `git push`, `gh`, `git commit`, `mix ecto.reset`, `mix ecto.drop`, `rm` denied; `--max-turns 40`, `--max-budget-usd 3` |
| Prompts | The routing case text plus one sentence naming the screen or diff, plus "list the files you read and the workflow you chose" |
| Repetitions | 3 per case, each in its own disposable worktree reset between runs (`deps/` and `_build` kept) |
| Cases | E12 (code-review, read-only), E30 (accessibility), E32 (async-state), E18 (NONE), E44 (provider-calls), E05 (layout-density, alternative responsive-layout) |

Cost of the 18 main runs: about 42 USD; five runs stopped at the budget cap after
the routing decision and before finishing the work.

## Results per run

"Read from kit" lists the kit files the session opened (by `Read` or `cat`);
"Routed" compares the `SKILL.md` it read with `expected_primary` (ok), an allowed
alternative (alt), another workflow (wrong) or none. "Skill tool" means the session
invoked the generated `elixir-agent-kit` skill through the Skill tool. "Maintainer
contract read" is the proof that `@AGENTS.md` reached the session, since only
`AGENTS.md` names that document.

| Run | Expected | Read from kit | Routed | Skill tool | Edits | mix test | Maintainer contract read | Ended | Cost (USD) |
|---|---|---|---|---|---|---|---|---|---|
| E05-r1 | layout-density | START, CONTRACT, ROUTING, responsive-layout | alt | no | 0 | no | no | finished | 2.72 |
| E05-r2 | layout-density | CONTRACT, ROUTING, responsive-layout | alt | yes | 0 | no | no | finished | 2.20 |
| E05-r3 | layout-density | START | none | no | 0 | no | no | finished | 2.48 |
| E12-r1 | code-review | START, ROUTING, code-review, motion-design | ok | no | 0 | no | no | finished | 1.55 |
| E12-r2 | code-review | START, CONTRACT, ROUTING, code-review | ok | no | 0 | no | no | finished | 1.11 |
| E12-r3 | code-review | START, CONTRACT, ROUTING, code-review | ok | no | 0 | no | no | finished | 1.65 |
| E18-r1 | NONE | nothing | ok | no | 1 | no | no | finished | 0.18 |
| E18-r2 | NONE | nothing | ok | no | 1 | no | no | finished | 0.22 |
| E18-r3 | NONE | nothing | ok | no | 1 | no | no | finished | 0.23 |
| E30-r1 | accessibility | START, CONTRACT, accessibility | ok | yes | 7 | yes | yes | budget cap | 3.09 |
| E30-r2 | accessibility | START, CONTRACT, accessibility | ok | yes | 7 | no | no | budget cap | 3.01 |
| E30-r3 | accessibility | START, CONTRACT, accessibility | ok | yes | 2 | yes | no | finished | 3.00 |
| E32-r1 | async-state | START, ROUTING, async-state | ok | no | 0 | no | yes | budget cap | 3.17 |
| E32-r2 | async-state | nothing | none | no | 0 | yes | yes | budget cap | 3.10 |
| E32-r3 | async-state | nothing | none | no | 0 | yes | yes | finished | 2.92 |
| E44-r1 | provider-calls | nothing | none | no | 2 | yes | yes | budget cap | 3.09 |
| E44-r2 | provider-calls | START, CONTRACT, ROUTING, provider-calls | ok | no | 3 | yes | yes | finished | 2.92 |
| E44-r3 | provider-calls | nothing | none | no | 0 | yes | yes | finished | 3.00 |

## Results per case

| Case | Expected | Routed correctly | Reached the kit at all | Read the maintainer contract | Hit the budget cap |
|---|---|---|---|---|---|
| E12 code review, read-only | code-review | 3/3 | 3/3 | 0/3 | 0/3 |
| E30 LiveView form accessibility | accessibility | 3/3 | 3/3 | 1/3 | 2/3 |
| E05 oversized buttons, ultrawide | layout-density (alt responsive-layout) | 2/3 as the allowed alternative, 1/3 none | 3/3 | 0/3 | 0/3 |
| E18 swap one icon | NONE | 3/3 | 0/3 (correct) | 0/3 | 0/3 |
| E32 late message after reconnect | async-state | 1/3 | 1/3 | 3/3 | 2/3 |
| E44 empty AI answer, double charge | provider-calls | 1/3 | 1/3 | 3/3 | 1/3 |

Mode: none of the six read-only reviews (three here, three in the no-deps control)
edited a file. E18 finished in under 25 seconds each time at about 0.20 USD without
touching the kit, which is the intended behavior for a bounded edit.

## What the transcripts show (judgment)

1. **Discovery works through `CLAUDE.md` → `START.md`, and the pointer skill is live.** The
   generated `elixir-agent-kit` skill appears in the `skills` list of every session's
   init event, and five main runs plus one control invoked it through the Skill tool
   (E05-r2, E30-r1, E30-r2, E30-r3, E12-r1 no-deps). No session opened the pointer
   file with `Read`; the Skill tool loads it. Frontend and review cases reached the
   catalog in 9 of 9 runs.

2. **For backend symptoms the project's own contract outranks the kit.** All six E32 and
   E44 runs opened `docs/maintainer-contract.md` first, because `AGENTS.md` says to
   read it before changing behavior, and four of the six never looked at the kit. The
   kit block sits at the end of `AGENTS.md` and reads as optional ("For development
   tasks, consult…"). The `@AGENTS.md` import demonstrably reached every one of those
   sessions, so the fix is ordering and wording, not discovery: a consumer can name the
   kit workflow selection inside its "Required contracts" list, and the generated block
   can say "before changing behavior, select one workflow" instead of "consult".

3. **The operator's global instructions compete with the kit.** The global
   `~/.claude/CLAUDE.md` was loaded in every run. E05-r3 spent its first turns on
   `mcptoon skills resolve` and the operator's anti-slop playbooks and never opened a
   `SKILL.md`; E05-r1, E05-r2 and E30-r1 also read `~/.agents/skills/playbook-*`. This
   confirms the audit's finding that two skill sources exist on this machine. It is an
   operator-environment effect, not a kit defect, and it will not reproduce on a machine
   without that rule.

4. **Routing quality where the kit was read was good.** E12 picked `code-review` 3/3
   and E12-r1 and E12-r2 (no-deps) added `motion-design` as the domain lens for a motion
   PR, which the routing guide allows. E05 picked `responsive-layout` for an ultrawide
   complaint, the listed alternative. E44-r2 and E32-r1 picked the expected workflow
   after reading `ROUTING.md`.

5. **Validation criteria were visible where the run finished.** E30-r3 fixed the
   create-task panel, ran the LiveView suite (61 tests) and named the unexercised
   browser and screen-reader pass, which is exactly what the `accessibility` workflow
   asks for in its completion. E44-r2 read `provider-calls`, changed three files and ran
   tests. Runs that hit the budget cap cannot be scored for completion; the cap should
   be 5 USD or the prompt should ask for a bounded plan first.

## Controls

### E12 in a clone without `deps/`

| Run | What happened |
|---|---|
| r1 | Read `START.md`, found the links dead, said so, ran `mix deps.get` (allowed), then read the contract and `code-review`, reviewed read-only, and reported the fetch in its answer. This is the behavior the block asks for. |
| r2 | Contaminated: r1's fetch left `deps/` in place, so this was a normal run (routed to `code-review`). Discarded. |
| r3 | Also ran with `deps/` present, yet its answer asserted that the dependency "was not fetched in this worktree" and that it had not read the workflow body, which was false for the fetch and true for the body. A model can report a missing dependency without checking; the block's "report the missing setup" instruction does not prevent an inaccurate report. Discarded for the no-deps question, kept as a finding. |

Only r1 is a valid no-deps observation. Repeat with a fresh clone per repetition
before drawing a rate.

### E30 and E32 without the kit (block and pointer skills removed, `@AGENTS.md` kept)

The control removed the kit block from `CLAUDE.md` and `AGENTS.md` and the two
pointer skills, keeping `@AGENTS.md` and the dependency in `deps/`. Two repetitions
per case.

| Run | Read from kit | Edits | mix test | Maintainer contract read | Ended | Cost (USD) |
|---|---|---|---|---|---|---|
| E30-r1 | CONTRACT, accessibility (found through the README and `docs/agent/practices.md`, which still name `START.md`) | 6 | no | no | finished | 2.96 |
| E30-r2 | nothing; worked from `AGENTS.md`, `docs/ui-motion.md` and the operator's playbooks | 5 | yes | yes | finished | 2.74 |
| E32-r1 | nothing | 0 | yes | yes | budget cap | 3.16 |
| E32-r2 | nothing | 0 | no | yes | budget cap | 3.09 |

With the block and pointer present, E30 reached the kit 3/3 and E32 1/3; without them,
1/2 and 0/2. The block and pointer therefore change behavior for the frontend case,
while the backend case is dominated by the maintainer contract in both arms. The
operator's global rule also fired here: both E30 controls attempted `mcptoon skills
resolve` before anything else.

## Retest after the consumer reordered `AGENTS.md`

agent-board#261 placed "select one Elixir Agent Kit workflow" directly under the
maintainer contract in "Required contracts" (the kit block itself still carried the
v0.5.0 wording; kit#17's new wording is unreleased). Same client, prompts, permissions
and 3 USD cap; two repetitions of the two backend cases in fresh worktrees.

| Run | Read from kit | Routed | Edits | mix test | Maintainer contract read | Ended | Cost (USD) |
|---|---|---|---|---|---|---|---|
| E32-r1 | START, CONTRACT, async-state | ok | 7 | yes | yes | turn cap | 3.00 |
| E32-r2 | nothing | none | 7 | yes | yes | budget cap | 3.05 |
| E44-r1 | START, CONTRACT, ROUTING, provider-calls | ok | 5 | yes | yes | budget cap | 3.03 |
| E44-r2 | START | none | 2 | no | yes | budget cap | 3.10 |

Before the reorder these two cases reached the kit in 2 of 6 runs and routed
correctly in 2 of 6; after it, 3 of 4 and 2 of 4. Every run still opened the
maintainer contract first, and every run hit a cap, so this is a direction, not a
rate: four runs cannot separate the reorder from noise. The next measurement should
use the released block wording, a 5 USD cap, and at least three repetitions.

## Rerun with the released v0.5.1 wording and a 5 USD cap

agent-board `main` `caea500` (kit v0.5.1: block and pointer skills say "before changing
behavior or reviewing code, select one workflow…, even when a local contract already
covers the area"; the `AGENTS.md` ranking from #261 kept). Same client, prompts and
permissions; `--max-budget-usd 5`; three repetitions of the six cases in three fresh
worktrees, run 14:19–15:23 local time. Total cost 59.96 USD.

| Run | Expected | Read from kit | Routed | Skill tool | Edits | mix test | Maintainer contract read | Ended | Cost (USD) |
|---|---|---|---|---|---|---|---|---|---|
| E05-r1 | layout-density | START, ROUTING, responsive-layout | alt | no | 1 | no | yes | finished | 4.44 |
| E05-r2 | layout-density | START, CONTRACT, ROUTING, responsive-layout | alt | no | 5 | no | no | finished | 4.10 |
| E05-r3 | layout-density | CONTRACT, responsive-layout | alt | yes | 1 | no | no | finished | 3.46 |
| E12-r1 | code-review | START, CONTRACT, code-review | ok | no | 0 | no | no | finished | 1.66 |
| E12-r2 | code-review | START, code-review | ok | no | 0 | no | no | finished | 2.14 |
| E12-r3 | code-review | CONTRACT | none | no | 0 | no | no | finished | 1.86 |
| E18-r1 | NONE | nothing | ok | no | 1 | no | no | finished | 0.19 |
| E18-r2 | NONE | nothing | ok | no | 1 | no | no | finished | 0.22 |
| E18-r3 | NONE | nothing | ok | no | 1 | no | no | finished | 0.22 |
| E30-r1 | accessibility | CONTRACT, ELIXIR, accessibility | ok | yes | 4 | yes | yes | finished | 4.55 |
| E30-r2 | accessibility | CONTRACT, accessibility | ok | yes | 3 | yes | yes | finished | 3.65 |
| E30-r3 | accessibility | START, CONTRACT, accessibility | ok | yes | 8 | yes | no | finished | 3.63 |
| E32-r1 | async-state | START, CONTRACT, ROUTING, async-state | ok | no | 1 | yes | yes | budget cap | 5.01 |
| E32-r2 | async-state | START, CONTRACT, ROUTING, async-state | ok | no | 2 | yes | yes | budget cap | 5.03 |
| E32-r3 | async-state | START | none | no | 3 | yes | yes | budget cap | 5.02 |
| E44-r1 | provider-calls | nothing | none | no | 6 | yes | yes | turn cap | 4.83 |
| E44-r2 | provider-calls | START, CONTRACT, ROUTING, provider-calls | ok | no | 7 | yes | yes | budget cap | 5.04 |
| E44-r3 | provider-calls | START | none | no | 2 | yes | yes | finished | 4.92 |

| Case | Routed correctly (v0.5.0 → v0.5.1) | Reached the kit (v0.5.0 → v0.5.1) | Read the maintainer contract | Hit a cap |
|---|---|---|---|---|
| E12 code review, read-only | 3/3 → 2/3 | 3/3 → 3/3 | 0/3 | 0/3 |
| E30 LiveView form accessibility | 3/3 → 3/3 | 3/3 → 3/3 | 2/3 | 0/3 |
| E05 oversized buttons, ultrawide | 2/3 alt → 3/3 alt | 3/3 → 3/3 | 1/3 | 0/3 |
| E18 swap one icon | 3/3 → 3/3 (none, correct) | 0/3 → 0/3 | 0/3 | 0/3 |
| E32 late message after reconnect | 1/3 → 2/3 | 1/3 → 3/3 | 3/3 | 3/3 |
| E44 empty AI answer, double charge | 1/3 → 1/3 | 1/3 → 2/3 | 3/3 | 2/3 |

What changed and what did not:

- The two backend cases now reach the kit in 5 of 6 runs (2 of 6 before) and route
  correctly in 3 of 6 (2 of 6 before). Every backend run still opened the maintainer
  contract first; the new wording gets the session to `START.md` afterwards, but two of
  the five that got there (E32-r3, E44-r3) stopped at `START.md` and went to the code
  without opening a `SKILL.md`. The miss is now inside the kit's entry point, not before it.
- E44-r1 never touched the kit: it read the maintainer contract, then fourteen source
  files, and hit the turn cap mid-edit. E44-r3 finished with a correct fix and two new
  tests from the maintainer contract alone, which is the case E46 was written for: the
  local contract was enough to act, so the workflow was skipped.
- The frontend and review cases hold: E30 3/3 through the Skill tool every time, E05 3/3
  on the allowed alternative, E18 0 kit reads at about 0.20 USD. E12 lost one run
  (E12-r3 read the shared contract through `docs/ui-motion.md` and reviewed without the
  `code-review` workflow; its review was read-only and found nothing wrong).
- The 5 USD cap still truncated all three E32 runs and two E44 runs; the first lasted
  13 to 18 minutes each. Routing happened before the cap in every capped run that routed,
  so the cap affects the judgment of the fix, not the routing measurement.
- E05-r3 reached the kit through the pointer skill directly (Skill tool, no `START.md`)
  and also loaded two of the operator's global skills (`playbook-antislop`,
  `playbook-unslop`): the operator's `~/.claude/CLAUDE.md` is still in these sessions.

Reading: the wording change and the `AGENTS.md` ranking together moved the backend cases
from "kit not reached" to "kit reached, workflow sometimes not opened". The next lever is
`START.md` itself (a session that opens it should leave it with one `SKILL.md` path in
hand), and the next measurement should run on a machine without the operator's global
instructions.

## Limits

- One client, one model, 18 runs plus controls and the 18-run rerun on v0.5.1, on the operator's machine with the
  operator's global instructions present. Codex and the DeepSeek executor were not
  evaluated.
- "Routed" is measured by which `SKILL.md` was opened, not by whether its criteria were
  followed; the judgment section covers that for finished runs only.
- The budget cap truncated five runs; routing happened before the cap in all of them.
- Prompts added one sentence of project context to the routing case text so the task
  had a target; the case text is otherwise unchanged.

## Follow-ups this suggests

Items 1 to 3 below shipped on the same day (agent-board#261, kit#17, case E46, kit
v0.5.1) and the rerun above measures them.

1. Done. Consumer (agent-board): move the kit selection into the "Required contracts"
   list of `AGENTS.md`, so backend symptoms meet the kit before the maintainer contract.
2. Done. Kit: reword the generated block from "consult" to "before changing behavior,
   select one workflow", with the same wording in the pointer skill's description.
3. Done. Kit: add a routing case for a request that names a local contract first.
4. Kit: make `START.md` end with the workflow choice, so a session that opens it leaves
   with one `SKILL.md` path; two backend runs stopped at `START.md`.
5. Evaluation: a fresh clone per no-deps repetition; the same matrix on a machine
   without the operator's global skill rule, and on Codex and the DeepSeek executor.
