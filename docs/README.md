# Documentation map

| Need | Start here |
|---|---|
| Install or migrate an existing Elixir application | [AI installation prompt](INSTALL_WITH_AI.md) and [Portuguese quick start](README.pt-BR.md) |
| Select a workflow | [Area routing](../priv/library/ROUTING.md), then [the grouped catalog](../priv/library/CATALOG.md) |
| Understand expected execution quality | [Shared contract](../priv/library/CONTRACT.md) and the selected `SKILL.md` |
| Understand what is distributed and why | [Architecture](architecture.md) and [client compatibility](compatibility.md) |
| Review how the 33 workflows were deepened | [Source review matrix](source-review.md) and [provenance](provenance.md) |
| Contribute a reusable improvement | [Evolution policy](../priv/library/EVOLUTION.md) and [contributing guide](../CONTRIBUTING.md) |
| Distinguish tests from live agent behavior | [Verification](verification.md) and [evaluator-only cases](../evals/README.md) |

The package's editable workflow source is `priv/library/`. Consumer projects
commit only references and an ownership record. Their domain rules stay local.
