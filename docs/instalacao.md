# Instalar o Elixir Agent Kit

[English](installation.md)

Em um projeto Mix com Elixir 1.15+, adicione esta entrada à lista em `deps/0`:

```elixir
{:elixir_agent_kit, "~> 1.2", only: [:dev, :test], runtime: false}
```

Para usar Codex e Claude Code, adicione esta entrada à lista em `project/0`:

```elixir
elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all]
```

Na raiz do projeto, rode:

```sh
mix deps.get
mix agent_kit.install
mix agent_kit.check
```

Quando o check informar **no changes needed**, versione `mix.exs`, `mix.lock` e
os caminhos que o instalador listou. Abra uma nova sessão do agente e peça que
siga `.elixir-agent-kit/START.md` para uma tarefa do projeto.

Sem configuração de agentes, o padrão é `:generic` com todos os workflows.
Para ver os arquivos que serão alterados, rode `mix agent_kit.install --dry-run`
antes de instalar. Versione as referências geradas e deixe `deps/` fora do Git.
Em um clone novo, rode `mix deps.get`; no CI, use `mix agent_kit.check` em
seguida para detectar diferenças.

## Atualizar ou migrar do Git para o Hex

Mantenha uma única entrada da dependência. Se usa Git, substitua essa entrada
pelo exemplo do Hex acima e preserve os agentes e workflows já selecionados.

```sh
mix deps.update elixir_agent_kit
mix agent_kit.sync --dry-run
mix agent_kit.sync
mix agent_kit.check
```

Revise o diff e versione o lockfile junto com os arquivos gerados.
`~> 1.2` aceita versões a partir da 1.2 e anteriores à 2.0. O lockfile mantém
as instalações reproduzíveis; a atualização acontece quando você pede ao Mix.

## Instalar pelo Git

Se precisar de uma release Git específica, use esta entrada **no lugar** da
entrada Hex. Os passos de instalação são os mesmos:

```elixir
{:elixir_agent_kit, git: "https://github.com/sallaumen/elixir-agent-kit.git",
 tag: "v1.2.2", only: [:dev, :test], runtime: false}
```
