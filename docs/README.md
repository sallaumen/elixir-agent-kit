# Documentation map

| Need | Start here |
|---|---|
| Install or migrate an existing Elixir application | [AI installation prompt](INSTALL_WITH_AI.md) and [Portuguese quick start](README.pt-BR.md) |
| Select a workflow | [Area routing](../priv/library/ROUTING.md), then [the grouped catalog](../priv/library/CATALOG.md) |
| Understand expected execution quality | [Shared contract](../priv/library/CONTRACT.md) and the selected `SKILL.md` |
| Understand what is distributed and why | [Architecture](architecture.md) and [client compatibility](compatibility.md) |
| Review how the 36 workflows were deepened, and where each lens and its license came from | [Source review matrix](source-review.md) and [provenance](provenance.md#review-lenses-and-their-licenses) |
| Contribute a reusable improvement | [Evolution policy](../priv/library/EVOLUTION.md) and [contributing guide](../CONTRIBUTING.md) |
| Distinguish tests from live agent behavior | [Client compatibility](compatibility.md) and the [evaluator-only cases](https://github.com/sallaumen/elixir-agent-kit/blob/main/evals/README.md) |
| Read the initial release's verification record | [Verification](verification.md), kept as history |

The package's editable workflow source is `priv/library/`. Consumer projects
commit only references and an ownership record. Their domain rules stay local.
