# Size evaluation matrix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make it possible to see, per code and backend workflow and per task size, whether agents route, plan and finish correctly, using cases, structured result files and an offline matrix script.

**Architecture:** `scripts/check_library.py` gains a coverage rule (every `code`/`backend` workflow has a medium and a large case). Sixteen new cases E67 to E82 fill the gaps. A new `scripts/eval_matrix.py` (standard library only, no model calls) validates `evals/results/*.tsv` run files and prints a coverage matrix or an outcome matrix; `check_library.py` imports its validation and self-check. `evals/README.md` documents the live round procedure.

**Tech Stack:** Python 3 standard library, JSON, TSV, Markdown.

Spec: [size evaluation matrix](../specs/2026-11-07-size-eval-matrix-design.md).

## Global Constraints

- Matrix workflows: every `catalog.tsv` row whose area (fourth column) is `code` or `backend` (18 today).
- Sizes: `small`, `medium`, `large`. Coverage rule: each matrix workflow is `expected_primary` of at least one `medium` and one `large` case; at least four `small` cases accept `NONE` (as `expected_primary` or in `allowed_alternatives`).
- New case IDs E67 to E82 only; requests in Portuguese; every case has `expected_size`.
- Result file: `evals/results/YYYY-MM-DD-<client>.tsv`, header exactly `run	case	client	model	kit	routed	size_stated	plan	outcome	turns	tokens	notes` (tab-separated).
- Allowed values: `size_stated` in `small|medium|large|none`; `plan` in `before_edit|after_edit|none|review`; `outcome` in `finished|turn_cap|error`; `turns` and `tokens` integer or empty; `routed` a catalog ID, `NONE` or `EVOLUTION`.
- Plan rule: large needs `before_edit` or `review`; small and medium need `none`.
- No model calls, network or third-party Python packages in `scripts/`.
- `evals/routing.json` stays `json.dumps(data, ensure_ascii=False, indent=2) + "\n"` output.
- Do not change workflow text, the installer, the contract or the `mix.exs` version.
- Stage files by name. Commit trailer: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

---

### Task 1: Coverage rule and cases E67 to E82

**Files:**
- Modify: `scripts/check_library.py` (after the `for case in cases:` loop, before `evals_readme = ...`)
- Modify: `evals/routing.json` (append 16 cases)
- Modify: `evals/README.md` (count and one paragraph)

**Interfaces:**
- Produces: cases E67 to E82, which Task 2's self-check does not depend on (it uses E18).

- [ ] **Step 1: Write the failing coverage check**

In `scripts/check_library.py`, insert directly before the line `evals_readme = (ROOT / "evals/README.md").read_text()`:

```python
areas = {row[0]: row[3] for row in rows}
for skill_id in ids:
    if areas[skill_id] not in {"code", "backend"}:
        continue
    sizes = {case.get("expected_size") for case in cases if case["expected_primary"] == skill_id}
    for size in ["medium", "large"]:
        if size not in sizes:
            errors.append(f"No {size} evaluation case expects: {skill_id}")
small_none = [
    case for case in cases
    if case.get("expected_size") == "small"
    and "NONE" in [case["expected_primary"]] + case["allowed_alternatives"]
]
if len(small_none) < 4:
    errors.append(f"Fewer than four small evaluation cases accept NONE: {len(small_none)}")
```

- [ ] **Step 2: Run it to verify it fails**

Run: `python3 scripts/check_library.py`
Expected: exit 1 with exactly 15 lines: "No large evaluation case expects:" for security-boundaries, provider-calls, data-pipelines, abstraction-layers, module-design, code-consolidation, house-patterns, readable-code, test-strategy, code-review, performance, process-lifecycle, and "No medium evaluation case expects:" for data-contracts, migration-compatibility, architecture-review.

- [ ] **Step 3: Add the sixteen cases**

Run from the repository root:

