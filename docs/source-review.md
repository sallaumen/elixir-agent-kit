# Review of all 35 workflows

This matrix is an editorial audit, not an evaluation of model compliance. The
earlier public edition preserved each trigger and a short four-step workflow but
compressed the original guidance. This revision restores task-specific inputs,
decisions, quality criteria, validation evidence and pitfalls in every workflow.
The canonical instructions remain in [the grouped catalog](../priv/library/CATALOG.md).

The original IDs refer to the historical agent-board collection recorded in
[provenance](provenance.md). Professional local skills were consulted as design
references, with rewritten instructions; their text and universal preferences
are not packaged. “Original workflow” means the historical authored material.

| Area | Public workflow | Original ID | Additional review lens | Most important quality boundary |
|---|---|---|---|---|
| Delivery | [`delivery-coordination`](../priv/library/skills/delivery-coordination/SKILL.md) | `coordenar-entregas` | original workflow; shared contract | Each work item has an owner, objective, affected paths, integration condition and handoff evidence. |
| Cross-cutting | [`architecture-review`](../priv/library/skills/architecture-review/SKILL.md) | `revisar-arquitetura` | elixir-antipatterns | Each finding names the owner of the behavior, the dependency crossing it and the consequence for a real use case. |
| Backend | [`abstraction-layers`](../priv/library/skills/abstraction-layers/SKILL.md) | `stratified-design` | elixir-antipatterns | A reader can follow the business intent without chasing a chain of one-line wrappers or decoding transport mechanics. |
| Backend | [`module-design`](../priv/library/skills/module-design/SKILL.md) | `organizar-modulos` | elixir-antipatterns | Each public module name predicts its responsibility, and exported operations form a coherent promise to consumers. |
| Cross-cutting | [`code-consolidation`](../priv/library/skills/code-consolidation/SKILL.md) | `consolidar-codigo` | elixir-antipatterns | The resulting API names the common concept and leaves meaningful differences visible at call sites. |
| Cross-cutting | [`version-lineage`](../priv/library/skills/version-lineage/SKILL.md) | `versoes-e-rastreabilidade` | original workflow; shared contract | Every claim about “the version” names the layer it describes and the identifier used to verify it. |
| Backend | [`data-contracts`](../priv/library/skills/data-contracts/SKILL.md) | `contratos-e-dados` | elixir-ecto-patterns | Document accepted input, output, errors and side effects at each meaningful boundary without repeating the same rule in every layer. |
| Frontend | [`ui-identity`](../priv/library/skills/ui-identity/SKILL.md) | `identidade-ui` | ui-review; impeccable; playbook-antislop | Make the primary action and essential information distinguishable by hierarchy, position, typography and wording; a decorative accent is not a substitute. |
| Frontend | [`layout-density`](../priv/library/skills/layout-density/SKILL.md) | `espaco-e-densidade` | ui-review; impeccable | Align related labels, values and actions on a stable grid. Group information by decision, then give primary and secondary content appropriate weight. |
| Frontend | [`navigation-ux`](../priv/library/skills/navigation-ux/SKILL.md) | `ux-e-navegacao` | ui-review; impeccable | Make the next meaningful action discoverable at each step without hiding context or creating an endless wizard. |
| Frontend | [`responsive-mobile`](../priv/library/skills/responsive-mobile/SKILL.md) | `mobile-e-responsividade` | ui-review; impeccable | Keep primary controls reachable and named on touch screens without relying on hover or a universal edge-swipe gesture. |
| Frontend | [`direct-interactions`](../priv/library/skills/direct-interactions/SKILL.md) | `interacoes-diretas` | ui-review; impeccable | Use a representation that communicates the actual choice, such as a segmented control or thumbnail, without turning decoration into a hidden input. |
| Frontend | [`accessibility`](../priv/library/skills/accessibility/SKILL.md) | `acessibilidade` | ui-review; WCAG 2.2 | Provide correct heading/landmark order, labels and programmatic relationships that match the visible task. |
| Frontend | [`design-system`](../priv/library/skills/design-system/SKILL.md) | `design-system` | impeccable; stitch-design-taste | Describe principles by purpose: hierarchy, density, typography, color role, motion, imagery and interaction states, not a fashionable fixed palette. |
| Frontend | [`motion-design`](../priv/library/skills/motion-design/SKILL.md) | — (external adaptation) | motion-kit (MIT, pinned commit); Material 3; IBM Carbon | Every animated change names the state it explains, the curve and duration derived for it, and a reduced-motion alternative that keeps the state legible. |
| Cross-cutting | [`performance`](../priv/library/skills/performance/SKILL.md) | `performance` | original workflow; shared contract | Before/after measurements use comparable inputs, warmup, configuration and statistical summary. |
| Cross-cutting | [`async-state`](../priv/library/skills/async-state/SKILL.md) | `estados-assincronos` | original workflow; shared contract | The UI and API can reconcile after reconnect or reload using persisted identifiers and a current-state read. |
| Backend | [`ai-orchestration`](../priv/library/skills/ai-orchestration/SKILL.md) | `orquestracao-ias` | original workflow; shared contract | Acquisition, release, timeout, cancellation and crash recovery keep capacity counters consistent. |
| Backend | [`provider-calls`](../priv/library/skills/provider-calls/SKILL.md) | none (new in 0.5) | a consuming application's paid-call rules, generalized; shared contract | Every call has one audit row at the provider's billing moment, failures are typed reasons, and a failed round trip never charges twice. |
| Backend | [`notifications`](../priv/library/skills/notifications/SKILL.md) | `notificacoes-e-bots` | original workflow; shared contract | A source event has stable identity through delivery so duplicate callbacks/retries do not create unexplained sends. |
| Backend | [`integration-setup`](../priv/library/skills/integration-setup/SKILL.md) | `setup-integracoes` | original workflow; shared contract | The UI and backend use one readiness contract with specific reasons, not several booleans with conflicting meanings. |
| Backend | [`commercial-eligibility`](../priv/library/skills/commercial-eligibility/SKILL.md) | `elegibilidade-comercial` | original workflow; shared contract | A single domain rule answers whether the exact offer can be produced, sold and fulfilled at its destination. |
| Frontend | [`asset-lineage`](../priv/library/skills/asset-lineage/SKILL.md) | `assets-e-imagens` | ui-review; playbook-antislop | Carry stable source, version and ownership identifiers through generation, transformation, storage and display. |
| Backend | [`metrics-costs`](../priv/library/skills/metrics-costs/SKILL.md) | `metricas-e-custos` | original workflow; shared contract | A metric definition states numerator, denominator, unit, period, source and exclusions so two screens mean the same thing. |
| Backend | [`operational-alerts`](../priv/library/skills/operational-alerts/SKILL.md) | `alertas-operacionais` | original workflow; shared contract | Repeated events for one active issue update a stable alert rather than flooding the operator. |
| Backend | [`simulation-isolation`](../priv/library/skills/simulation-isolation/SKILL.md) | `simulacao-e-producao` | original workflow; shared contract | Simulation cannot reach real orders, payments, messages or provider writes through a hidden common code path. |
| Cross-cutting | [`test-consolidation`](../priv/library/skills/test-consolidation/SKILL.md) | `testes-redundantes` | tdd | The consolidated test states its behavioral oracle and fails when the protected contract breaks. |
| Cross-cutting | [`test-strategy`](../priv/library/skills/test-strategy/SKILL.md) | `estrategia-de-testes` | tdd | Each test has a concrete input, expected observable result and reason the boundary matters. |
| Cross-cutting | [`code-review`](../priv/library/skills/code-review/SKILL.md) | `code-review` | original workflow; shared contract | Each finding cites a tight location, conditions to reproduce and the resulting wrong behavior. |
| Cross-cutting | [`debugging`](../priv/library/skills/debugging/SKILL.md) | `investigar-bugs` | original workflow; shared contract | The fix addresses the mechanism at the owning layer and preserves neighboring behavior. |
| Backend | [`security-boundaries`](../priv/library/skills/security-boundaries/SKILL.md) | `seguranca-e-permissoes` | original workflow; shared contract | Tenant or account scope survives IDs supplied in URLs, caches, exports, attachments and queued work. |
| Backend | [`migration-compatibility`](../priv/library/skills/migration-compatibility/SKILL.md) | `migracoes-e-compatibilidade` | elixir-ecto-patterns | Old records remain readable and new writes do not break active old readers during the coexistence window. |
| Delivery | [`pipeline-design`](../priv/library/skills/pipeline-design/SKILL.md) | `pipelines-e-ci` | original workflow; shared contract | Each pipeline step has a purpose, reproducible command and clear failure signal. |
| Delivery | [`build-dependencies`](../priv/library/skills/build-dependencies/SKILL.md) | `build-ci-dependencias` | original workflow; shared contract | A fresh install resolves the same dependency graph from committed manifests. |
| Delivery | [`delivery-validation`](../priv/library/skills/delivery-validation/SKILL.md) | `validar-entrega` | original workflow; shared contract | The final evidence links each acceptance condition to a check or a clearly stated limitation. |

