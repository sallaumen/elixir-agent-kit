# Catalog field round

The question was whether the current guides help an agent do a specific
piece of work, and when a change to a guide is justified. Correct behavior
without the guide is a useful control. A tie is enough to keep a guide that
meets its case criteria; an A/B run alone is not enough to close a failed
case.

| Evidence | Workflows covered | What was compared |
|---|---|---|
| [Code review](2026-11-13-review-repeat/README.md), [architecture](2026-11-13-architecture-review/README.md), [test strategy](2026-11-13-test-strategy-baseline.md), [debugging](2026-11-13-debugging-baseline.md) | `code-review`, `architecture-review`, `test-strategy`, `debugging` | Historical guide versus candidate for the first three. For debugging, a reader-side baseline followed by a caller-side unaided/guided pair and a replay of the real fix. |
| [Engineering](2026-11-13-engineering-ab.md) | `data-contracts`, `migration-compatibility`, `provider-calls`, `data-pipelines`, `abstraction-layers`, `module-design`, `code-consolidation`, `house-patterns`, `functional-refactoring`, `readable-code` | Returned Elixir implementations exercised against held-out assertions on synthetic contracts derived from historical changes. |
| [Runtime and delivery](2026-11-13-runtime-delivery-ab.md) | `performance`, `async-state`, `process-lifecycle`, `security-boundaries`, `delivery-coordination`, `pipeline-design`, `build-dependencies`, `delivery-validation` | Historical source extracts or delivery records, paired diagnoses and plans, plus evaluator controls. |
| [Domains](2026-11-13-domain-ab.md) | `ai-orchestration`, `notifications`, `operational-alerts`, `integration-setup`, `metrics-costs`, `simulation-isolation`, `commercial-eligibility`, `revision-lineage` | Paired reviews, counterexamples and separate application tests or probes where available. |
| [Frontend](2026-11-13-frontend-ab.md) | `ui-identity`, `layout-density`, `navigation-ux`, `responsive-layout`, `direct-interactions`, `accessibility`, `design-system`, `motion-design` | Paired reviews of historical source and reduced reproductions; evaluator observations in WebKit are reported separately from the model responses. |

These are manual, bounded evaluations on one client/model family. The
controls vary by case; aggregating scores as an accuracy or improvement rate
would obscure what was tested. No private application code or records are
required by the installed guides and no evaluator runs during installation.

**Release decision: hold.** All 38 workflows have paired evidence. On these
cases, 37 have support for keeping the current guide or adopting a tested
candidate. The exception is `ui-identity`: an addition improved the original
agreement screen, missed an important combination of states in a second
historical screen, and tied 3/6 on a third, previously unseen payment screen
while losing a meaningful copy distinction. Keep the published guide. Do
not tag a release on this evidence. A useful next test is a new independent
source of expected product hierarchy (for example a designer-approved set
of simultaneous states and their permitted actions), frozen before proposing
new wording; do not tune against these three screens again.

## Candidate identity and limits

The following SHA-256 values identify the full installed workflow files used
in the final candidate runs, including the inline guide in the pipeline test.
A match identifies the instructions; it does not establish repeatability.
In particular, pipeline outcomes varied across sessions. The 37 dispositions
above concern the named cases only, not complete acceptance across every
criterion or superiority to an unaided agent.

| Workflow | SHA-256 |
|---|---|
| `data-pipelines` | `9b184ffdb3fd41fde659131cf05b4b47b95ec04670f882e06ab0db836a161426` |
| `async-state` | `67fdeacafaefb058c4e79f60dc561cceaf35c23fc5cf5ee22310af344e618066` |
| `commercial-eligibility` | `3e58a79797c7192e255ab5a4b68b01bd25052e65a850684aa2fa1a5709795f71` |
| `revision-lineage` | `88ee9430c14b55ffcd2913c3d1e3047a080b6fd57b99b348cd73f39e7adc4022` |
| `accessibility` | `235a9a2d72b7a43bd51b1ea6cd22b699ad51b68d3107ddd2efd624759099763f` |
| `navigation-ux` | `0ea2ec6236b3f234540ee6e03120c64e64d18c7ed382d814878c55ae2c1a413a` |
| `motion-design` | `b9d95147fcbd8a5aab67081762a92c68f94f8aec6fab70e0dea3c83395a689c0` |