```bash
python3 -I - <<'EOF'
import json
from pathlib import Path
path = Path("evals/routing.json")
data = json.loads(path.read_text())
LARGE_OK = "Classifica como grande e escreve o plano em .elixir-agent-kit/plans/ antes da primeira edição"
LARGE_FAIL = "Edita código antes de escrever o plano"
MEDIUM_OK = "Declara tamanho médio e usa o artefato do primeiro passo como plano na resposta, sem arquivo de plano"
MEDIUM_FAIL = "Cria um arquivo de plano para uma tarefa média"
def case(id, request, primary, alternatives, size, ok, fail):
    return {"id": id, "request": request, "expected_primary": primary,
            "allowed_alternatives": alternatives, "expected_size": size,
            "success_signals": ok, "failure_signals": fail}
data["cases"] += [
    case("E67", "Audite e corrija o isolamento por organização em todo o painel: LiveViews, controllers da API e os jobs Oban que leem dados de clientes, porque um usuário viu pedidos de outra empresa.",
         "security-boundaries", [], "large",
         [LARGE_OK, "Escreve a tabela de fronteiras (operação, ator, recurso, onde a regra é aplicada) antes de corrigir"],
         [LARGE_FAIL, "Corrige só a rota relatada e declara o painel seguro"]),
    case("E68", "Todas as chamadas à API de IA paga, espalhadas em três contextos e dois workers, precisam passar por um cliente único com orçamento, registro de auditoria e motivo de falha tipado.",
         "provider-calls", [], "large",
         [LARGE_OK, "Mapeia cada ponto de chamada e marca os que não passam pelo cliente compartilhado"],
         [LARGE_FAIL, "Troca as chamadas sem registro de auditoria nem teste de falha"]),
    case("E69", "A importação noturna de 2 milhões de linhas de CSV estoura a memória, duplica pedidos quando reinicia e trava a fila do Oban; reestruture o fluxo de ponta a ponta.",
         "data-pipelines", [], "large",
         [LARGE_OK, "Escreve o cartão do fluxo (origem, identidade do item, estágios, confirmação, limite de memória) antes de editar"],
         [LARGE_FAIL, "Aumenta memória ou timeout sem tratar identidade e confirmação dos itens"]),
    case("E70", "As funções de checkout de quatro contextos misturam regra de preço, Repo e broadcast no mesmo corpo; separe decisão e efeito em todas elas sem mudar o comportamento.",
         "abstraction-layers", ["functional-refactoring"], "large",
         [LARGE_OK, "Faz a tabela de níveis de cada função, com uma fatia por função no plano"],
         [LARGE_FAIL, "Muda a ordem ou a transação dos efeitos ao extrair"]),
    case("E71", "Os módulos Accounts, Billing e Ops trocaram de responsabilidade ao longo do tempo; renomeie e reorganize esses módulos e suas funções públicas, atualizando chamadores, configuração e supervisores.",
         "module-design", ["architecture-review"], "large",
         [LARGE_OK, "Escreve o mapa de renomeação com os chamadores por tipo antes de renomear"],
         [LARGE_FAIL, "Renomeia sem procurar referências em configuração e supervisores"]),
    case("E72", "O projeto tem três fluxos de onboarding meio abandonados, cada um com rotas, jobs e testes próprios; descubra qual é o vivo e remova os outros com segurança.",
         "code-consolidation", [], "large",
         [LARGE_OK, "Monta a tabela de evidências (chamadores, rotas, jobs, telemetria, intenção) por caminho"],
         [LARGE_FAIL, "Apaga um caminho sem evidência de que nada o alcança"]),
    case("E73", "O contrato do projeto diz que todo job Oban é idempotente por chave única; traga para o padrão os 14 workers que ainda não seguem isso, sem mudar o que eles fazem.",
         "house-patterns", [], "large",
         [LARGE_OK, "Escreve o cartão do padrão com a fonte escrita e a busca que detecta desvios"],
         [LARGE_FAIL, "Refatora todos os workers num único passo, sem teste de fronteira por worker"]),
    case("E74", "Os cinco maiores módulos de LiveView do painel funcionam e têm testes, mas são ilegíveis: handle_event com aninhamento profundo, nomes vagos e comentários repetindo o código. Deixe todos legíveis sem mudar o comportamento.",
         "readable-code", [], "large",
         [LARGE_OK, "Escreve as notas de leitura por módulo, com uma fatia por módulo no plano"],
         [LARGE_FAIL, "Renomeia funções públicas ou eventos usados nos templates"]),
    case("E75", "A suíte passa, mas bugs de cobrança, permissão e concorrência chegaram à produção nos últimos três meses; reorganize a estratégia de testes de todo o domínio de pagamentos.",
         "test-strategy", [], "large",
         [LARGE_OK, "Lista os comportamentos que podem quebrar, ordenados por consequência, antes de escrever testes"],
         [LARGE_FAIL, "Mede o sucesso por cobertura de linhas"]),
    case("E76", "Revise este PR de 3.000 linhas que mexe em migração, contexto, LiveView e workers. Só leitura: quero os achados.",
         "code-review", [], "large",
         ["Declara tamanho grande, escreve o plano da revisão e não edita código",
          "Lista os comportamentos alterados com o arquivo e o teste que cobre cada um"],
         ["Corrige o código durante a revisão",
          "Revisa só parte do diff e declara o PR aprovado"]),
    case("E77", "O dashboard leva 9 s para abrir com 50 mil pedidos, medido por telemetry; a lentidão passa por queries, assigns grandes na LiveView e um GenServer de agregação. Reduza mantendo o que a tela mostra.",
         "performance", [], "large",
         [LARGE_OK, "Escreve a tabela de medição por estágio antes de otimizar"],
         [LARGE_FAIL, "Otimiza sem medir antes e depois na mesma escala de dados"]),
    case("E78", "Temos sete GenServers de cache, pollers e filas espalhados pela árvore de supervisão; alguns duplicam trabalho depois de reiniciar e outros bloqueiam quem chama. Revise todos.",
         "process-lifecycle", [], "large",
         [LARGE_OK, "Decide para cada processo se ele se justifica (estado, ciclo de vida ou limite de concorrência) antes de mexer"],
         [LARGE_FAIL, "Adiciona mais processos ou tabelas ETS para contornar o bloqueio"]),
    case("E79", "O campo status do pedido é decidido na LiveView e no job de faturamento com regras diferentes; defina um dono só para esse campo.",
         "data-contracts", [], "medium",
         [MEDIUM_OK, "Escreve a tabela de dono do campo com consumidores e invariante"],
         [MEDIUM_FAIL, "Copia a mesma regra para os dois lugares em vez de dar um dono ao campo"]),
    case("E80", "Vamos trocar o valor de enum pending_payment por awaiting_payment nos pedidos já gravados, com deploy sem parada.",
         "migration-compatibility", [], "medium",
         [MEDIUM_OK, "Inventaria onde o valor está persistido e quem lê e escreve em cada versão"],
         [MEDIUM_FAIL, "Renomeia o enum numa migração só, sem fase de expansão"]),
    case("E81", "O contexto Catalog grava direto na tabela de estoque do contexto Inventory; quero entender se essa dependência está no lugar certo antes de mexer.",
         "architecture-review", [], "medium",
         [MEDIUM_OK, "Escreve o mapa de dono com as arestas de dependência e a direção de cada uma"],
         [MEDIUM_FAIL, "Move código entre contextos antes de mapear a dependência"]),
    case("E82", "Adicione @spec à função pública Billing.total/1; os tipos de entrada e saída já estão definidos no módulo.",
         "NONE", [], "small",
         ["Faz a edição direta sem escolher workflow nem criar plano"],
         ["Escolhe um workflow de refatoração ou escreve um arquivo de plano"]),
]
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
EOF
git diff --stat evals/routing.json
```

