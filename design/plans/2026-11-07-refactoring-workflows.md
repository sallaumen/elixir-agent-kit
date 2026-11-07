# Refactoring workflows Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two workflows, `functional-refactoring` and `readable-code`, that deliver a finished, behavior-preserving refactoring in the functional-thinking and readable-code styles, adapted to Elixir.

**Architecture:** Each workflow is a `priv/library/skills/<id>/SKILL.md` following the template that `scripts/check_library.py` enforces, registered in `priv/library/catalog.tsv`, `priv/library/CATALOG.md`, the README catalog grid, `docs/provenance.md` and at least one routing case. `ROUTING.md` gains a "Refactoring requests" section; four neighbor workflows gain one separating sentence. The installer does not change: the generated pointer skill lists catalog rows automatically.

**Tech Stack:** Markdown, a TSV catalog, a JSON evaluation file, Python 3 check scripts, Elixir/ExUnit for `mix check`.

Spec: [refactoring workflows](../specs/2026-11-07-refactoring-workflows-design.md).

## Global Constraints

- Workflow IDs exactly `functional-refactoring` and `readable-code`; area `code`; default mode `analyze-and-fix`.
- Catalog sentences, verbatim:
  - `functional-refactoring`: `Use when a module is hard to test or change because decisions, hidden inputs such as the clock, configuration or the database, and effects are interleaved across its functions.`
  - `readable-code`: `Use when a module works and is tested but is hard to read: vague names, long or deeply nested functions, comments that restate the code or a tangled error flow.`
- Evaluation IDs E63, E64, E65, E66 only; every case carries `expected_size`.
- Books are concept-only references: *Grokking Simplicity* (Eric Normand) and *Clean Code* (Robert C. Martin); no passage reproduced.
- No em dash characters in `priv/library`; no `/Users/`, `playwright` or the word `mcp` in workflow text.
- Point to `elixir/code-shape.md` and `elixir/pipelines.md` for vocabulary instead of restating them.
- Do not change the installer, tests, the contract, the `mix.exs` version or any existing workflow beyond the one separating sentence named in Task 3.
- `evals/routing.json` stays `json.dumps(data, ensure_ascii=False, indent=2) + "\n"` output; edit it with a small `python3 -I` script.
- Stage files by name. Commit trailer: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

---

### Task 1: The functional-refactoring workflow

**Files:**
- Create: `priv/library/skills/functional-refactoring/SKILL.md`
- Modify: `priv/library/catalog.tsv` (new line after the `house-patterns` line)
- Modify: `priv/library/CATALOG.md` (new row after the `house-patterns` row)
- Modify: `README.md` (catalog grid: new row after the `house-patterns` row)
- Modify: `docs/README.pt-BR.md` (same grid row)
- Modify: `docs/provenance.md` (new section at the end)
- Modify: `evals/routing.json` (case E63), `evals/README.md` (count)

**Interfaces:**
- Produces: workflow ID `functional-refactoring` and file path `priv/library/skills/functional-refactoring/SKILL.md`, linked by Tasks 2 and 3. The provenance section titled "## Refactoring workflows in 0.8" is extended by Task 2.

- [ ] **Step 1: Register the catalog line first (failing check)**

Append after the line starting `house-patterns` in `priv/library/catalog.tsv` (tab-separated: id, mode, sentence, area):

```
functional-refactoring	analyze-and-fix	Use when a module is hard to test or change because decisions, hidden inputs such as the clock, configuration or the database, and effects are interleaved across its functions.	code
```

- [ ] **Step 2: Run the check to verify it fails**

Run: `python3 scripts/check_library.py`
Expected: exit 1 with "Catalog and workflow directories disagree" (and follow-on errors for the missing file).

- [ ] **Step 3: Create the workflow**

Create `priv/library/skills/functional-refactoring/SKILL.md` with exactly:

