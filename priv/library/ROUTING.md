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

A workflow does not grant permission to send messages, spend money, publish,
merge, deploy or access production. A user's existing authorization still applies.
For frontend work, verify behavior in the running application when available;
for backend work, validate the actual read/write or job boundary. No structural
check proves that a model followed the guidance in a live session.
