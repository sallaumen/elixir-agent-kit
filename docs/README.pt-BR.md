# Elixir Agent Kit

Uma biblioteca compartilhada de 34 práticas para agentes, distribuída pelo Mix.
Os agentes leem os textos diretamente da dependência. A instalação mantém apenas
um índice, um registro de propriedade e referências em `AGENTS.md`/`CLAUDE.md`.
Não copia a biblioteca nem cria dezenas de skills dentro da aplicação.

```elixir
{:elixir_agent_kit,
 git: "https://github.com/sallaumen/elixir-agent-kit.git",
 tag: "v0.4.0",
 only: [:dev, :test],
 runtime: false}
```

Em `project/0`, configure:

```elixir
elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all]
```

Execute `mix deps.get`, `mix agent_kit.install --dry-run`,
`mix agent_kit.install` e `mix agent_kit.check`. Confira os aliases locais antes.
A dependência é pública: não coloque token no `mix.exs`. Ainda não há publicação Hex.

Para migrar da v0.1.1, atualize a tag, rode `mix deps.update elixir_agent_kit` e
`mix agent_kit.sync --dry-run`; confira as remoções e execute `mix agent_kit.sync`.
O instalador remove apenas cópias e atalhos registrados e não modificados. Edições
locais bloqueiam a migração para que sejam preservadas. Arquivos próprios sobrevivem.

Versione dependência, lockfile, índice, registro e blocos de instruções. Não
versione `deps/`. Em um checkout novo, execute `mix deps.get` antes de usar as
práticas. O cliente precisa conseguir ler os arquivos da dependência, mesmo que
ela esteja ignorada pelo Git; esta versão não registra comandos de skills nativas.

`mix agent_kit.check` confere a instalação, não a versão mais recente.
`mix agent_kit.outdated` consulta tags públicas sem alterar nada; com `--check`,
uma atualização disponível causa saída de erro. Falhas de rede significam que não
foi possível determinar a versão atual. Não há atualização automática em segundo plano.

Melhorias reutilizáveis vão para o kit; regras de domínio ficam no projeto.
Uma melhoria revisada vira release e cada consumidor adota a versão em um PR.
As 34 práticas agora estão agrupadas em frontend, backend, engenharia transversal
e entrega. O agente começa pelo [guia de seleção](../priv/library/ROUTING.md),
escolhe a prática específica no [catálogo](../priv/library/CATALOG.md) e lê
seus critérios de qualidade e validação diretamente na dependência.
Veja a [política de evolução](../priv/library/EVOLUTION.md), o
[prompt completo de instalação](INSTALL_WITH_AI.md), a
[compatibilidade](compatibility.md) e o [guia principal](../README.md).
