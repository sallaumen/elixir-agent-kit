# Architecture review: choosing where to start

This round removes the named consumer from the [previous discovery test](2026-11-13-architecture-discovery.md). The only application symptom was “changing only a comment in a color utility recompiles dozens of files.” Both reviewers were asked what to investigate or change first and why. No paths, counts, candidate consumers, commands, graph output or previous answers were supplied.

Two fresh Codex CLI 0.162.1 sessions (GPT-6.1-Sol, medium) used the unmodified guide at aa186fc, with separate writable snapshots of the same pre-fix application revision. Each had an offline Mix launcher, source and warm test build (Elixir 1.19.5 / OTP 27.3.4.11). Neither needed Cyclops. Temporary edits for measurement were allowed; implementation, service startup and delivery were out of scope. The earlier round used GPT-6-Sol and read-only sessions: the difference between rounds is not a controlled estimate of the effect of removing a clue.

Before seeing either answer we chose to assess the first priority, its mechanism, alternative explanations and marginal savings on the actual warm build. Picking the previously named consumer was not a pass criterion.

## Independent compiler check

A third checkout used the normal Mix compiler: no source files compiled on a warm no-op; editing only the comment rebuilt 46, and restoring it rebuilt the same 46. All ten direct callers of the utility had runtime edges. A static registry, however, pulled a concrete adapter into its module-body validation; schemas and other consumers then compile against the registry. In this build the trace distinguishes the runtime adapter literal from the compile reference when the module attribute is expanded by the validator.

To isolate this edge, the evaluator temporarily substituted an inert atom for the adapter and warmed the build before repeating the identical comment edit. Exactly 19 files left the build set, with none added: **46 → 27**. This probe deliberately cannot serve the adapter at runtime. It measures removing the dependency altogether, not merely changing its label to runtime; it is not a viable patch. For comparison, the previously named display component had independently accounted for one file (**46 → 45**). Neither count measures wall time.

## What the reviewers chose

| Fresh session | First priority and competing hypothesis | Completed shell calls / output tokens |
|---|---|---:|
| A | Separate the static catalog from adapter dispatch. Moving the display calculation to render and removing the catalog's validation loop each saved one file in separate experiments. Disabling adapter registration saved 19. | 34 / 9,713 |
| B | Same boundary. Moving the whole catalog construction to a function saved one file; disabling registration saved 19. Ranked the display component lower from the graph and traced the questionnaire submission contract. | 28 / 8,470 |

Both distinguished the 779 → 646 change in size of a compile-connected group from the 46 → 27 change in the **actual build**. Both identified the behavioral regression in the diagnostic and kept the proposed boundary split conditional. Source bytes were checked after both sessions. The counts above are client events, not a timing or cost benchmark.

One explanation needs qualification. B's shortest illustrated path included an export dependency. The edge exists, but a comment does not change the exported API, so the illustration alone does not explain invalidation. The evaluator verified a parallel path from the adapter through a query module to a schema and then the utility, with all three edges labeled runtime. The proposed priority stands on the controlled interventions, not on the shortest graph path. Nor does “adapter dispatch at runtime” by itself guarantee 19 fewer rebuilds: compile consumers must stop reaching the concrete implementation through the catalog.

**Decision:** keep the workflow unchanged. It prioritized the higher-impact investigation in both runs; one imperfect causal explanation is a useful grading case, not enough to justify changing the default review. A production candidate would need to preserve catalog validation, questionnaire behavior and a single source for area metadata, then repeat the warm measurement against that candidate. The remaining 27 files and wall-clock impact are separate questions.