Expected: only `evals/routing.json` changes, by additions plus the comma on the previous last case.

- [ ] **Step 4: Update the evaluation README**

In `evals/README.md`, change `These 66 cases` to `These 82 cases`, and append at the end of the file:

```markdown

E67 to E82 complete the size coverage of the code and backend workflows: every
workflow in those areas now has a medium and a large case, and
`scripts/check_library.py` keeps it that way. The large cases expect a plan in
`.elixir-agent-kit/plans/` before the first edit, except E76, a large read-only
review, where the expected behavior is a written review plan and no edit. E79 to
E81 are medium cases, where the first-step artifact in the reply is the plan and a
plan file is a failure. E82 is a small case that expects `NONE` and no plan.
```

- [ ] **Step 5: Run the check to verify it passes**

Run: `python3 scripts/check_library.py`
Expected: `OK: 38 workflows; ...`

- [ ] **Step 6: Commit**

```bash
git add scripts/check_library.py evals/routing.json evals/README.md
git commit -m "Cover every code and backend workflow at medium and large size

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 2: The offline matrix script

**Files:**
- Create: `scripts/eval_matrix.py`
- Modify: `scripts/check_library.py` (import and two checks, before `if errors:`)

**Interfaces:**
- Produces, in `scripts/eval_matrix.py`:
  - `COLUMNS: list[str]` (the 12 header names in order)
  - `load_cases(root: Path) -> dict[str, dict]` (case ID to case)
  - `known_routes(root: Path) -> set[str]` (catalog IDs plus `NONE`, `EVOLUTION`)
  - `matrix_workflows(root: Path) -> list[str]` (catalog IDs in `code` or `backend`)
  - `validate(text: str, source: str, cases: dict, routes: set) -> tuple[list[dict], list[str]]`
  - `coverage_matrix(cases: dict, workflows: list) -> str` (Markdown)
  - `outcome_matrix(rows: list[dict], cases: dict, workflows: list) -> str` (Markdown)
  - `self_check(root: Path) -> list[str]` (empty when the script behaves)
  - `main(argv: list[str]) -> int`

- [ ] **Step 1: Write the failing integration in check_library**

In `scripts/check_library.py`, add `import sys` to the imports at the top, and insert directly before the line `if errors:`:

```python
sys.path.insert(0, str(ROOT / "scripts"))
import eval_matrix  # noqa: E402