```markdown
---
name: functional-refactoring
description: "Use when a module is hard to test or change because decisions, hidden inputs such as the clock, configuration or the database, and effects are interleaved across its functions."
---

# Functional Refactoring

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when testing one rule of a module needs the database, a frozen clock and an `Application.put_env/3` that the test must restore; when private functions call `DateTime.utc_now/0`, `Application.get_env/2` or `Repo.get!/2` deep inside a calculation; when a pricing or eligibility decision cannot be reused because it also inserts a row or broadcasts; when two functions repeat the same body except for one step; or when the user asks to refactor a module in a functional style and the project has no written pattern for it.

The separating rule among the code workflows: a whole module, or a small cluster around one entry point, whose functions interleave hidden inputs, decisions and effects is this workflow; one function mixing a decision with effects is [abstraction-layers](../abstraction-layers/SKILL.md); code drifting from a pattern the project already chose is [house-patterns](../house-patterns/SKILL.md); working code that is only hard to read is [readable-code](../readable-code/SKILL.md); a misleading module name or public API is [module-design](../module-design/SKILL.md). When a request only says "refactor this module", hidden dependencies or rules that are hard to test point here and reading obstacles alone point to readable-code; with both, this workflow runs first and readable-code follows as a later slice of the same plan.

## Inputs to inspect

- Start at: the module named in the request, with `grep -n "def \|defp " lib/<path>.ex` to list its functions, then a search for implicit inputs inside it: `grep -n "utc_now\|get_env\|Repo\.\|:ets\.\|Process.get" lib/<path>.ex`.
- Each public function's callers (`mix xref graph --sink lib/<path>.ex --only-nodes` lists the files that depend on the module) and what they observe: return shapes, error tuples, raises, rows written, broadcasts, jobs, telemetry.
- The tests that reach the module today and what each one stubs, freezes or configures to get there.
- The effects and their transaction boundaries: `Repo` writes, `Ecto.Multi`, `Oban.insert`, `Phoenix.PubSub.broadcast`, `send/2`, `Logger`, `:telemetry.execute`. See [Ecto](../../elixir/ecto.md) and [Oban](../../elixir/oban.md) when the project uses them.
- [Module and function shape](../../elixir/code-shape.md#decisions-and-effects) for where pure decisions live, and [Pipelines and control flow](../../elixir/pipelines.md) for chaining the reshaped steps.

## Workflow

1. Write the module inventory: one row per function with its kind (action: its result or effect depends on when or how often it runs; calculation: the same output for the same input; data shaping: builds or reads a struct or map), its implicit inputs (clock, configuration, database reads, ETS, process dictionary, messages received) and its implicit outputs (writes, broadcasts, jobs, logs, telemetry, messages sent). A function that calls an action is an action. This table is the artifact every later step reports against. Done when every function has a row and every implicit input and output the search found is attributed to one.

2. Pin current behavior at the public seam: for each public action, a test asserting what callers observe (result, error, raise, rows, broadcast, job), adding a characterization test where none exists. Record the effect inventory: count, order and transaction of each effect. Done when the pinned tests pass on the unchanged code.

3. Make implicit inputs explicit at the edge: the public action reads the clock, the configuration or the database once and passes plain values down; the functions it calls take those values as arguments. Public signatures and return shapes stay as they are; a value callers may want to override becomes an optional keyword or default argument, never a new required one. Done when no calculation row in the inventory still has an implicit input.

4. Extract calculations into pure functions that take data and return data, in the module or in a pure module named for the decision when several functions share it, each with a unit test that needs no database, stub or frozen clock. Done when every decision the inventory names can be called and tested without an effect.

5. Stratify the module: arrange the functions so each calls only its own layer or lower ones (public actions, then domain operations, then calculations, then data shaping), no calculation calls an action, and two bodies that differ in a single step become one function that receives that step as a function argument. Done when the inventory's call graph has no upward edge and no duplicated body remains.

6. Compare the effect inventory with step 2's, rerun the pinned tests and the project gate, and list the reading obstacles left for [readable-code](../readable-code/SKILL.md). Done when effects match in count, order and transaction, the gate passes on the head commit, and the handoff names each moved decision and its new test.

## Decision points

- Extract only when the new function names a business decision or shields a detail likely to change; a one-line wrapper that only forwards arguments is not a calculation.
- Implicit inputs are read once, at the edge, in the public action; never pass the repo, a client module or the whole configuration down to make a function look pure.
- Data over behavior: prefer plain maps, structs and tagged tuples flowing between functions over callbacks threaded through layers; pass a function argument only to remove a duplicated body.
- Effect count, order, error propagation and transaction boundary are frozen by step 2; changing any of them is a separate, named decision.
- Do not introduce a GenServer, Agent or ETS table to hold state the refactor exposed; a process is a [process-lifecycle](../process-lifecycle/SKILL.md) decision, and timing between concurrent effects is [async-state](../async-state/SKILL.md).
- A change that would alter a public signature, a stored shape or a message other processes rely on stops at the contract's stop-and-ask triggers.

## Quality criteria

- Every decision in the module can be called and tested with plain values, and its test needs no database, stub, frozen clock or configuration change.
- Each public action reads at one level: read inputs, decide, perform effects in the recorded order.
- No function calls one of a higher layer, and no calculation reaches the clock, configuration, database or a process.
- The effect inventory before and after is identical, and callers observe the same results and errors.
- No parameter bundle or callback exists only to claim purity.

## Validation and evidence

- Minimum: the module inventory before and after, a test of each extracted calculation that uses no stub, frozen clock or database, and the pinned public-seam tests passing on the unchanged code and on the head commit.
- When turns allow: the effect inventory before and after for one complete public action, listing each effect, its order and its transaction.
- When a test previously stubbed or froze something to reach a rule: the same rule now tested directly, with the stub or freeze kept only in the action's test.
- When reading obstacles remain: their list handed to [readable-code](../readable-code/SKILL.md), not fixed in the same step. See [ExUnit and diagnostics](../../elixir/exunit.md).

## Avoid

- Do not count new modules, files or lines as progress; a module whose rules became testable is the result.
- Do not move an effect into or out of a transaction, reorder effects or change their count while extracting.
- Do not change a public signature or return shape to make a function pure; read the input at the edge instead.
- Do not rename public functions or move the module here; that is [module-design](../module-design/SKILL.md).
- Do not mix readability sweeps (local renames, comment cleanup, formatting) into a structural step.

## Completion

A module inventory with every function classified and every implicit input and output attributed, calculations extracted as pure functions with stub-free tests, implicit inputs read once in the public actions, no upward call in the layering, effects unchanged in count, order and transaction, and the gate green on the head commit. For a single function use [abstraction-layers](../abstraction-layers/SKILL.md); for a pattern the project already chose use [house-patterns](../house-patterns/SKILL.md); for reading obstacles left behind use [readable-code](../readable-code/SKILL.md); for the coverage the stubs were hiding use [test-strategy](../test-strategy/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
```

