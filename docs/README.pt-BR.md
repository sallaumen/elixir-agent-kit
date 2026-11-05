# Elixir Agent Kit

Práticas compartilhadas para agentes de programação, versionadas junto do seu
projeto Elixir. Inclui 33 workflows em inglês, contrato comum e contexto técnico
condicional para Elixir, Phoenix, Ecto e Oban.

## Instalar

Adicione às dependências existentes do `mix.exs`:

```elixir
{:elixir_agent_kit,
 git: "https://github.com/sallaumen/elixir-agent-kit.git",
 tag: "v0.1.1",
 only: [:dev, :test],
 runtime: false}
```

Na lista retornada por `project/0`, adicione:

```elixir
elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all]
```

Selecione apenas os clientes que você usa. Depois:

```sh
mix deps.get
mix agent_kit.install --dry-run
mix agent_kit.install
mix agent_kit.check
```

O download pelo GitHub público não exige token. Esta edição ainda não está no
Hex. A instalação não chama modelos, não inicia a aplicação e não configura
credenciais de provedores.

O instalador preserva instruções locais, recusa conflitos e registra os arquivos
que gerencia. Versione o conteúdo gerado para que outros agentes e worktrees
recebam a mesma edição. Uma segunda instalação deve informar que nada mudou.

Para DeepSeek e outros modelos, a integração depende do executor: `:generic`
prepara o `AGENTS.md`, mas o executor precisa efetivamente lê-lo. Arquivos
instalados não comprovam que uma sessão carregou as práticas.

## Atualizar e remover

Para atualizar, escolha uma nova tag no `mix.exs`, execute
`mix deps.update elixir_agent_kit`, revise `mix agent_kit.sync --dry-run`, aplique
`mix agent_kit.sync` e rode `mix agent_kit.check` e os checks do projeto.

Para remover, execute `mix agent_kit.uninstall` antes de retirar a dependência.
Conteúdo gerenciado que tenha sido editado bloqueia a operação para preservar o
trabalho local. Consulte a recuperação de conflitos no guia principal.

## Instalar com outra IA

Copie o [prompt de instalação](INSTALL_WITH_AI.md) para o agente que trabalha no
projeto de destino. Ele contém a versão, os comandos, a preservação das regras
locais e a verificação de instalação repetida.

- [Documentação completa](../README.md)
- [Catálogo de workflows](../priv/library/CATALOG.md)
- [Compatibilidade e limitações](compatibility.md)
- [Origem e adaptação das capacidades](provenance.md)
- [Licença MIT](../LICENSE)