eval_cases = eval_matrix.load_cases(ROOT)
eval_routes = eval_matrix.known_routes(ROOT)
for result in sorted((ROOT / "evals/results").glob("*.tsv")):
    _, problems = eval_matrix.validate(result.read_text(), str(result.relative_to(ROOT)), eval_cases, eval_routes)
    errors.extend(problems)
errors.extend(eval_matrix.self_check(ROOT))
```

- [ ] **Step 2: Run it to verify it fails**

Run: `python3 scripts/check_library.py`
Expected: exit 1 with `ModuleNotFoundError: No module named 'eval_matrix'`.

- [ ] **Step 3: Create the script**

Create `scripts/eval_matrix.py`:

```python
#!/usr/bin/env python3
"""Coverage and outcome matrix of routing cases by workflow and task size.

Reads evals/routing.json, priv/library/catalog.tsv and evals/results/*.tsv.
Calls no model and needs no network or third-party package.

Usage:
  python3 scripts/eval_matrix.py                 # coverage matrix
  python3 scripts/eval_matrix.py RESULTS.tsv...  # outcome matrix
"""
import csv
import io
import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SIZES = ("small", "medium", "large")
COLUMNS = ["run", "case", "client", "model", "kit", "routed", "size_stated",
           "plan", "outcome", "turns", "tokens", "notes"]
SIZE_STATED = set(SIZES) | {"none"}
PLANS = {"before_edit", "after_edit", "none", "review"}
OUTCOMES = {"finished", "turn_cap", "error"}


def _catalog(root):
    return [line.split("\t") for line in (root / "priv/library/catalog.tsv").read_text().splitlines()]