Note: the links to `../readable-code/SKILL.md` resolve only after Task 2 creates that file. Do not create a stub for it; Step 6 runs the check and accepts exactly those broken-link lines, which Task 2 resolves.

- [ ] **Step 4: Register the catalog row, README grid, provenance and E63**

`priv/library/CATALOG.md`, after the `house-patterns` row:

```markdown
| [functional-refactoring](skills/functional-refactoring/SKILL.md) | analyze-and-fix | Use when a module is hard to test or change because decisions, hidden inputs such as the clock, configuration or the database, and effects are interleaved across its functions. |
```

`README.md` catalog grid, after the row containing `[house-patterns](priv/library/skills/house-patterns/SKILL.md)`:

```markdown
|  |  | [functional-refactoring](priv/library/skills/functional-refactoring/SKILL.md) |  |  |
```

`docs/README.pt-BR.md` grid, after the row containing `[house-patterns](../priv/library/skills/house-patterns/SKILL.md)`:

```markdown
|  |  | [functional-refactoring](../priv/library/skills/functional-refactoring/SKILL.md) |  |  |
```

Append to the end of `docs/provenance.md`:

```markdown

## Refactoring workflows in 0.8

`functional-refactoring` is the kit's own addition. It applies the ideas of
*Grokking Simplicity* by Eric Normand (actions, calculations and data; implicit
inputs and outputs; stratified design; functions passed as arguments) to Elixir
modules, alongside the stratified-design reference above. The book is a
concept-only reference: no passage was consulted for wording or reproduced, and
the workflow is written in the kit's own words.
```

Add E63 and update the count (run from the repository root):

```bash
python3 -I - <<'EOF'
import json
from pathlib import Path
path = Path("evals/routing.json")
data = json.loads(path.read_text())
data["cases"].append({
    "id": "E63",
    "request": "Este módulo de cobrança é impossível de testar sem banco: as regras de desconto chamam DateTime.utc_now e Repo.get! no meio do cálculo. Refatore no estilo funcional, como no Grokking Simplicity, sem mudar o comportamento.",
    "expected_primary": "functional-refactoring",
    "allowed_alternatives": ["abstraction-layers"],
    "expected_size": "medium",
    "success_signals": [
        "Faz o inventário do módulo com entradas e saídas implícitas antes de editar",
        "Lê o relógio e o Repo uma vez na ação pública e testa as regras sem stub nem banco",
        "Mantém as assinaturas públicas e os efeitos na mesma quantidade e ordem"
    ],
    "failure_signals": [
        "Muda a assinatura pública para receber o Repo ou o relógio",
        "Cria um GenServer ou novos diretórios como prova de refatoração"
    ]
})
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
EOF
sed -i '' 's/These 62 cases/These 63 cases/' evals/README.md
```

