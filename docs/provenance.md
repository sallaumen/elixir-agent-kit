# Workflow provenance

This English community edition adapts 33 workflows developed by Lucas Tavano with coding-agent assistance, adds one workflow adapted from an external MIT skill and one distilled from a consuming application's rules, for 34 public workflows after the 0.5 merges and the addition of `process-lifecycle` (`revision-lineage` from two lineage workflows, `test-strategy` absorbing `testes-redundantes`), and 36 since `house-patterns` and `data-pipelines` in 0.7. The source collection was `biblioteca-prompts-desenvolvimento v1.0.0`, later refined in an application repository. The public edition preserves task boundaries and authorization modes while rewriting instructions for a standalone package. Product-specific contexts, application source, credentials and operational records are not included.

| Public ID | Original ID |
|---|---|
| `delivery-coordination` | `coordenar-entregas` |
| `architecture-review` | `revisar-arquitetura` |
| `abstraction-layers` | `stratified-design` |
| `module-design` | `organizar-modulos` |
| `code-consolidation` | `consolidar-codigo` |
| `revision-lineage` | `versoes-e-rastreabilidade` and `assets-e-imagens` (merged in 0.5) |
| `data-contracts` | `contratos-e-dados` |
| `ui-identity` | `identidade-ui` |
| `layout-density` | `espaco-e-densidade` |
| `navigation-ux` | `ux-e-navegacao` |
| `responsive-layout` | `mobile-e-responsividade` (history and overlays moved to `navigation-ux` in 0.5) |
| `direct-interactions` | `interacoes-diretas` |
| `accessibility` | `acessibilidade` |
| `design-system` | `design-system` |
| `motion-design` | — (external adaptation, 0.4) |
| `performance` | `performance` |
| `async-state` | `estados-assincronos` |
| `ai-orchestration` | `orquestracao-ias` |
| `notifications` | `notificacoes-e-bots` |
| `integration-setup` | `setup-integracoes` |
| `commercial-eligibility` | `elegibilidade-comercial` |
| `metrics-costs` | `metricas-e-custos` |
| `operational-alerts` | `alertas-operacionais` |
| `simulation-isolation` | `simulacao-e-producao` |
| `test-strategy` | `estrategia-de-testes` and `testes-redundantes` (merged in 0.5) |
| `code-review` | `code-review` |
| `debugging` | `investigar-bugs` |
| `security-boundaries` | `seguranca-e-permissoes` |
| `migration-compatibility` | `migracoes-e-compatibilidade` |
| `pipeline-design` | `pipelines-e-ci` |
| `build-dependencies` | `build-ci-dependencias` |
| `delivery-validation` | `validar-entrega` |

Conceptual references: [Agent Skills specification](https://agentskills.io/specification), [Eric Normand on stratified design](https://ericnormand.me/podcast/more-about-stratified-design), and [WCAG 2.2](https://www.w3.org/TR/WCAG22/). These references inform concepts; their texts are not bundled or relicensed.

## Review lenses and their licenses

The [source review matrix](source-review.md) names the skills consulted while
deepening each workflow. None of their sentences is reproduced in this kit; the
table records where each lens came from and the license stated in the copy that
was consulted, so a reader can judge the provenance claim rather than trust it.

| Lens | Origin | License in the consulted copy | What the kit took |
|---|---|---|---|
| `skill-creator` | Anthropic skills collection | Apache-2.0 | The packaging principle: when to use, which decisions matter, how to check the outcome. |
| `ui-review` | Local skill by the kit's author | Same author as this kit | Real browser, keyboard, responsive and state checks as evidence. |
| `impeccable` | Local skill; the copy declares Apache 2.0 but records no upstream repository | Apache-2.0 (as declared) | Hierarchy and design-system questions; none of its aesthetic defaults. |
| `stitch-design-taste` | Local skill for Google Stitch | None stated in the consulted copy | Design-system questions only; nothing reused. |
| `playbook-antislop` | `sallaumen/agent-playbook`, adapted from "Anti Slop" by Miqdad Badjuber | MIT | Honest copy and working controls as quality criteria. |
| `elixir-antipatterns` | Gentleman-Skills, author tsardinasGitHub | MIT | Module boundary, changeset and query questions; numeric heuristics and code not imported. |
| `elixir-ecto-patterns` | Local skill | None stated in the consulted copy | Ecto concepts only; nothing reused. |
| `tdd` | mattpocock-skills plugin by Matt Pocock | MIT | The distinction between public behavior, failure cases and test oracles. |
| `motion-kit` | Hugh Phan, revision `6173e5c` | MIT | The motion method adapted into `motion-design`, as recorded below. |

Where the consulted copy states no license, the kit relied on the concept alone.
Confirm the upstream license before any future textual reuse from those sources.

## Consolidation in 0.2

The original collection stopped being a second editable source. The shared
contract now links an evolution policy, and reusable decision, delivery, diagnosis
and validation templates live in `priv/library/templates/`. Incorporation becomes
the proposal template and evolution guide, rather than a command to run every
workflow. The initial 29 routing cases live in `evals/`, outside the installed payload.
Their metadata is checked; live agent evaluations remain separate.

Original long-form wording and product contexts remain in the source repository's
Git history. This edition is a concise adaptation, not a claim of literal text
equivalence. Private product contexts are not part of the public package.

## Depth review in 0.3

All 33 workflows from the original collection now have task-specific inputs, decision points, quality
criteria, validation evidence and pitfalls. The [source review matrix](source-review.md)
records each original ID, primary area and additional professional reference
considered. The guidance is rewritten for reuse; no external skill text or
product-specific instruction is bundled verbatim.

## External motion adaptation in 0.4

`motion-design` does not come from the original collection. It adapts the method of
[motion-kit](https://github.com/hughminhphan/motion-kit) by Hugh Phan (MIT, revision
`6173e5c408f81f1989435843af3f0788b74bda96`): `skills/motion-designer/SKILL.md`,
`LIBRARY.md` and `motion-kit.js`. The workflow is rewritten for product interfaces.
It keeps the register, one-curve-per-property, distance-and-weight timing,
lead-and-reactions and restraint model; it adds interface timing floors,
server-rendered and LiveView guidance, reduced-motion alternatives and browser
verification. Video-only devices (seek-safe GSAP timelines, wiggle, time remapping,
text ranges) stay in the source and are not packaged. Curve values retain their
attribution to easings.net, Material 3 and IBM Carbon. The source is MIT and permits
adaptation; no text is bundled verbatim. For rendered video the routing guide points
at the external skill instead of copying it into this kit.

## Provider calls in 0.5

`provider-calls` does not come from the original collection either. It generalizes
rules that a consuming application (agent-board) kept in its maintainer contract
for paid model and voice calls: every call is a row, no retry of a paid request,
failure is a typed reason rather than a fabricated answer, budget is checked before
the network. The workflow restates them for any billed or rate-limited provider and
adds output validation and prompt-content boundaries. No application text, module
names or credentials are included.

## Process lifecycle and the five areas in 0.5

`process-lifecycle` is the kit's own addition for BEAM runtime concerns (ownership,
supervision, backpressure, restart) that no original workflow covered beyond two
sentences in the Elixir context. The catalog also moved from four areas to five:
frontend; backend and data; code structure and quality; operational domains; delivery
and build. "Operational domains" names the product patterns that came from the
original collection (alerts, notifications, readiness, metrics, simulations,
eligibility, revisions, model capacity) so a project without those domains can
omit them from its selection instead of reading them as general engineering rules.