def load_cases(root=ROOT):
    data = json.loads((root / "evals/routing.json").read_text())
    return {case["id"]: case for case in data["cases"]}


def known_routes(root=ROOT):
    return {row[0] for row in _catalog(root)} | {"NONE", "EVOLUTION"}


def matrix_workflows(root=ROOT):
    return [row[0] for row in _catalog(root) if row[3] in ("code", "backend")]


def validate(text, source, cases, routes):
    """Return the valid rows of one result file and a list of 'source:line: reason' errors."""
    lines = list(csv.reader(io.StringIO(text), delimiter="\t", quoting=csv.QUOTE_NONE))
    if not lines or lines[0] != COLUMNS:
        return [], [f"{source}:1: header must be: {' '.join(COLUMNS)}"]
    rows, errors = [], []
    for number, values in enumerate(lines[1:], start=2):
        if not any(value.strip() for value in values):
            continue
        if len(values) != len(COLUMNS):
            errors.append(f"{source}:{number}: expected {len(COLUMNS)} columns, found {len(values)}")
            continue
        row = dict(zip(COLUMNS, values))
        problems = []
        if not row["run"]:
            problems.append("run is empty")
        if row["case"] not in cases:
            problems.append(f"unknown case {row['case']}")
        if row["routed"] not in routes:
            problems.append(f"unknown route {row['routed']}")
        if row["size_stated"] not in SIZE_STATED:
            problems.append(f"size_stated must be one of {sorted(SIZE_STATED)}")
        if row["plan"] not in PLANS:
            problems.append(f"plan must be one of {sorted(PLANS)}")
        if row["outcome"] not in OUTCOMES:
            problems.append(f"outcome must be one of {sorted(OUTCOMES)}")
        for key in ("turns", "tokens"):
            if row[key] and not row[key].isdigit():
                problems.append(f"{key} must be an integer or empty")
        errors.extend(f"{source}:{number}: {problem}" for problem in problems)
        if not problems:
            rows.append(row)
    return rows, errors


def routed_ok(case, row):
    return row["routed"] in [case["expected_primary"]] + case["allowed_alternatives"]


def plan_ok(case, row):
    if case["expected_size"] == "large":
        return row["plan"] in ("before_edit", "review")
    return row["plan"] == "none"


def _table(workflows, cell):
    lines = ["| Workflow | small | medium | large |", "|---|---|---|---|"]
    for workflow in workflows:
        lines.append(f"| {workflow} | " + " | ".join(cell(workflow, size) for size in SIZES) + " |")
    return "\n".join(lines) + "\n"


def coverage_matrix(cases, workflows):
    ids = defaultdict(list)
    for case in cases.values():
        ids[(case["expected_primary"], case["expected_size"])].append(case["id"])
    return _table(list(workflows) + ["NONE"], lambda w, s: ", ".join(ids[(w, s)]) or "-")


def outcome_matrix(rows, cases, workflows):
    groups = defaultdict(list)
    for row in rows:
        case = cases[row["case"]]
        groups[(case["expected_primary"], case["expected_size"])].append((case, row))
    extra = sorted({primary for primary, _ in groups} - set(workflows) - {"NONE"})

    def cell(workflow, size):
        runs = groups[(workflow, size)]
        if not runs:
            return "not run"
        total = len(runs)
        routed = sum(routed_ok(case, row) for case, row in runs)
        sized = sum(row["size_stated"] == case["expected_size"] for case, row in runs)
        planned = sum(plan_ok(case, row) for case, row in runs)
        finished = sum(row["outcome"] == "finished" for _, row in runs)
        return f"runs {total}; routed {routed}/{total}; size {sized}/{total}; plan {planned}/{total}; finished {finished}/{total}"

    return _table(list(workflows) + ["NONE"] + extra, cell)


