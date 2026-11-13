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

## Production follow-up

| Warm comment edit | Before | After | Change |
|---|---:|---:|---:|
| Earlier diagnostic: disable the adapter | 46 | 27 | 19 fewer |
| Production correction: keep the adapter enabled | 45 | 26 | 19 fewer |

The later baseline already included the independent one-file display fix.
The shipped change kept a single catalog for area metadata and port selection.
Build configuration supplies the concrete adapter module; consumers that compile
against the catalog no longer take a dependency on its implementation. The
questionnaire still blocked admission for missing or stale answers, accepted a
fresh answer and was skipped only where the catalog declared no port.

The original and corrected warm no-ops rebuilt nothing. Inserting and restoring
the same comment reproduced each file set. Comparing lists removed the registry,
12 discovery sources and six UI consumers, with no new files. After the base
advanced, the integration tree reproduced the same 19-file difference. These
are counts of compiled sources, not wall-clock measurements.

The application suite passed 18,255 tests (89.7% coverage) on the original
candidate base; 193 affected tests passed on the final integration tree.
The deployed image passed its machine check and the public health endpoint.
Private application code, identifiers and transcripts stay out of this report.

**Pilot closed.** Keep the corrected xref explanation. Both unnamed-consumer
reviews prioritized the higher-impact boundary; the production result confirmed
their prediction without disabling behavior. This case does not establish a
general ranking accuracy or explain the remaining 26 recompilations. No new
mandatory step or Cyclops dependency is warranted.
