# Choose one workflow

Start with the project's instructions and actual task. The categories name the
**primary** kind of work, not ownership boundaries in an application's source tree.
A LiveView race may use `async-state` under cross-cutting engineering; a UI that
shows a cross-tenant record needs `security-boundaries` under backend and data.
Follow the trigger, not the directory name. A small, specified edit may need no
workflow beyond the shared contract and project gates.

| Start here when the problem is… | Area | Typical distinctions |
|---|---|---|
| A screen's meaning, interaction, layout, navigation, accessibility or assets | [Frontend and user experience](CATALOG.md#frontend-and-user-experience) | Identity versus density; responsive layout versus history/navigation; design system versus one screen |
| Domain rules, persisted state, integrations, jobs, authorization or operational accounting | [Backend and data](CATALOG.md#backend-and-data) | Data contracts versus migration compatibility; integration setup versus security boundaries; alerts versus notifications |
| A behavior or risk that crosses UI, backend, tests or architecture | [Cross-cutting engineering](CATALOG.md#cross-cutting-engineering) | Review versus debugging; test gaps versus duplicate tests; performance versus asynchronous correctness |
| Packaging, sequencing, CI or acceptance of combined work | [Delivery and build](CATALOG.md#delivery-and-build) | Build failure versus pipeline design; coordination versus independent delivery validation |

Read one workflow and its [shared contract](CONTRACT.md). Add a neighboring
workflow only when the task has a distinct risk that the first does not cover;
state that reason. Read [Elixir context](ELIXIR.md) only for technologies actually
used. The default mode in the catalog yields to the user's explicit scope.

## Game and canvas interfaces

The kit has no game workflow. When the project renders a game or canvas scene and
the task touches its HUD, menus or overlays, add the external
[`game-ui-ux`](https://github.com/gamedev-skills/awesome-gamedev-agent-skills/tree/19d93f97c9c1ea0f8b306e77aa81e0d3e352d3e9/skills/disciplines/game-ui-ux)
skill (Apache-2.0, pinned commit) beside the kit workflow the risk names, usually
`accessibility`, `navigation-ux` or `responsive-mobile`. It contributes a screen
stack, focus navigation, event-driven HUD updates, scaling and safe areas; map its
Godot and Unity examples onto the project's own rendering code. The evidence is a
canvas or engine scene in the source, not a playful visual theme. Install that one
skill per project, after reading and scanning it.

A workflow does not grant permission to send messages, spend money, publish,
merge, deploy or access production. A user's existing authorization still applies.
For frontend work, verify behavior in the running application when available;
for backend work, validate the actual read/write or job boundary. No structural
check proves that a model followed the guidance in a live session.