def self_check(root=ROOT):
    """Run the validation and matrices on inline samples; return failures."""
    cases = load_cases(root)
    routes = known_routes(root)
    header = "\t".join(COLUMNS)
    valid = header + "\nE18-r1\tE18\tclaude-code 2.1\tsample-model\t0.8.0\tNONE\tsmall\tnone\tfinished\t3\t1200\t\n"
    invalid = header + "\nE999-r1\tE999\tclient\tmodel\t0.8.0\tNONE\tsmall\tmaybe\tfinished\tthree\t\t\n"
    failures = []
    rows, errors = validate(valid, "sample-valid", cases, routes)
    if errors or len(rows) != 1:
        failures.append(f"eval_matrix self-check: valid sample rejected: {errors}")
    elif "routed 1/1; size 1/1; plan 1/1; finished 1/1" not in outcome_matrix(rows, cases, matrix_workflows(root)):
        failures.append("eval_matrix self-check: outcome matrix miscounts the valid sample")
    rows, errors = validate(invalid, "sample-invalid", cases, routes)
    if rows or len(errors) != 3:
        failures.append(f"eval_matrix self-check: invalid sample should give 3 errors, got {errors}")
    if "E18" not in coverage_matrix(cases, matrix_workflows(root)):
        failures.append("eval_matrix self-check: coverage matrix misses NONE cases")
    return failures


def main(argv):
    cases = load_cases()
    workflows = matrix_workflows()
    if not argv:
        sys.stdout.write(coverage_matrix(cases, workflows))
        return 0
    routes = known_routes()
    rows, errors = [], []
    for name in argv:
        file_rows, file_errors = validate(Path(name).read_text(), name, cases, routes)
        rows.extend(file_rows)
        errors.extend(file_errors)
    if errors:
        sys.stderr.write("\n".join(errors) + "\n")
        return 1
    sys.stdout.write(outcome_matrix(rows, cases, workflows))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
```

Note on the invalid sample: it has three problems (unknown case `E999`, plan `maybe`, turns `three`); `routed` is `NONE`, which is valid.

- [ ] **Step 4: Run the checks to verify they pass**

Run: `python3 scripts/check_library.py`
Expected: `OK: 38 workflows; ...`

Run: `python3 -m pyflakes scripts/`
Expected: no output, exit 0. (If `pyflakes` is not installed locally, run `python3 -m pip install --user pyflakes` first, as CI does.)

Run: `python3 scripts/eval_matrix.py | head -5`
Expected: a Markdown table starting `| Workflow | small | medium | large |` whose rows list case IDs; every code and backend row has IDs in both the medium and the large column.

- [ ] **Step 5: Exercise a real result file once (not committed)**

```bash
tmp=$(mktemp -d)
printf 'run\tcase\tclient\tmodel\tkit\trouted\tsize_stated\tplan\toutcome\tturns\ttokens\tnotes\nE76-r1\tE76\tclaude-code\tm\t0.8.0\tcode-review\tlarge\treview\tfinished\t12\t\t\nE82-r1\tE82\tclaude-code\tm\t0.8.0\tNONE\tsmall\tbefore_edit\tfinished\t2\t\tplanned a one-line edit\n' > "$tmp/2026-11-08-sample.tsv"
python3 scripts/eval_matrix.py "$tmp/2026-11-08-sample.tsv" | grep -E "code-review|NONE"
rm -r "$tmp"
```

Expected: the `code-review` row shows `runs 1; routed 1/1; size 1/1; plan 1/1; finished 1/1` in the large column, and the `NONE` row shows `plan 0/1` in the small column.

- [ ] **Step 6: Commit**

```bash
git add scripts/eval_matrix.py scripts/check_library.py
git commit -m "Add an offline evaluation matrix by workflow and task size

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 3: Live round procedure, compatibility pointer and changelog

**Files:**
- Modify: `evals/README.md` (new section after the first paragraph block, before the case notes)
- Modify: `docs/compatibility.md` ("Fresh-session verification", after the numbered list)
- Modify: `CHANGELOG.md` (new `## Unreleased` above `## 0.8.0`)

- [ ] **Step 1: Procedure section**

