# Choose one workflow

Start with the project's instructions and actual task. The categories name the
**primary** kind of work, not ownership boundaries in an application's source tree.
A LiveView race may use `async-state` under cross-cutting engineering; a UI that
shows a cross-tenant record needs `security-boundaries` under backend and data.
Follow the trigger, not the directory name. A small, specified edit may need no
workflow beyond the shared contract and project gates.

| Start here when the problem is… | Area | Typical distinctions |
|---|---|---|
| A screen's meaning, interaction, layout, navigation, accessibility, motion or assets | [Frontend and user experience](CATALOG.md#frontend-and-user-experience) | Identity versus density; layout at a width versus history and overlays (navigation-ux, on every device); design system versus one screen; motion versus state feedback |
| Domain rules, persisted state, integrations, jobs, authorization or operational accounting | [Backend and data](CATALOG.md#backend-and-data) | Data contracts versus migration compatibility; integration setup versus security boundaries; alerts versus notifications; one provider call versus capacity across workers |
| A behavior or risk that crosses UI, backend, tests or architecture | [Cross-cutting engineering](CATALOG.md#cross-cutting-engineering) | Review versus debugging; test gaps and duplicates (one workflow); performance versus asynchronous correctness; product revisions versus the running build |
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
`accessibility`, `navigation-ux` or `responsive-layout`. It contributes a screen
stack, focus navigation, event-driven HUD updates, scaling and safe areas; map its
Godot and Unity examples onto the project's own rendering code. The evidence is a
canvas or engine scene in the source, not a playful visual theme. Install that one
skill per project, after reading and scanning it.

## Motion and rendered video

Interface motion is `motion-design`: choosing curves, durations and reactions for
state changes in the running product, with a reduced-motion alternative. It governs
the interface, not film.

For rendered video, motion graphics or an animated deck, apply the external
[motion-designer](https://github.com/hughminhphan/motion-kit/tree/6173e5c408f81f1989435843af3f0788b74bda96/skills/motion-designer)
skill (MIT, pinned revision). It supplies a GSAP helper (`motion-kit.js`), a motion
library and the same principles for frame-accurate work. Read `SKILL.md` and
`LIBRARY.md`, add the skill per project rather than the whole repository, vendor the
helper into the composition, and record the revision. Its text is not bundled here;
`motion-design` is the interface adaptation, and the repository's `docs/provenance.md`
records the source revision. A page whose motion is plain CSS does not need
the external skill.

A workflow does not grant permission to send messages, spend money, publish,
merge, deploy or access production. A user's existing authorization still applies.
For frontend work, verify behavior in the running application when available;
for backend work, validate the actual read/write or job boundary. No structural
check proves that a model followed the guidance in a live session.