## House patterns and the Elixir references in 0.7

`house-patterns` is the kit's own addition: a workflow for bringing existing code to
patterns a project has already established, one verifiable step at a time, without
changing what callers observe. The Elixir context grew from the same source as
`provider-calls`: an inventory of the practices agent-board follows in its code,
tests and maintainer contract (clients as values with typed failure reasons,
per-item isolation in sync jobs, claim-before-effect writes, data loading in
`handle_params/3`, keyed async jobs, configuration knobs restored after tests,
`precommit` versus `gate`, and the libraries it relies on). Each rule was restated
for any Elixir project and checked against the documentation or source of the
library versions named; product rules, intervals, vendor limits and the
application's own wording stayed in the application. `ELIXIR.md` became an index of
per-technology references in `elixir/` so an agent reads only the ones its project
uses.

## Deeper Elixir references and data pipelines in 0.7

Before 0.7 shipped, a second review compared the references with the Elixir
anti-pattern guides, library guidelines, naming and documentation guides and the
1.18 to 1.20 changelogs (Apache-2.0); the Phoenix 1.8 usage rules shipped in the
`phoenix` package and its contexts and scopes guides (MIT); the Ecto, Plug, Req,
GenStage, Flow, Broadway and Mox documentation (Apache-2.0); the `boundary`
library (MIT); José Valim's "Mocks and explicit contracts"; Christopher Adams's
Elixir style guide (CC BY 3.0); a public package-quality checklist by Mike
Hostetler; and public agent rule sets for Elixir (`usage_rules`, Tidewave,
community skill collections). Every rule is paraphrased and checked against the
documentation or source of the version named; no passage is reproduced. The
review added `pipelines.md`, `architecture.md`, `library-authoring.md` and
`agent-loop.md`, expanded `code-shape.md` with the anti-pattern vocabulary, and
added the `data-pipelines` workflow for flows of many items, whose CI namesake
`pipeline-design` now points to it.

## Refactoring workflows in 0.8

`functional-refactoring` is the kit's own addition. It applies the ideas of
*Grokking Simplicity* by Eric Normand (actions, calculations and data; implicit
inputs and outputs; stratified design; functions passed as arguments) to Elixir
modules, alongside the stratified-design reference above. The book is a
concept-only reference: no passage was consulted for wording or reproduced, and
the workflow is written in the kit's own words.

`readable-code` is also the kit's own addition. It applies the ideas of
*Clean Code* by Robert C. Martin (names that reveal intent, functions at one level of
detail, comments that carry information, visible error flow) through the Elixir
anti-pattern vocabulary in `elixir/code-shape.md`. The book is a concept-only
reference in the same way: no passage was consulted for wording or reproduced.
