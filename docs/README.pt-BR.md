# Elixir Agent Kit

**Práticas de código compartilhadas para agentes de IA, versionadas junto com o seu projeto Elixir.**

Fixe o kit como qualquer dependência Mix. Todo agente que trabalhar no projeto, seja
Codex, Claude Code ou o seu próprio harness, lê os mesmos 36 workflows revisados
direto de `deps/`: o que inspecionar, quais decisões importam, o que é "pronto" e
como provar. Sem biblioteca copiada que envelhece, sem serviço, sem chamada a
modelo, nada vai para produção.

<p align="center">
  <img src="assets/how-it-works.svg" alt="Como funciona: o projeto fixa o kit como dependência Mix; o instalador escreve referências pequenas; a sessão do agente segue essas referências até a dependência e lê um workflow." width="960">
</p>

## Por que uma dependência

- **Uma fonte, muitos agentes, muitos projetos.** Um workflow melhora uma vez, em
  `priv/library/`, sai como tag, e cada aplicação o adota num PR de dependência
  comum. Dois agentes no mesmo checkout leem texto idêntico.
- **Workflows que dizem o que fazer, não como se sentir.** Cada `SKILL.md` nomeia
  as entradas a inspecionar, os pontos de decisão, os critérios de qualidade, a
  evidência que valida o resultado e as armadilhas. Veja
  [`async-state`](../priv/library/skills/async-state/SKILL.md) para a forma.
- **Honesto por construção.** O instalador escreve referências e checksums, nunca
  a cópia de um workflow. `mix agent_kit.check` roda offline no CI e falha em
  drift ou quando falta um arquivo da biblioteca apontado pelos links. Nada aqui
  afirma que um modelo seguiu o texto; isso se verifica em uma sessão nova, como
  descreve [compatibilidade](compatibility.md).

## Começo rápido

Requer Elixir 1.15+, Erlang/OTP compatível e Git. As releases são tags públicas do
Git, **não Hex**; não há token.

**1. Adicione a dependência** em `deps/0` no `mix.exs`:

```elixir
{:elixir_agent_kit,
 git: "https://github.com/sallaumen/elixir-agent-kit.git",
 tag: "v0.6.0",
 only: [:dev, :test],
 runtime: false}
```

**2. Escolha agentes e workflows** em `project/0`:

```elixir
elixir_agent_kit: [agents: [:codex, :claude, :generic], skills: :all]
```

**3. Instale** a partir da raiz do projeto Mix (confira os seus aliases antes; o
kit não inicia aplicação, banco nem `mix setup`):

```sh
mix deps.get
mix agent_kit.install
mix agent_kit.check
```

Você verá os caminhos que o instalador escreveu e o próximo passo:

```text
Changed 6 paths:
  .agents/skills/elixir-agent-kit/SKILL.md
  .claude/skills/elixir-agent-kit/SKILL.md
  .elixir-agent-kit/START.md
  .elixir-agent-kit/state.tsv
  AGENTS.md
  CLAUDE.md

Next: run mix agent_kit.check, commit these paths, then ask a fresh agent
session to follow .elixir-agent-kit/START.md and name the workflow it selects.
```

Versione `mix.exs`, `mix.lock` e esses caminhos. Não versione `deps/`. Coloque
`mix agent_kit.check` no gate que roda depois de `mix deps.get`. Prefira
`mix agent_kit.install --dry-run` quando quiser ver o plano antes, e o
[prompt de instalação com IA](INSTALL_WITH_AI.md) quando um agente fizer a
configuração.

## O que um agente faz com ele

> "Depois de reconectar, uma mensagem atrasada marca a tarefa anterior como
> concluída e esconde o progresso da atual."

A sessão carrega `AGENTS.md` ou `CLAUDE.md` e segue o bloco até
`.elixir-agent-kit/START.md`, ou encontra a skill gerada `elixir-agent-kit` no
seu próprio diretório de skills. Qualquer um dos dois pede quatro passos antes de
abrir qualquer arquivo-fonte:

1. Nomeia em uma linha o risco principal da tarefa, só a partir do pedido: aqui,
   estado de processo.
2. Escolhe um workflow nas tabelas do `START.md`, o mais estreito que sirva:
   [`async-state`](../priv/library/skills/async-state/SKILL.md). Só quando dois
   vizinhos servem é que abre o [guia de seleção](../priv/library/ROUTING.md)
   para separá-los; uma edição delimitada e totalmente especificada escolhe NONE.
3. Lê o `SKILL.md` desse workflow na dependência junto com o
   [contrato compartilhado](../priv/library/CONTRACT.md), sem copiar nenhum dos
   dois para o projeto. O workflow diz o que inspecionar (ciclo de vida de eventos
   e jobs, IDs estáveis, comportamento ao reconectar), o que decidir (um único dono
   durável do estado; idempotência por efeito), como é qualidade (a UI se
   reconcilia após recarregar a partir de identificadores persistidos;
   retentativas nunca avançam o estado falsamente) e que evidência mostrar
   (entrega duplicada, atrasada e fora de ordem exercitada no fluxo real).
4. Declara o ID do workflow, ou NONE, no seu plano com o motivo em uma linha, abre
   a entrada `Start at` do workflow antes de qualquer outra coisa e produz o
   artefato que o primeiro passo do workflow pede; depois investiga do jeito que o
   workflow diz e entrega com o [template de handoff](../priv/library/HANDOFF.md):
   resultado, workflow e versão usados, checks de fato executados, limites.

