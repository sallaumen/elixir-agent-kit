# Workflow provenance

This English community edition adapts 33 workflows developed by Lucas Tavano with coding-agent assistance. The source collection was `biblioteca-prompts-desenvolvimento v1.0.0`, later refined in an application repository. The public edition preserves task boundaries and authorization modes while rewriting instructions for a standalone package. Product-specific contexts, application source, credentials and operational records are not included.

| Public ID | Original ID |
|---|---|
| `delivery-coordination` | `coordenar-entregas` |
| `architecture-review` | `revisar-arquitetura` |
| `abstraction-layers` | `stratified-design` |
| `module-design` | `organizar-modulos` |
| `code-consolidation` | `consolidar-codigo` |
| `version-lineage` | `versoes-e-rastreabilidade` |
| `data-contracts` | `contratos-e-dados` |
| `ui-identity` | `identidade-ui` |
| `layout-density` | `espaco-e-densidade` |
| `navigation-ux` | `ux-e-navegacao` |
| `responsive-mobile` | `mobile-e-responsividade` |
| `direct-interactions` | `interacoes-diretas` |
| `accessibility` | `acessibilidade` |
| `design-system` | `design-system` |
| `performance` | `performance` |
| `async-state` | `estados-assincronos` |
| `ai-orchestration` | `orquestracao-ias` |
| `notifications` | `notificacoes-e-bots` |
| `integration-setup` | `setup-integracoes` |
| `commercial-eligibility` | `elegibilidade-comercial` |
| `asset-lineage` | `assets-e-imagens` |
| `metrics-costs` | `metricas-e-custos` |
| `operational-alerts` | `alertas-operacionais` |
| `simulation-isolation` | `simulacao-e-producao` |
| `test-consolidation` | `testes-redundantes` |
| `test-strategy` | `estrategia-de-testes` |
| `code-review` | `code-review` |
| `debugging` | `investigar-bugs` |
| `security-boundaries` | `seguranca-e-permissoes` |
| `migration-compatibility` | `migracoes-e-compatibilidade` |
| `pipeline-design` | `pipelines-e-ci` |
| `build-dependencies` | `build-ci-dependencias` |
| `delivery-validation` | `validar-entrega` |

Conceptual references: [Agent Skills specification](https://agentskills.io/specification), [Eric Normand on stratified design](https://ericnormand.me/podcast/more-about-stratified-design), and [WCAG 2.2](https://www.w3.org/TR/WCAG22/). These references inform concepts; their texts are not bundled or relicensed.

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

All 33 public workflows now have task-specific inputs, decision points, quality
criteria, validation evidence and pitfalls. The [source review matrix](source-review.md)
records each original ID, primary area and additional professional reference
considered. The guidance is rewritten for reuse; no external skill text or
product-specific instruction is bundled verbatim.