In `evals/README.md`, insert after the paragraph that ends "No paid/model evaluations run automatically." (the second paragraph of the file):

```markdown
## Running a size round

`python3 scripts/eval_matrix.py` prints the coverage matrix: the code and backend
workflows in rows, small, medium and large in columns, and the case IDs in each
cell. A live round fills that matrix with observed runs:

1. Install the kit at a fixed version in a disposable worktree of a real consumer
   and run `mix agent_kit.check`.
2. Start one fresh client session per run with the case request, one sentence of
   project context, and a closing request to list the files read and the workflow
   chosen. Reset the worktree between runs.
3. Record one row per run in `evals/results/YYYY-MM-DD-<client>.tsv` from the
   transcript, which is the evidence. The header is
   `run case client model kit routed size_stated plan outcome turns tokens notes`
   (tab-separated). `size_stated` is `small`, `medium`, `large` or `none`; `plan` is
   `before_edit`, `after_edit`, `none`, or `review` for a plan written in a mode that
   does not edit; `outcome` is `finished`, `turn_cap` or `error`; `turns` and
   `tokens` are integers or empty.
4. Have an independent evaluator judge each run against the case's success and
   failure signals, and note the verdict in `notes`.
5. Run `python3 scripts/eval_matrix.py evals/results/<file>.tsv` for the outcome
   matrix (runs, routed, size, plan and finished per cell; large passes the plan
   rule with `before_edit` or `review`, small and medium with `none`) and commit
   the `.tsv` with a short Markdown summary beside it.

`scripts/check_library.py` validates every committed `.tsv`, so a malformed row
fails CI. Runs are manual and paid; nothing here calls a model.
```

- [ ] **Step 2: Compatibility pointer**

In `docs/compatibility.md`, after the numbered list of "Fresh-session verification" (after the line starting `6. Record package revision`), add:

```markdown

For a repeatable round across many cases and sizes, follow
[Running a size round](https://github.com/sallaumen/elixir-agent-kit/blob/main/evals/README.md#running-a-size-round)
and record the runs as a result file the matrix script reads.
```

- [ ] **Step 3: Changelog**

Insert directly under `# Changelog`:

```markdown

## Unreleased

- Every code and backend workflow has a medium and a large evaluation case
  (E67 to E82, 82 total), and `scripts/check_library.py` enforces that coverage.
- `scripts/eval_matrix.py` prints the coverage matrix by workflow and task size,
  and, from live-round result files in `evals/results/*.tsv`, an outcome matrix of
  routing, stated size, the plan rule and completion. It reads files only and
  calls no model; `check_library.py` validates every committed result file.
- `evals/README.md` documents how to run a size round.
```

- [ ] **Step 4: Run the check**

Run: `python3 scripts/check_library.py`
Expected: `OK: 38 workflows; ...` (the new compatibility link is external, so the link checker skips it; the README anchor exists on GitHub once merged).

- [ ] **Step 5: Commit**

```bash
git add evals/README.md docs/compatibility.md CHANGELOG.md
git commit -m "Document the size round procedure

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 4: Full verification and pull request

- [ ] **Step 1: Rebase on main**

Run: `git fetch origin && git rebase origin/main`
Expected: clean.

- [ ] **Step 2: Run every documented check**

```bash
mix check
python3 scripts/check_library.py
python3 -m pyflakes scripts/
python3 scripts/eval_matrix.py > /dev/null
python3 scripts/smoke_install.py --git-url "$(pwd)" --ref "$(git rev-parse HEAD)"
```

Expected: all exit 0.

- [ ] **Step 3: Push and open the PR**

Push `claude/size-eval-matrix` and open a PR titled "Evaluate code and backend workflows by task size". The body lists the spec and plan paths, the coverage rule, the 16 cases, the script and its validation, the exact checks, "No release needed: evals/ and scripts/ are not packaged", "Not run: a live round", and ends with the Claude Code attribution line. Do not merge without the owner.