Os casos de seleção em [`evals/`](https://github.com/sallaumen/elixir-agent-kit/blob/main/evals/README.md)
guardam 46 pedidos como esse, com o workflow esperado e os sinais de uma resposta
boa ou ruim. Ficam fora do payload instalado para que um agente nunca veja o
gabarito.

## O catálogo de relance

Escolha a área, depois o gatilho mais estreito. Cada entrada aponta para o
workflow completo; o [catálogo](../priv/library/CATALOG.md) lista as frases de
gatilho. Domínios operacionais são padrões de produto; um projeto sem eles pode
deixar esses IDs fora da sua seleção `skills:`.

| Frontend e experiência do usuário | Backend e dados | Estrutura e qualidade de código | Domínios operacionais | Entrega e build |
|---|---|---|---|---|
| [ui-identity](../priv/library/skills/ui-identity/SKILL.md) | [data-contracts](../priv/library/skills/data-contracts/SKILL.md) | [architecture-review](../priv/library/skills/architecture-review/SKILL.md) | [ai-orchestration](../priv/library/skills/ai-orchestration/SKILL.md) | [delivery-coordination](../priv/library/skills/delivery-coordination/SKILL.md) |
| [layout-density](../priv/library/skills/layout-density/SKILL.md) | [migration-compatibility](../priv/library/skills/migration-compatibility/SKILL.md) | [abstraction-layers](../priv/library/skills/abstraction-layers/SKILL.md) | [notifications](../priv/library/skills/notifications/SKILL.md) | [pipeline-design](../priv/library/skills/pipeline-design/SKILL.md) |
| [navigation-ux](../priv/library/skills/navigation-ux/SKILL.md) | [security-boundaries](../priv/library/skills/security-boundaries/SKILL.md) | [module-design](../priv/library/skills/module-design/SKILL.md) | [operational-alerts](../priv/library/skills/operational-alerts/SKILL.md) | [build-dependencies](../priv/library/skills/build-dependencies/SKILL.md) |
| [responsive-layout](../priv/library/skills/responsive-layout/SKILL.md) | [provider-calls](../priv/library/skills/provider-calls/SKILL.md) | [code-consolidation](../priv/library/skills/code-consolidation/SKILL.md) | [integration-setup](../priv/library/skills/integration-setup/SKILL.md) | [delivery-validation](../priv/library/skills/delivery-validation/SKILL.md) |
| [direct-interactions](../priv/library/skills/direct-interactions/SKILL.md) | [data-pipelines](../priv/library/skills/data-pipelines/SKILL.md) | [test-strategy](../priv/library/skills/test-strategy/SKILL.md) | [metrics-costs](../priv/library/skills/metrics-costs/SKILL.md) |  |
| [accessibility](../priv/library/skills/accessibility/SKILL.md) |  | [code-review](../priv/library/skills/code-review/SKILL.md) | [simulation-isolation](../priv/library/skills/simulation-isolation/SKILL.md) |  |
| [design-system](../priv/library/skills/design-system/SKILL.md) |  | [debugging](../priv/library/skills/debugging/SKILL.md) | [commercial-eligibility](../priv/library/skills/commercial-eligibility/SKILL.md) |  |
| [motion-design](../priv/library/skills/motion-design/SKILL.md) |  | [performance](../priv/library/skills/performance/SKILL.md) | [revision-lineage](../priv/library/skills/revision-lineage/SKILL.md) |  |
|  |  | [async-state](../priv/library/skills/async-state/SKILL.md) |  |  |
|  |  | [process-lifecycle](../priv/library/skills/process-lifecycle/SKILL.md) |  |  |
|  |  | [house-patterns](../priv/library/skills/house-patterns/SKILL.md) |  |  |

Três deles têm um modo padrão diferente: `code-review` revisa sem editar,
`delivery-validation` analisa sem reparar, `delivery-coordination` coordena. O
escopo explícito do usuário sempre vence um padrão. O
[contexto Elixir](../priv/library/ELIXIR.md) indexa uma referência curta por assunto
(forma do código, pipelines, arquitetura de dependências, OTP, Phoenix e LiveView,
Ecto, Oban, ExUnit, clientes HTTP, segurança, telemetria, builds, autoria de
bibliotecas, o ciclo de trabalho do agente) e as bibliotecas recomendadas; o agente
lê só as que o `mix.lock` e a tarefa pedem.

## O que fica no projeto

| Caminho | Para quê |
|---|---|
| `.elixir-agent-kit/START.md` | Quatro passos que terminam na escolha nomeada de um workflow, depois o catálogo habilitado com links para a dependência. |
| `.elixir-agent-kit/state.tsv` | Versão, seleção e SHA-256 de cada arquivo e bloco que o instalador possui. |
| `AGENTS.md` | Bloco delimitado para Codex e harnesses genéricos (`:codex`, `:generic`). |
| `CLAUDE.md` | Bloco delimitado para Claude Code (`:claude`). Quando `AGENTS.md` é gerenciado ou já existe, o bloco o importa com `@AGENTS.md`, porque o Claude Code deixa de ler `AGENTS.md` assim que um `CLAUDE.md` se aplica. |
| `.claude/skills/elixir-agent-kit/SKILL.md` | Uma skill gerada para a descoberta nativa do Claude Code: descrição, catálogo filtrado pela sua seleção e links para a dependência. |
| `.agents/skills/elixir-agent-kit/SKILL.md` | A mesma skill gerada, para o Codex. |

Texto fora dos blocos gerenciados é seu e sobrevive a todo sync. Nenhum corpo de
workflow é copiado; a biblioteca fica em `deps/elixir_agent_kit/priv/library/`.
Uma skill pré-existente chamada `elixir-agent-kit` bloqueia a instalação até ser
renomeada. Caminhos de dependência personalizados são resolvidos pelo Mix; uma
dependência local externa por caminho produz links absolutos e precisa de um novo
sync depois de mover. Em um umbrella, rode as tasks a partir da raiz do umbrella:
do diretório de uma aplicação, o `deps/` compartilhado fica fora da raiz do
projeto, e os links saem absolutos. `mix agent_kit.check` compara cada caminho
possuído com o que o pacote carregado geraria e também verifica que os arquivos
da biblioteca apontados pelos links existem.

## Comandos

| Comando | Efeito |
|---|---|
| `mix agent_kit.list` | Imprime IDs, modos e gatilhos dos workflows agrupados por área. |
| `mix agent_kit.install` | Cria ou sincroniza as referências após uma verificação prévia de conflitos; um alias de `sync`. |
| `mix agent_kit.sync` | A mesma reconciliação: regenera arquivos e blocos possuídos, remove arquivos gerados legados não modificados, recusa conteúdo gerenciado modificado localmente. |
| `mix agent_kit.check` | Comparação offline e somente leitura com o pacote carregado e a configuração, mais a verificação de que cada arquivo da biblioteca apontado pelos links existe; falha em drift. |
| `mix agent_kit.outdated` | Consulta as tags públicas estáveis do Git e informa a versão carregada e a mais recente; `--check` falha quando há tag mais nova. |
| `mix agent_kit.uninstall` | Remove referências e estado possuídos e não modificados; poda só os diretórios que esvaziou. |

`install`, `sync` e `check` aceitam `--agents codex,claude,generic` e
`--skills ID,ID` para uma execução; `install`, `sync` e `uninstall` aceitam
`--dry-run`. Quando `project/0` declara `:elixir_agent_kit`, essa entrada é a fonte
da verdade e uma chave removida volta ao seu padrão; sem a entrada, a seleção
registrada em `.elixir-agent-kit/state.tsv` é mantida. Restrinja a descoberta com
`skills: ["debugging", "code-review"]`; a seleção molda o índice e as skills
apontadoras, não é um limite de acesso. Um projeto com `CLAUDE.md` e sem `:claude`
na seleção recebe um aviso, porque o Claude Code não veria o kit. Nenhuma task
inicia a sua aplicação nem chama um modelo.

## Atualizações e uma fonte só

1. Leia o [changelog](../CHANGELOG.md); `mix agent_kit.outdated` diz se existe tag mais nova.
2. Troque a tag no `mix.exs` e rode `mix deps.update elixir_agent_kit`.
3. Rode `mix agent_kit.sync --dry-run`, inspecione, depois `mix agent_kit.sync`.
4. Rode `mix agent_kit.check` e os gates do seu projeto; versione o diff.

Lições reutilizáveis sobem pela [política de evolução](../priv/library/EVOLUTION.md)
e pelo [template de proposta](../priv/library/templates/practice-proposal.md);
regras de produto ficam na aplicação. Uma instalação 0.1 migra do mesmo jeito: o
sync remove as cópias registradas e os wrappers `eak-*` e mantém tudo o que não
possui. Conteúdo gerenciado editado, colisões desconhecidas, marcadores
malformados e saídas em symlink bloqueiam qualquer escrita antes de começar; não
existe opção de força.

## Garantias e limites

- Zero dependências Elixir de terceiros no seu projeto (`ex_doc` é uma ferramenta
  só de desenvolvimento que gera a documentação deste pacote), sem telemetria,
  sem configuração global de cliente, sem credenciais.
- `check` é offline e verifica esta instalação, não a atualidade; `outdated` é
  uma consulta de rede explícita, nunca um atualizador em segundo plano.
- Um checkout novo precisa de `mix deps.get` antes de qualquer agente ler um
  workflow, e o cliente precisa conseguir ler arquivos ignorados em `deps/`. Um
  harness com DeepSeek ou personalizado precisa carregar `AGENTS.md` ou o índice
  no seu worktree real.
- Testes estruturais e smoke de consumidor provam links, preservação e migração.
  Não provam que um cliente vivo descobriu ou seguiu uma prática. Use o
  procedimento de sessão nova em [compatibilidade](compatibility.md).

## Documentação

[Mapa da documentação](README.md) ·
[Instalar com um agente de IA](INSTALL_WITH_AI.md) ·
[English](../README.md) ·
[Arquitetura](architecture.md) ·
[Compatibilidade e avaliação ao vivo](compatibility.md) ·
[Proveniência](provenance.md) ·
[Contribuir](../CONTRIBUTING.md) ·
[Segurança](../SECURITY.md) ·
[Licença MIT](../LICENSE)