## Source selection and editorial decisions

Origins and licenses of every lens below are tabulated in
[provenance](provenance.md#review-lenses-and-their-licenses).

- `skill-creator` supplied the packaging principle: a skill should say when to use it, which decisions matter and how to check the outcome. Length alone is not the goal.
- `ui-review` contributed real browser, keyboard, responsive and state checks. `impeccable` and `stitch-design-taste` helped expose hierarchy and design-system questions, but their aesthetic defaults are not universal product rules.
- `playbook-antislop` contributed honest product copy and functioning controls. Its guidance is applied only where interface or user-facing text is at issue.
- `elixir-antipatterns` and `elixir-ecto-patterns` helped identify module boundaries, changesets, constraints and query behavior. Their numerical heuristics and illustrative code are not imported as enforceable rules.
- `motion-kit` supplied the motion method (registers, curve per property, distance-and-weight duration, lead and reactions, restraint) for `motion-design`; its video-only tools and its text are not imported. Material 3, IBM Carbon and easings.net supplied public curve values, as credited in the source.
- `tdd` helped distinguish public behavior, failure cases and test oracles. The kit does not mandate test-first for every change or reward a test that only mirrors implementation.
- The original 33 workflows supply the domain-specific distinctions, including async identity, eligibility per variant and destination, notification delivery, simulations, persisted migration contracts and coordinated delivery. The thirty-fourth, `motion-design`, is the external adaptation recorded in [provenance](provenance.md); the thirty-fifth, `provider-calls`, generalizes rules a consuming application kept locally for paid calls (one audit row per call, no retry without idempotency, failure as a typed reason, budget before the network).

## Gaps and resolution

| Observed gap in the previous public edition | Resolution in this edition |
|---|---|
| A flat catalog obscured frontend, backend and delivery work. | The catalog has a primary area and a routing page; cross-area work can select a neighboring workflow for a distinct risk. |
| Short workflows did not specify the evidence an agent should inspect. | Each workflow names task-specific inputs and decision points. |
| Completion language was easy to satisfy by assertion alone. | Each workflow names quality criteria and representative validation evidence. |
| Source skills contained product-bound and sometimes overly prescriptive advice. | The public bodies retain reusable mechanisms, with local product rules left to consuming repositories. |
| Game and canvas interfaces had no route. | The routing guide points to one pinned external `game-ui-ux` skill when the source has a canvas or game scene, beside a kit frontend workflow. |
| Interface motion had no route, so the default was one borrowed easing on every change. | `motion-design` covers curves, distance-and-weight timing, reactions, continuity and reduced motion; the routing guide points to a pinned external `motion-designer` skill for rendered video. |
| Structural package checks could be mistaken for proof that GPT, DeepSeek or Claude followed instructions. | Compatibility docs retain an explicit live-client evaluation boundary. |

The matrix establishes content coverage. It does not prove that each agent client
loads the dependency or applies the practice. Use fresh sessions and the
[compatibility procedure](compatibility.md) for that separate question.
