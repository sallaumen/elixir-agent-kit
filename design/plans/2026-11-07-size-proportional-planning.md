# Size-proportional planning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every kit workflow inherits a planning rule that scales with task size: large tasks write a plan file in a kit-managed, git-ignored folder before the first edit.

**Architecture:** The rule lives in `priv/library/CONTRACT.md` with a new template `priv/library/templates/task-plan.md`. The installer (`lib/elixir_agent_kit/installer.ex`) adds a size to step 1 and a step 5 to the shared `START.md`/pointer-skill body, and owns one new file, `.elixir-agent-kit/plans/.gitignore`. `scripts/check_library.py` guards the contract, the template and a new `expected_size` field on every evaluation case.

**Tech Stack:** Elixir 1.15+ Mix tasks, ExUnit, Python 3 scripts, Markdown.

Spec: [size-proportional planning](../specs/2026-11-07-size-proportional-planning-design.md).

## Global Constraints

- Do not edit any `priv/library/skills/*/SKILL.md`, `CATALOG.md`, `ROUTING.md`, `catalog.tsv` or the `mix.exs` version; another session owns those (release PR #37 bumps 0.7.0).
- Evaluation IDs: this plan adds E55 and E56 only. E57-E64 belong to the other session.
- No model calls, telemetry, services or global client configuration (AGENTS.md).
- The installer never touches the consumer's own `.gitignore`.
- Plans folder: `.elixir-agent-kit/plans/`; ignore file contents exactly `*\n!.gitignore\n`.
- Stop-and-ask triggers, verbatim: the plan widens the requested scope, changes persisted data or a public contract, or contains an irreversible step.
- No em dash in `priv/library` workflow text; English in library and docs except `docs/README.pt-BR.md`.
- Stage files by name. Commit message trailer: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Before pushing, `git fetch origin && git rebase origin/main`; the other session merges to `main` concurrently.

---

### Task 1: Planning rule in the contract, the handoff and the task-plan template

**Files:**
- Modify: `scripts/check_library.py` (after the `errors = []` line and before the catalog loop)
- Modify: `priv/library/CONTRACT.md` (new section after "## Deliver bounded changes")
- Modify: `priv/library/HANDOFF.md` (one line)
- Create: `priv/library/templates/task-plan.md`

**Interfaces:**
- Produces: anchor `CONTRACT.md#plan-in-proportion-to-size` and file `templates/task-plan.md`, both linked by Task 2's `START.md` text.

- [ ] **Step 1: Write the failing check**

In `scripts/check_library.py`, insert after `errors = []`:

```python
contract = (LIBRARY / "CONTRACT.md").read_text()
if "## Plan in proportion to size" not in contract:
    errors.append("CONTRACT.md lacks the 'Plan in proportion to size' section")
for size in ["| Small |", "| Medium |", "| Large |"]:
    if size not in contract:
        errors.append(f"CONTRACT.md size table lacks the row {size}")
task_plan = LIBRARY / "templates/task-plan.md"
if not task_plan.is_file():
    errors.append("templates/task-plan.md is missing")
else:
    plan_text = task_plan.read_text()
    for field in [
        "- Request, authorized scope and exclusions:",
        "- Size and why; workflow ID and version:",
        "- Baseline: branch, revision, pre-existing failures:",
        "- Stop-and-ask triggers hit",
        "| # | Slice | Files/contracts | Check that proves it | Status |",
        "- Order and safe intermediate states:",
        "- Stop conditions:",
        "- Notes after compaction",
    ]:
        if field not in plan_text:
            errors.append(f"templates/task-plan.md lacks: {field}")
```

- [ ] **Step 2: Run it to verify it fails**

Run: `python3 scripts/check_library.py`
Expected: exit 1 listing "CONTRACT.md lacks the 'Plan in proportion to size' section", the three size rows and "templates/task-plan.md is missing".

- [ ] **Step 3: Add the contract section**

In `priv/library/CONTRACT.md`, insert this section between "## Deliver bounded changes" (after its last paragraph) and "## Validate the changed risk":

```markdown
## Plan in proportion to size

Classify the task from the request before reading code, and revise the size after the first inspection when the code shows otherwise. Between two sizes, choose the larger.

| Size | Signals (any one raises the level) | Planning |
|---|---|---|
| Small | A bounded, fully specified edit: one function or one file. | No plan; the workflow is usually NONE. |
| Medium | One flow or module, one workflow, one delivery. | The selected workflow's first-step artifact is the plan, stated in the reply. |
| Large | Crosses more than one context or boundary; touches persisted data and code together; needs more than one delivery; an open request such as "refactor module X"; or unlikely to fit one session without compaction. | Before the first edit, write a plan from the [task-plan template](templates/task-plan.md) in `.elixir-agent-kit/plans/YYYY-MM-DD-<slug>.md` and name its path in the first message. |

The plan does not replace the workflow: its first slice is the selected workflow's first-step artifact. Stop for the user only when the plan widens the requested scope, changes persisted data or a public contract, or contains an irreversible step; otherwise proceed. Update the plan's Status column as each slice closes. After compaction or when resuming, reread the plan before any other action. Record a change of direction under Notes instead of deleting history; a change that hits a stop trigger stops for the user.

The plans folder is ignored by Git: a plan survives compaction and another session in the same checkout, not another worktree. When the project's instructions name their own plan location, use it. The final report states the size next to the workflow ID and cites the plan path. Multi-delivery work with owners keeps the [delivery plan](templates/delivery-plan.md).
```

- [ ] **Step 4: Add the handoff line**

In `priv/library/HANDOFF.md`, replace:

```markdown
- **Revision and practices:** code revision, Elixir Agent Kit version, selected workflow IDs.
```

with:

```markdown
- **Revision and practices:** code revision, Elixir Agent Kit version, selected workflow IDs, task size and plan path for a large task.
```

- [ ] **Step 5: Create the template**

Create `priv/library/templates/task-plan.md`:

```markdown
# Task plan: <one line>

- Request, authorized scope and exclusions:
- Size and why; workflow ID and version:
- Baseline: branch, revision, pre-existing failures:
- Stop-and-ask triggers hit (scope, persisted data, public contract, irreversible): none | which

| # | Slice | Files/contracts | Check that proves it | Status |
|---|---|---|---|---|
| 1 | <first-step artifact of the workflow> | | | todo |

- Order and safe intermediate states:
- Stop conditions:
- Notes after compaction (what changed, what's next):
```

- [ ] **Step 6: Run the check to verify it passes**

Run: `python3 scripts/check_library.py`
Expected: `OK: 35 workflows; structure, routing coverage, provenance and version aligned; ... local links and anchors checked.`

- [ ] **Step 7: Commit**

```bash
git add scripts/check_library.py priv/library/CONTRACT.md priv/library/HANDOFF.md priv/library/templates/task-plan.md
git commit -m "Add size-proportional planning to the shared contract

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 2: Installer owns the plans folder and START.md gains the size and step 5

**Files:**
- Modify: `lib/elixir_agent_kit/installer.ex` (module attributes; `missing_library_files/2`; `files/3`; `entry/2`; `parse_entry/1`)
- Test: `test/installer_test.exs`

**Interfaces:**
- Consumes: `templates/task-plan.md` and `CONTRACT.md#plan-in-proportion-to-size` from Task 1.
- Produces: owned file `.elixir-agent-kit/plans/.gitignore` (state row `file\t.elixir-agent-kit/plans/.gitignore\t<sha256>\tcreated`), which Task 3's smoke test and Task 5's docs name.

- [ ] **Step 1: Update the existing tests and add new ones (failing)**

In `test "installs only references and round trips"`, replace the expected snapshot list and the step count:

```elixir
    assert Enum.sort(Map.keys(snapshot(root))) ==
             [
               ".agents/skills/elixir-agent-kit/SKILL.md",
               ".claude/skills/elixir-agent-kit/SKILL.md",
               ".elixir-agent-kit/START.md",
               ".elixir-agent-kit/plans/.gitignore",
               ".elixir-agent-kit/state.tsv",
               "AGENTS.md",
               "CLAUDE.md"
             ]

    start = get(root, ".elixir-agent-kit/START.md")
    assert String.starts_with?(start, "# Elixir Agent Kit #{ElixirAgentKit.version()}\n")
    assert start =~ "../deps/elixir_agent_kit/priv/library/CONTRACT.md"
    assert length(Regex.scan(~r/^\d\. /m, start)) == 5
    assert start =~ "`Start at`"
    assert start =~ "its size (small, medium or large)"
    assert start =~ "../deps/elixir_agent_kit/priv/library/templates/task-plan.md"
    assert start =~ "../deps/elixir_agent_kit/priv/library/CONTRACT.md#plan-in-proportion-to-size"
```

In `test "missing library files are listed for the selection"`, replace the second assertion:

```elixir
    assert Installer.missing_library_files("/nonexistent", ["debugging"]) ==
             ~w(CONTRACT.md ROUTING.md ELIXIR.md EVOLUTION.md HANDOFF.md templates/task-plan.md skills/debugging/SKILL.md)
```

Add before `test "missing library files are listed for the selection"`:

```elixir
  test "the plans folder ignores its own contents and keeps plans on uninstall", %{root: root} do
    Installer.run(:install, root)
    assert get(root, ".elixir-agent-kit/plans/.gitignore") == "*\n!.gitignore\n"
    assert get(root, ".elixir-agent-kit/state.tsv") =~ "file\t.elixir-agent-kit/plans/.gitignore\t"
    put(root, ".elixir-agent-kit/plans/2026-11-07-billing.md", "# Task plan")
    assert {:ok, []} = Installer.run(:check, root)
    assert {:ok, _} = Installer.run(:uninstall, root)
    refute File.exists?(Path.join(root, ".elixir-agent-kit/plans/.gitignore"))
    refute File.exists?(Path.join(root, ".elixir-agent-kit/state.tsv"))
    assert get(root, ".elixir-agent-kit/plans/2026-11-07-billing.md") == "# Task plan"
  end

  test "a missing or edited plans ignore file is drift", %{root: root} do
    Installer.run(:install, root)
    File.rm!(Path.join(root, ".elixir-agent-kit/plans/.gitignore"))
    assert {:drift, [".elixir-agent-kit/plans/.gitignore"]} = Installer.run(:check, root)
    assert {:ok, [".elixir-agent-kit/plans/.gitignore"]} = Installer.run(:sync, root)
    put(root, ".elixir-agent-kit/plans/.gitignore", "*.md\n")
    assert {:drift, [".elixir-agent-kit/plans/.gitignore"]} = Installer.run(:check, root)
    assert_raise ArgumentError, ~r/locally modified managed content/, fn ->
      Installer.run(:sync, root)
    end
  end

  test "sync from a state without the plans folder adds only that file", %{root: root} do
    Installer.run(:install, root, agents: [:codex])
    state = Path.join(root, ".elixir-agent-kit/state.tsv")
    File.rm!(Path.join(root, ".elixir-agent-kit/plans/.gitignore"))
    File.rmdir!(Path.join(root, ".elixir-agent-kit/plans"))

    File.write!(
      state,
      state
      |> File.read!()
      |> String.split("\n")
      |> Enum.reject(&String.contains?(&1, "plans/.gitignore"))
      |> Enum.join("\n")
    )

    before = snapshot(root)
    assert {:ok, paths} = Installer.run(:sync, root)
    assert Enum.sort(paths) == [".elixir-agent-kit/plans/.gitignore", ".elixir-agent-kit/state.tsv"]

    assert Map.drop(snapshot(root), [".elixir-agent-kit/plans/.gitignore", ".elixir-agent-kit/state.tsv"]) ==
             Map.drop(before, [".elixir-agent-kit/state.tsv"])

    assert {:ok, []} = Installer.run(:check, root)
  end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `mix test test/installer_test.exs`
Expected: FAIL in "installs only references and round trips" (snapshot lacks `plans/.gitignore`, 4 steps), "missing library files are listed for the selection", and the three new tests.

- [ ] **Step 3: Implement the installer changes**

In `lib/elixir_agent_kit/installer.ex`:

Add after `@agents ~w(codex claude generic)`:

```elixir
  @plans_ignore ".elixir-agent-kit/plans/.gitignore"
```

In `missing_library_files/2`, replace the file list line:

```elixir
    ~w(CONTRACT.md ROUTING.md ELIXIR.md EVOLUTION.md HANDOFF.md templates/task-plan.md)
```

In `files/3`, replace the `payload` line:

```elixir
    # The plans folder ignores its own contents, so the consumer's .gitignore is never touched.
    payload = %{
      ".elixir-agent-kit/START.md" => {:file, start_document(config, target.(1))},
      @plans_ignore => {:file, "*\n!.gitignore\n"}
    }
```

In `entry/2`, update the comment above it from "four steps" to "five steps" and replace steps 1 to 4 with:

```elixir
    1. Name the task's primary risk and its size (small, medium or large) in one line,
       from the request alone: a screen, stored data or a provider call, code quality
       or process state, an operational domain, or delivery. Revise the size after the
       first inspection when the code shows otherwise.
    2. Pick one workflow from the tables below. When two neighbors fit, the
       [routing guide](#{target}/ROUTING.md) separates them. A bounded, fully specified
       edit picks NONE.
    3. Read that workflow's SKILL.md from the dependency together with the
       [shared contract](#{target}/CONTRACT.md); copy neither into this project.
    4. State the workflow ID or NONE and the size in your plan or report, with the
       reason in one line and the workflow's `Start at` input as the first thing you
       open; then investigate the way the workflow says, producing the artifact its
       first step asks for. The local contracts say what this project must do; the
       workflow says how to inspect, decide and prove it.
    5. For a large task, before the first edit, write the plan from the
       [task-plan template](#{target}/templates/task-plan.md) in
       `.elixir-agent-kit/plans/`, following the contract's
       [planning rules](#{target}/CONTRACT.md#plan-in-proportion-to-size), and reread
       it after any compaction.
```

In `parse_entry/1`, in the `"file" ->` branch, add `path == @plans_ignore or` after `path == ".elixir-agent-kit/START.md" or`:

```elixir
            "file" ->
              String.starts_with?(path, ".elixir-agent-kit/library/") or
                path == ".elixir-agent-kit/START.md" or
                path == @plans_ignore or
                path in [pointer_path("claude"), pointer_path("codex")] or
                Regex.match?(~r/^\.(agents|claude)\/skills\/eak-[a-z0-9-]+\/SKILL\.md$/, path)
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `mix test test/installer_test.exs`
Expected: PASS, 0 failures. The existing "all installed local Markdown references resolve" test also confirms the new template and anchor links resolve.

- [ ] **Step 5: Run the full Elixir check**

Run: `mix check`
Expected: format, compile with warnings as errors and all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/elixir_agent_kit/installer.ex test/installer_test.exs
git commit -m "Own the plans folder and add the size and step 5 to START.md

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 3: Install smoke test covers the plans folder

**Files:**
- Modify: `scripts/smoke_install.py:70-71`

**Interfaces:**
- Consumes: `.elixir-agent-kit/plans/.gitignore` from Task 2.

- [ ] **Step 1: Update the managed-path assertion**

Replace:

```python
    assert managed == {".elixir-agent-kit/START.md", ".elixir-agent-kit/state.tsv", "CLAUDE.md"} | pointers, managed
```

with:

```python
    owned = {".elixir-agent-kit/START.md", ".elixir-agent-kit/plans/.gitignore", ".elixir-agent-kit/state.tsv", "CLAUDE.md"}
    assert managed == owned | pointers, managed
    assert (root / ".elixir-agent-kit/plans/.gitignore").read_text() == "*\n!.gitignore\n"
```

- [ ] **Step 2: Run the smoke against this checkout**

Run: `python3 scripts/smoke_install.py --git-url "$(pwd)" --ref "$(git rev-parse HEAD)"`
Expected: exit 0. (Without `--git-url` it fetches the published `v0.6.0` tag, which predates this change and would fail the new assertion; the release PR moves the default ref.)

- [ ] **Step 3: Commit**

```bash
git add scripts/smoke_install.py
git commit -m "Assert the plans folder in the install smoke

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 4: Evaluation cases carry an expected size

**Files:**
- Modify: `scripts/check_library.py` (the `for case in cases:` loop)
- Modify: `evals/routing.json`
- Modify: `evals/README.md`

**Interfaces:**
- Produces: field `expected_size` (`"small" | "medium" | "large"`) on every case; cases E55 and E56.

- [ ] **Step 1: Write the failing check**

In `scripts/check_library.py`, inside `for case in cases:`, add:

```python
    if case.get("expected_size") not in {"small", "medium", "large"}:
        errors.append(f"Evaluation case lacks expected_size small, medium or large: {case['id']}")
```

- [ ] **Step 2: Run it to verify it fails**

Run: `python3 scripts/check_library.py`
Expected: exit 1 with 54 "lacks expected_size" lines.

- [ ] **Step 3: Label every case and add E55 and E56**

Run this once from the repository root (it rewrites `evals/routing.json` with two-space indentation and non-ASCII kept; check `git diff --stat` afterwards):

```bash
python3 -I - <<'EOF'
import json
from pathlib import Path
path = Path("evals/routing.json")
data = json.loads(path.read_text())
large = {"E01", "E02", "E07", "E13", "E16", "E20", "E23", "E26", "E28", "E34", "E36", "E53"}
small = {"E18", "E29", "E48", "E54"}
for case in data["cases"]:
    case["expected_size"] = "large" if case["id"] in large else "small" if case["id"] in small else "medium"
data["cases"] += [
    {
        "id": "E55",
        "request": "Extraia o fluxo de cobrança, hoje espalhado entre a LiveView de checkout, o contexto Billing e dois workers Oban, para um contexto próprio, mantendo funcionando os jobs que já estão enfileirados.",
        "expected_primary": "architecture-review",
        "allowed_alternatives": ["migration-compatibility"],
        "expected_size": "large",
        "success_signals": [
            "Classifica a tarefa como grande e escreve o plano em .elixir-agent-kit/plans/ antes da primeira edição",
            "A primeira fatia do plano é o artefato do primeiro passo do workflow",
            "Trata os jobs enfileirados como gatilho de parada ou como fatia própria com estado intermediário seguro"
        ],
        "failure_signals": [
            "Edita código antes de escrever o plano",
            "Move tudo num único passo sem estados intermediários seguros"
        ]
    },
    {
        "id": "E56",
        "request": "Os eventos de progresso das tarefas chegam fora de ordem no worker que grava o status, no PubSub e na LiveView. Corrija o fluxo inteiro, do worker até a tela.",
        "expected_primary": "async-state",
        "allowed_alternatives": ["process-lifecycle", "data-contracts"],
        "expected_size": "large",
        "success_signals": [
            "Escreve o plano em .elixir-agent-kit/plans/ antes da primeira edição, com uma fatia e uma verificação por fronteira",
            "O relatório final informa o tamanho, o workflow e o caminho do plano"
        ],
        "failure_signals": [
            "Edita código antes de planejar",
            "Para e pede aprovação do plano sem que ele amplie o escopo, mexa em dado persistido ou contrato público, ou tenha passo irreversível"
        ]
    }
]
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n")
EOF
git diff --stat evals/routing.json
```

Expected: only `evals/routing.json` changes, by `expected_size` lines and the two new cases. The file is already `json.dumps(..., ensure_ascii=False, indent=2)` output (verified 2026-11-07), so no other line moves.

- [ ] **Step 4: Update the evaluation README**

In `evals/README.md`, change `These 54 cases` to `These 56 cases`, and append this paragraph at the end of the file:

```markdown
Every case carries `expected_size` (`small`, `medium` or `large`), following the
contract's "Plan in proportion to size" table, so a live evaluation also judges
the size classification. E55 (extracting a billing flow from a LiveView, a
context and two Oban workers while queued jobs keep working) and E56 (progress
events out of order across a worker, PubSub and a LiveView) are large cases: the
expected behavior is a plan file in `.elixir-agent-kit/plans/` before the first
edit, and stopping for approval only on a stop-and-ask trigger.
```

- [ ] **Step 5: Run the check to verify it passes**

Run: `python3 scripts/check_library.py`
Expected: `OK: 35 workflows; ...`

- [ ] **Step 6: Commit**

```bash
git add scripts/check_library.py evals/routing.json evals/README.md
git commit -m "Give every evaluation case an expected size and add two large cases

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 5: Documentation and changelog

**Files:**
- Modify: `README.md` (section "What an agent does with it", the routing-case count sentence, table "What lands in your project")
- Modify: `docs/README.pt-BR.md` (the mirrored sections)
- Modify: `docs/architecture.md` (section "Reference-only installation")
- Modify: `docs/compatibility.md` (section "Fresh-session verification")
- Modify: `CHANGELOG.md` (`## Unreleased`)

**Interfaces:**
- Consumes: names from Tasks 1-4: `.elixir-agent-kit/plans/.gitignore`, `templates/task-plan.md`, "Plan in proportion to size", E55, E56.

- [ ] **Step 1: README.md**

In "What an agent does with it" (the source text is wrapped across lines; match it ignoring line breaks), replace "Either one asks for four steps before any source file is opened:" with "Either one asks for five steps before any source file is opened:"; in step 1, after "from the request alone: here, process state." add " It also names the size: small, medium or large."; and after step 4 add:

```markdown
5. When the task is large (it crosses contexts, touches stored data and code
   together, needs more than one delivery or will not fit one session), it writes
   a plan from the [task-plan template](priv/library/templates/task-plan.md) in
   `.elixir-agent-kit/plans/` before the first edit and rereads it after a
   compaction. It stops for approval only when the plan widens the requested
   scope, changes persisted data or a public contract, or has an irreversible step.
```

Replace "hold 46 requests like that one," with "hold 56 requests like that one,". In "What lands in your project", update the `START.md` row purpose to "Five steps that end in a named workflow choice and a task size, then the enabled catalog linking into the dependency." and add after the `state.tsv` row:

```markdown
| `.elixir-agent-kit/plans/.gitignore` | Keeps the plans folder out of Git without touching your `.gitignore`; large tasks write their plans next to it, and uninstall keeps those plans. |
```

- [ ] **Step 2: docs/README.pt-BR.md**

Mirror Step 1 (wrapped text; match ignoring line breaks): "pede quatro passos" -> "pede cinco passos"; in step 1, after "aqui, estado de processo." add " Também nomeia o tamanho: pequeno, médio ou grande."; after step 4 add:

```markdown
5. Quando a tarefa é grande (cruza contextos, mexe em dado armazenado e em código
   juntos, pede mais de uma entrega ou não cabe numa sessão), escreve um plano a
   partir do [template de plano](../priv/library/templates/task-plan.md) em
   `.elixir-agent-kit/plans/` antes da primeira edição e o relê depois de uma
   compactação. Só para e pede aprovação quando o plano amplia o escopo pedido,
   muda dado persistido ou contrato público, ou tem passo irreversível.
```

Replace "guardam 46 pedidos como esse" with "guardam 56 pedidos como esse"; update the `START.md` row to "Cinco passos que terminam na escolha nomeada de um workflow e no tamanho da tarefa, depois o catálogo habilitado com links para a dependência." and add after the `state.tsv` row:

```markdown
| `.elixir-agent-kit/plans/.gitignore` | Mantém a pasta de planos fora do Git sem mexer no seu `.gitignore`; tarefas grandes escrevem seus planos ao lado dele, e o uninstall preserva esses planos. |
```

- [ ] **Step 3: docs/architecture.md**

In "Reference-only installation", after the sentence ending "removal prunes only directories the kit itself emptied." add:

```markdown
It also owns `.elixir-agent-kit/plans/.gitignore`, which ignores the folder's
contents so large tasks can keep a plan there across compaction without the
installer editing the project's `.gitignore`; uninstall removes that file and
keeps any plan beside it.
```

- [ ] **Step 4: docs/compatibility.md**

In "Fresh-session verification", after step 4 add, renumbering the old step 5 to 6:

```markdown
5. For a large request, observe that the session names the size, writes a plan in
   `.elixir-agent-kit/plans/` before its first edit, and stops for approval only on
   a stop-and-ask trigger from the contract.
```

- [ ] **Step 5: CHANGELOG.md**

Under `## Unreleased`, add:

```markdown
- The shared contract plans in proportion to size: `START.md` step 1 names the task
  size (small, medium or large) and a new step 5 asks a large task to write a plan
  from `templates/task-plan.md` in `.elixir-agent-kit/plans/` before the first edit,
  to reread it after compaction and to stop only on a stop-and-ask trigger.
- The installer owns `.elixir-agent-kit/plans/.gitignore`, which ignores the
  folder's contents without touching the project's `.gitignore`; uninstall keeps
  existing plans. `check` reports the file as drift when missing or edited.
- Every evaluation case carries `expected_size`; E55 and E56 add two large cases.
```

- [ ] **Step 6: Verify links and docs**

Run: `python3 scripts/check_library.py`
Expected: `OK: 35 workflows; ...` with no broken links.

- [ ] **Step 7: Commit**

```bash
git add README.md docs/README.pt-BR.md docs/architecture.md docs/compatibility.md CHANGELOG.md
git commit -m "Document size-proportional planning and the plans folder

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

### Task 6: Full verification and pull request

**Files:** none new.

- [ ] **Step 1: Rebase on the concurrent main**

Run: `git fetch origin && git rebase origin/main`
Expected: clean rebase. On conflicts in `evals/routing.json`, `evals/README.md`, `README.md`, `docs/README.pt-BR.md` or `CHANGELOG.md`, keep both sides; new cases from the other session (E57+) must also carry `expected_size`.

- [ ] **Step 2: Run every documented check (CONTRIBUTING.md)**

```bash
mix check
python3 scripts/check_library.py
python3 scripts/smoke_install.py --git-url "$(pwd)" --ref "$(git rev-parse HEAD)"
python3 scripts/smoke_migration.py
mix hex.build
```

Expected: all exit 0. Report structural results only; no live client evaluation was run.

- [ ] **Step 3: Push and open the PR**

```bash
git push -u origin claude/elixir-skills-usage-687f50
gh pr create --base main --title "Plan in proportion to task size" --body-file <body>
```

The body lists the spec and plan paths, the changes per area, the exact checks run, "Not run: live client evaluation", and ends with the Claude Code attribution line. Tell the other session (agent-board patterns) the PR number so release PR #37 can bundle it. Do not merge or tag without the owner.