- [ ] **Step 5: Confirm the routing JSON diff is only the new case**

Run: `git diff --stat evals/routing.json`
Expected: one file, about 18 insertions and 1 deletion (the previous last case's closing brace gains a comma).

- [ ] **Step 6: Run the check**

Run: `python3 scripts/check_library.py`
Expected: exit 1 with only `Broken/escaping link: priv/library/skills/functional-refactoring/SKILL.md -> ../readable-code/SKILL.md` lines (resolved by Task 2). Any other error must be fixed before committing.

- [ ] **Step 7: Commit**

```bash
git add priv/library/skills/functional-refactoring/SKILL.md priv/library/catalog.tsv priv/library/CATALOG.md README.md docs/README.pt-BR.md docs/provenance.md evals/routing.json evals/README.md
git commit -m "Add the functional-refactoring workflow

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 2: The readable-code workflow

**Files:**
- Create: `priv/library/skills/readable-code/SKILL.md`
- Modify: `priv/library/catalog.tsv` (new line after `functional-refactoring`)
- Modify: `priv/library/CATALOG.md` (new row after `functional-refactoring`)
- Modify: `README.md`, `docs/README.pt-BR.md` (grid row after `functional-refactoring`)
- Modify: `docs/provenance.md` (extend the "Refactoring workflows in 0.8" section)
- Modify: `evals/routing.json` (case E64), `evals/README.md` (count)

**Interfaces:**
- Consumes: `priv/library/skills/functional-refactoring/SKILL.md` (Task 1), which links to this workflow.
- Produces: workflow ID `readable-code` at `priv/library/skills/readable-code/SKILL.md`.

- [ ] **Step 1: Register the catalog line (failing check)**

Append after the `functional-refactoring` line in `priv/library/catalog.tsv`:

```
readable-code	analyze-and-fix	Use when a module works and is tested but is hard to read: vague names, long or deeply nested functions, comments that restate the code or a tangled error flow.	code
```

- [ ] **Step 2: Run the check to verify it fails**

Run: `python3 scripts/check_library.py`
Expected: exit 1 with "Catalog and workflow directories disagree".

- [ ] **Step 3: Create the workflow**

Create `priv/library/skills/readable-code/SKILL.md` with exactly:

```markdown
---
name: readable-code
description: "Use when a module works and is tested but is hard to read: vague names, long or deeply nested functions, comments that restate the code or a tangled error flow."
---

# Readable Code

Default mode: **analyze-and-fix**. Read the [shared contract](../../CONTRACT.md) before applying this workflow. The user's explicit scope overrides the default mode.

## When to use

Use when a reviewer must hold four nested `case` and `if` levels in mind to follow one `handle_event/3`; when a function called `process/2` binds results named `res2` and `tmp`; when `mix credo --strict` reports complexity or nesting for functions nobody wants to touch; when every other line carries a comment that repeats the code below it; when errors travel through `{:ok, _}` and `{:error, _}` matches repeated at each step instead of one `with`; or when the user asks to make a module readable or clean without changing what it does.

The separating rule among the code workflows: working, tested code that is hard to read inside its function bodies is this workflow; a module's name, location or public API is [module-design](../module-design/SKILL.md); hidden inputs and effects interleaved across a module are [functional-refactoring](../functional-refactoring/SKILL.md), which runs first when both symptoms appear; one function mixing a decision with effects is [abstraction-layers](../abstraction-layers/SKILL.md); drift from a pattern the project already chose is [house-patterns](../house-patterns/SKILL.md). Code whose behavior no test pins gets those tests first, as step 2 says.

## Inputs to inspect

- Start at: the module named in the request and `mix credo --strict <path>` for it (or the project's lint command), whose complexity, nesting and naming findings seed the reading notes.
- The project's naming and style sources: `AGENTS.md` or a style guide, a glossary if one exists, `.credo.exs` and `.formatter.exs`. They win over the kit's defaults.
- The tests that pin the module's public behavior, and the callers of its public functions, so every rename stays private.
- [Module and function shape](../../elixir/code-shape.md) for the anti-pattern names (assertive code, naming, errors, documentation), and [Pipelines and control flow](../../elixir/pipelines.md#with-for-fallible-steps) for `with` and the pipe.

## Workflow

1. Write the reading notes: one row per function with each obstacle found (a vague or misleading name, nesting depth, length that mixes levels of detail, a comment that restates code, a repeated error match, non-assertive matching or map access), the `credo` finding or the [code-shape](../../elixir/code-shape.md) anti-pattern name it maps to, and the planned change. This table is the artifact every later step reports against. Done when every function the request covers has a row, including those with no obstacle.

2. Pin behavior and the lint baseline: the public functions' tests pass on the unchanged code, characterization tests are added where a function has none, and the current `credo` output is saved. Done when both exist.

3. Rename local variables and private functions to the domain's vocabulary, one name per concept, using the project's glossary when it exists. Public function and module names go to [module-design](../module-design/SKILL.md) as handoff rows. Done when no private name in the notes is still vague and `mix compile --warnings-as-errors` is clean.

4. Reshape control flow by meaning: branch with function heads and pattern matching instead of nested `case` and `if`, chain fallible steps with one `with` whose `else` handles each error once, use the pipe for successive transformations of one value, and split a function where its level of detail changes, not at a line count. Done when each function reads at one level and `credo` reports no nesting or complexity finding beyond those the baseline already accepted.

5. Clean up comments and docs: delete comments that restate the code, keep those that record a constraint, a reason or a measured fact, and make `@moduledoc` and `@doc` state promises per [code-shape](../../elixir/code-shape.md#documentation-and-types). Done when every remaining comment says something the code cannot.

6. Compare and close: the pinned tests pass unchanged, `credo` reports nothing new against the baseline, the diff changes no return value, error, effect or public name, and the project gate passes. Done when the handoff lists the notes table in its final state and any rows handed off.

## Decision points

- The project's naming and style rules beat the kit's defaults; the [code-shape](../../elixir/code-shape.md) anti-pattern names give a shared vocabulary, not new rules.
- Split by meaning, never by line count: a long function that reads at one level stays; a short one that mixes levels splits.
- Renames stay private here; a public rename changes a contract and belongs to [module-design](../module-design/SKILL.md).
- A comment is kept when it records a constraint, a reason or a measured fact the code cannot show.
- A readability change that would alter behavior (a lenient match made assertive on input that can really vary) is a separate, named decision with its own test, not part of the cleanup.
- Formatting is the formatter's job; do not hand-format or mix a formatter run with semantic changes in one step.

## Quality criteria

- A reader follows each function without holding more than one level of nesting or detail in mind.
- Names say what a value is or what a function decides, in the domain's words, consistently across the module.
- Error flow is visible in one place per function, and every error the function could return is still returned.
- Every remaining comment adds information the code does not carry.
- Tests, return values, errors, effects and public names are unchanged.

## Validation and evidence

- Minimum: the reading notes before and after, the pinned public tests passing on the unchanged code and on the head commit, and the `credo` output before and after showing no new finding.
- When turns allow: one before-and-after excerpt per obstacle kind in the handoff, named with its anti-pattern.
- When a public name was found vague: the handoff row for [module-design](../module-design/SKILL.md) instead of a rename.
- When a function had no test: the characterization test added in step 2. See [ExUnit and diagnostics](../../elixir/exunit.md).

## Avoid

- Do not treat shorter code, fewer lines or more functions as more readable by themselves.
- Do not rename public functions, modules or stored keys here.
- Do not change behavior, effects or error values while cleaning up, including obvious-looking fixes; report them as defects.
- Do not restate the code in new comments or add docs that only repeat the function name.
- Do not move effects or extract calculations across the module; that is [functional-refactoring](../functional-refactoring/SKILL.md).

## Completion

Reading notes with every obstacle mapped to a `credo` finding or an anti-pattern name, private names in the domain's vocabulary, control flow reshaped by meaning, comments that carry information, tests and public names unchanged, no new `credo` finding, and the gate green on the head commit. For public names use [module-design](../module-design/SKILL.md); for hidden inputs and effects use [functional-refactoring](../functional-refactoring/SKILL.md); for one function mixing a decision with effects use [abstraction-layers](../abstraction-layers/SKILL.md); for a project pattern use [house-patterns](../house-patterns/SKILL.md).

Use the [Elixir context](../../ELIXIR.md) only for technology present in the project. Record a useful [handoff](../../HANDOFF.md) when another person or agent will continue the work.
```

- [ ] **Step 4: Register the catalog row, grid, provenance and E64**

`priv/library/CATALOG.md`, after the `functional-refactoring` row:

```markdown
| [readable-code](skills/readable-code/SKILL.md) | analyze-and-fix | Use when a module works and is tested but is hard to read: vague names, long or deeply nested functions, comments that restate the code or a tangled error flow. |
```

`README.md` grid, after the `functional-refactoring` row:

```markdown
|  |  | [readable-code](priv/library/skills/readable-code/SKILL.md) |  |  |
```

`docs/README.pt-BR.md` grid, after the `functional-refactoring` row:

```markdown
|  |  | [readable-code](../priv/library/skills/readable-code/SKILL.md) |  |  |
```

Append to the "## Refactoring workflows in 0.8" section of `docs/provenance.md` (a new paragraph after the existing one):

```markdown

`readable-code` is also the kit's own addition. It applies the ideas of *Clean
Code* by Robert C. Martin (names that reveal intent, functions at one level of
detail, comments that carry information, visible error flow) through the Elixir
anti-pattern vocabulary in `elixir/code-shape.md`. The book is a concept-only
reference in the same way: no passage was consulted for wording or reproduced.
```

Add E64 and update the count:

```bash
python3 -I - <<'EOF'
import json
from pathlib import Path
path = Path("evals/routing.json")
data = json.loads(path.read_text())
data["cases"].append({
    "id": "E64",
    "request": "O módulo de relatórios funciona e tem testes, mas ninguém consegue ler: funções de 80 linhas com quatro níveis de case, variáveis res2 e tmp e comentários repetindo o código. Deixe legível, estilo Clean Code, sem mudar nada do que ele faz.",
    "expected_primary": "readable-code",
    "allowed_alternatives": [],
    "expected_size": "medium",
    "success_signals": [
        "Escreve as notas de leitura com o achado do credo ou o nome do anti-pattern por função",
        "Divide as funções por significado e troca o aninhamento por cabeças de função ou with",
        "Mantém testes e nomes públicos inalterados, sem achado novo do credo"
    ],
    "failure_signals": [
        "Renomeia funções públicas",
        "Mede legibilidade por número de linhas ou de funções"
    ]
})
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
EOF
sed -i '' 's/These 63 cases/These 64 cases/' evals/README.md
```

- [ ] **Step 5: Run the check to verify it passes**

Run: `python3 scripts/check_library.py`
Expected: `OK: 38 workflows; structure, routing coverage, provenance and version aligned; ... local links and anchors checked.`

- [ ] **Step 6: Commit**

```bash
git add priv/library/skills/readable-code/SKILL.md priv/library/catalog.tsv priv/library/CATALOG.md README.md docs/README.pt-BR.md docs/provenance.md evals/routing.json evals/README.md
git commit -m "Add the readable-code workflow

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 3: Routing, neighbor boundaries and the two routing-boundary cases

**Files:**
- Modify: `priv/library/ROUTING.md` (code-area row; new section before "## Game and canvas interfaces")
- Modify: `priv/library/skills/abstraction-layers/SKILL.md:14`, `priv/library/skills/module-design/SKILL.md:14`, `priv/library/skills/code-consolidation/SKILL.md:14`, `priv/library/skills/house-patterns/SKILL.md:14` (append one sentence each)
- Modify: `priv/library/ELIXIR.md:12`, `priv/library/elixir/code-shape.md` (first bullet of "## Decisions and effects")
- Modify: `evals/routing.json` (E65, E66), `evals/README.md` (count and paragraph)

**Interfaces:**
- Consumes: both workflow paths from Tasks 1 and 2.
- Produces: anchor `ROUTING.md#refactoring-requests`.

- [ ] **Step 1: Routing guide**

In `priv/library/ROUTING.md`, in the "Code structure and quality" row, replace `versus a pattern nobody has chosen yet (architecture-review);` with:

```
versus a pattern nobody has chosen yet (architecture-review); a module's hidden inputs and effects (functional-refactoring) versus reading obstacles inside working code (readable-code), see [Refactoring requests](#refactoring-requests);
```

Insert before the line `## Game and canvas interfaces`:

```markdown
## Refactoring requests

A request to refactor names a style, a symptom or neither. Route by the symptom,
then by scope:

- Hidden inputs (the clock, configuration, the database) or effects interleaved
  across a module, or a rule that cannot be tested without them:
  [functional-refactoring](skills/functional-refactoring/SKILL.md); a single
  function with that problem: [abstraction-layers](skills/abstraction-layers/SKILL.md).
- Working, tested code that is hard to read inside its functions:
  [readable-code](skills/readable-code/SKILL.md); a misleading module name,
  location or public function name: [module-design](skills/module-design/SKILL.md).
- Code that drifts from a pattern the project already chose:
  [house-patterns](skills/house-patterns/SKILL.md), whatever style the request names.

"In a functional style" or "like Grokking Simplicity" points to
functional-refactoring, and "clean" or "like Clean Code" to readable-code, unless
the symptom says otherwise. When a vague request ("refactor module X") shows both
symptoms, select functional-refactoring and plan readable-code as a later slice of
the same plan.

```

- [ ] **Step 2: Neighbor separating sentences**

Append each sentence to the end of line 14 (the paragraph starting "The separating rule among the code workflows:"), separated by one space:

- `priv/library/skills/abstraction-layers/SKILL.md`: `A whole module whose functions interleave hidden inputs, decisions and effects is [functional-refactoring](../functional-refactoring/SKILL.md).`
- `priv/library/skills/module-design/SKILL.md`: `Reading obstacles inside function bodies, including private names, are [readable-code](../readable-code/SKILL.md); public names stay here.`
- `priv/library/skills/code-consolidation/SKILL.md`: `Restructuring or cleaning up the one implementation that stays is [functional-refactoring](../functional-refactoring/SKILL.md) or [readable-code](../readable-code/SKILL.md).`
- `priv/library/skills/house-patterns/SKILL.md`: `When no pattern has been chosen and the request names a functional or readable style, use [functional-refactoring](../functional-refactoring/SKILL.md) or [readable-code](../readable-code/SKILL.md).`

- [ ] **Step 3: Elixir context pointers**

In `priv/library/ELIXIR.md` line 12 (the "Module and function shape" row), append to the last cell, before its closing ` |`: `; the refactoring workflows that apply it are [functional-refactoring](skills/functional-refactoring/SKILL.md) and [readable-code](skills/readable-code/SKILL.md)`.

In `priv/library/elixir/code-shape.md`, at the end of the first bullet of "## Decisions and effects" (after `...is the [abstraction-layers](../skills/abstraction-layers/SKILL.md) workflow.`), add, rewrapping the bullet near 80 columns:

```
A whole module whose functions interleave hidden inputs and effects is
[functional-refactoring](../skills/functional-refactoring/SKILL.md); making
working code readable without changing it is
[readable-code](../skills/readable-code/SKILL.md).
```

- [ ] **Step 4: Cases E65 and E66, and the evals README**

```bash
python3 -I - <<'EOF'
import json
from pathlib import Path
path = Path("evals/routing.json")
data = json.loads(path.read_text())
data["cases"] += [
    {
        "id": "E65",
        "request": "Refatore o módulo Billing: para testar uma regra os testes precisam congelar o relógio e mexer no Application env, e as funções são enormes e cheias de case aninhado.",
        "expected_primary": "functional-refactoring",
        "allowed_alternatives": ["readable-code"],
        "expected_size": "large",
        "success_signals": [
            "Classifica como grande e planeja functional-refactoring primeiro e readable-code como fatia posterior do mesmo plano",
            "Escreve o plano em .elixir-agent-kit/plans/ antes da primeira edição"
        ],
        "failure_signals": [
            "Mistura renomeações e limpeza de comentários nos passos estruturais",
            "Começa pela legibilidade e deixa as dependências escondidas"
        ]
    },
    {
        "id": "E66",
        "request": "Renomeie a função pública Billing.process/2 para charge_invoice/2 e atualize quem chama.",
        "expected_primary": "module-design",
        "allowed_alternatives": ["NONE"],
        "expected_size": "small",
        "success_signals": [
            "Trata como mudança de API pública e atualiza todos os chamadores",
            "Não seleciona readable-code"
        ],
        "failure_signals": [
            "Seleciona readable-code e faz uma limpeza geral do módulo",
            "Renomeia sem procurar os chamadores"
        ]
    }
]
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
EOF
sed -i '' 's/These 64 cases/These 66 cases/' evals/README.md
```

Append to the end of `evals/README.md`:

```markdown

E63 to E66 cover the refactoring workflows. E63 asks for a functional-style
refactor of a module whose rules read the clock and the database
(`functional-refactoring`); E64 asks for a readable, Clean Code style cleanup of
working code (`readable-code`); E65 is a vague "refactor module X" with both
symptoms, where the expected route is `functional-refactoring` first with
`readable-code` planned as a later slice; E66 renames a public function, a
negative case for `readable-code` (`module-design`, or `NONE` for the bounded
edit).
```

- [ ] **Step 5: Run the checks**

Run: `python3 scripts/check_library.py`
Expected: `OK: 38 workflows; ...` (the new `#refactoring-requests` anchor and all new links resolve).

Run: `grep -n "—" priv/library/ROUTING.md priv/library/ELIXIR.md priv/library/elixir/code-shape.md priv/library/skills/*/SKILL.md`
Expected: no output.

- [ ] **Step 6: Commit**

```bash
git add priv/library/ROUTING.md priv/library/skills/abstraction-layers/SKILL.md priv/library/skills/module-design/SKILL.md priv/library/skills/code-consolidation/SKILL.md priv/library/skills/house-patterns/SKILL.md priv/library/ELIXIR.md priv/library/elixir/code-shape.md evals/routing.json evals/README.md
git commit -m "Route refactoring requests by symptom and mark the new boundaries

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 4: Counts, source review and changelog

**Files:**
- Modify: `README.md:11`, `docs/README.pt-BR.md:6`, `docs/README.md:9`, `CONTRIBUTING.md:44` (36 -> 38)
- Modify: `docs/source-review.md` (two rows after the `house-patterns` row)
- Modify: `CHANGELOG.md` (new `## Unreleased` section at the top)

- [ ] **Step 1: Workflow counts**

Run: `grep -rn "36" README.md docs/README.pt-BR.md docs/README.md CONTRIBUTING.md docs/source-review.md | grep -i workflow`
Change each count of workflows from 36 to 38 in those lines (expected: `README.md` "the same 36 reviewed workflows", `docs/README.pt-BR.md` "os mesmos 36 workflows revisados", `docs/README.md` "Review how the 36 workflows", `CONTRIBUTING.md` "the 36-workflow review"). Leave numbers that are not workflow counts.

- [ ] **Step 2: Source review rows**

In `docs/source-review.md`, after the row starting `| Code | [\`house-patterns\`]`, add:

```markdown
| Code | [`functional-refactoring`](../priv/library/skills/functional-refactoring/SKILL.md) | none (new in 0.8) | shared contract; Elixir context; *Grokking Simplicity* concepts (Eric Normand), concept only | Every extracted decision is tested with plain values and no stub, and the effect inventory is identical before and after. |
| Code | [`readable-code`](../priv/library/skills/readable-code/SKILL.md) | none (new in 0.8) | shared contract; Elixir context; *Clean Code* concepts (Robert C. Martin), concept only | Tests, effects and public names are unchanged and no new lint finding appears, while every obstacle in the reading notes is resolved or handed off. |
```

- [ ] **Step 3: Changelog**

Insert directly under `# Changelog` (before the latest release heading):

```markdown

## Unreleased

- New workflows `functional-refactoring` and `readable-code` (code area), both
  behavior-preserving and analyze-and-fix. `functional-refactoring` makes a
  module's hidden inputs explicit at the edge, extracts its decisions as pure
  functions tested without stubs and layers its functions (ideas from *Grokking
  Simplicity*, concept only). `readable-code` resolves reading obstacles inside
  working code (names, nesting, comments, error flow) through the `code-shape`
  vocabulary (ideas from *Clean Code*, concept only).
- `ROUTING.md` routes refactoring requests by symptom; a vague request with both
  symptoms runs `functional-refactoring` first and `readable-code` as a later
  slice. `abstraction-layers`, `module-design`, `code-consolidation` and
  `house-patterns` name the new boundaries.
- Evaluation cases E63 to E66 (66 total).
```

- [ ] **Step 4: Run the check**

Run: `python3 scripts/check_library.py`
Expected: `OK: 38 workflows; ...`

- [ ] **Step 5: Commit**

```bash
git add README.md docs/README.pt-BR.md docs/README.md CONTRIBUTING.md docs/source-review.md CHANGELOG.md
git commit -m "Count 38 workflows and record the refactoring workflows

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 5: Full verification and pull request

- [ ] **Step 1: Rebase on main**

Run: `git fetch origin && git rebase origin/main`
Expected: clean.

- [ ] **Step 2: Run every documented check**

```bash
mix check
python3 scripts/check_library.py
python3 scripts/smoke_install.py --git-url "$(pwd)" --ref "$(git rev-parse HEAD)"
python3 scripts/smoke_migration.py
mix hex.build && rm -f elixir_agent_kit-*.tar
```

Expected: all exit 0; the generated START.md in the smoke lists both new workflows under "Code structure and quality".

- [ ] **Step 3: Push and open the PR**

Push `claude/refactoring-workflows` and open a PR titled "Add functional-refactoring and readable-code". The body lists the spec and plan paths, changes per area, the exact checks, a provenance statement (both books concept-only; no excerpt was consulted for wording, so no passage can overlap), "Not run: live client evaluation", and ends with the Claude Code attribution line. Do not merge or tag without the owner.
