# Workflow catalog

Choose the area first, then the narrowest trigger. Operational domains are product
patterns (alerts, notifications, eligibility, simulations, revisions, model capacity); a
project without them can omit those IDs from its `skills:` selection. [ROUTING.md](ROUTING.md) explains
neighboring skills and when no workflow is needed. Read the [shared contract](CONTRACT.md)
with the selected workflow. The installed project index points here after `mix deps.get`.
Consumer projects hold at most one generated pointer skill per client, never a
copy of a workflow body.

## Frontend and user experience

| Workflow | Default mode | Trigger |
|---|---|---|
| [ui-identity](skills/ui-identity/SKILL.md) | analyze-and-fix | Use when a working interface lacks product-specific hierarchy, identity or visual coherence. |
| [layout-density](skills/layout-density/SKILL.md) | analyze-and-fix | Use when spacing, alignment or information density makes a screen hard to scan or use. |
| [navigation-ux](skills/navigation-ux/SKILL.md) | analyze-and-fix | Use when users lose context or need unnecessary steps to complete a multi-screen task. |
| [responsive-layout](skills/responsive-layout/SKILL.md) | analyze-and-fix | Use when a layout breaks, overflows or hides actions across phone, notebook and wide screens, or touch targets and reach fail on a phone. |
| [direct-interactions](skills/direct-interactions/SKILL.md) | analyze-and-fix | Use when a simple selection or adjustment requires excessive forms and disconnected controls. |
| [accessibility](skills/accessibility/SKILL.md) | analyze-and-fix | Use when controls, forms, dialogs or asynchronous changes may exclude keyboard or assistive-technology users. |
| [design-system](skills/design-system/SKILL.md) | analyze-and-fix | Use when teams repeat interface mistakes or create incompatible component and token variations. |
| [motion-design](skills/motion-design/SKILL.md) | analyze-and-fix | Use when interface motion is missing, generic or applied to every change, or when transitions misrepresent state. |

## Backend and data

| Workflow | Default mode | Trigger |
|---|---|---|
| [data-contracts](skills/data-contracts/SKILL.md) | analyze-and-fix | Use when layers disagree about data, rules are duplicated or a write leaves records inconsistent. |
| [migration-compatibility](skills/migration-compatibility/SKILL.md) | analyze-and-fix | Use when stored schemas, identifiers, jobs or public payloads must survive a version change. |
| [security-boundaries](skills/security-boundaries/SKILL.md) | analyze-and-fix | Use when untrusted input, credentials, permissions or tenant boundaries may permit unintended access. |
| [provider-calls](skills/provider-calls/SKILL.md) | analyze-and-fix | Use when code calls a paid, rate-limited or externally billed provider and its retries, budget, audit trail or failure reasons are unclear. |

## Code structure and quality

| Workflow | Default mode | Trigger |
|---|---|---|
| [architecture-review](skills/architecture-review/SKILL.md) | analyze-and-fix | Use when changes cross many modules, rules repeat, dependencies cycle or domain ownership is unclear. |
| [abstraction-layers](skills/abstraction-layers/SKILL.md) | analyze-and-fix | Use when functions mix business decisions, low-level details and effects at incompatible levels. |
| [module-design](skills/module-design/SKILL.md) | analyze-and-fix | Use when module names, locations or public APIs obscure responsibilities that are already understood. |
| [code-consolidation](skills/code-consolidation/SKILL.md) | analyze-and-fix | Use when unfinished features, abandoned paths or competing implementations make a codebase ambiguous. |
| [test-strategy](skills/test-strategy/SKILL.md) | analyze-and-fix | Use when a passing suite misses important bugs, the required regression coverage is unclear, or duplicated tests protect nothing distinct. |
| [code-review](skills/code-review/SKILL.md) | review | Use when reviewing a bounded diff or pull request for actionable defects and regressions. |
| [debugging](skills/debugging/SKILL.md) | analyze-and-fix | Use when a wrong result, exception or intermittent failure has no demonstrated root cause. |
| [performance](skills/performance/SKILL.md) | analyze-and-fix | Use when measured latency, freezes, excessive work or rendering cost affects a real workflow. |
| [async-state](skills/async-state/SKILL.md) | analyze-and-fix | Use when progress stalls, success appears too early or stale asynchronous results overwrite current state. |
| [process-lifecycle](skills/process-lifecycle/SKILL.md) | analyze-and-fix | Use when a GenServer, Task, poller or supervised process holds state, leaks, blocks callers, duplicates work or behaves differently after a restart. |

## Operational domains

| Workflow | Default mode | Trigger |
|---|---|---|
| [ai-orchestration](skills/ai-orchestration/SKILL.md) | analyze-and-fix | Use when agent jobs, queues, workers and model capacity are conflated or incorrectly accounted for. |
| [notifications](skills/notifications/SKILL.md) | analyze-and-fix | Use when bots or notifications fail, repeat or produce unexplained message volume. |
| [operational-alerts](skills/operational-alerts/SKILL.md) | analyze-and-fix | Use when alerts repeat, historical incidents look current or acknowledging an alert appears to resolve it. |
| [integration-setup](skills/integration-setup/SKILL.md) | analyze-and-fix | Use when an integration looks configured but required steps or operational readiness remain unclear. |
| [metrics-costs](skills/metrics-costs/SKILL.md) | analyze-and-fix | Use when totals, model costs or operational metrics have unclear scope, origin or meaning. |
| [simulation-isolation](skills/simulation-isolation/SKILL.md) | analyze-and-fix | Use when simulation, training or demo flows share code and data paths with real operations. |
| [commercial-eligibility](skills/commercial-eligibility/SKILL.md) | analyze-and-fix | Use when an offering is presented without evidence that its exact variant and destination are supported. |
| [revision-lineage](skills/revision-lineage/SKILL.md) | analyze-and-fix | Use when a revision, preview, asset or selection is associated with the wrong version, or viewing an old version silently changes the current one. |

## Delivery and build

| Workflow | Default mode | Trigger |
|---|---|---|
| [delivery-coordination](skills/delivery-coordination/SKILL.md) | coordinate | Use when consolidating a product or dividing an authorized change into reviewable deliveries. |
| [pipeline-design](skills/pipeline-design/SKILL.md) | analyze-and-fix | Use when validation pipelines lack clear ownership, local/CI parity or predictable command effects. |
| [build-dependencies](skills/build-dependencies/SKILL.md) | analyze-and-fix | Use when dependencies, builds or CI fail or behave differently across environments. |
| [delivery-validation](skills/delivery-validation/SKILL.md) | analyze | Use when checking whether an integrated change actually satisfies its acceptance criteria. |
