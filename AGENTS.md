# Elixir Agent Kit contributor instructions

Read README.md, CONTRIBUTING.md and docs/architecture.md before changing behavior.
Canonical public workflows live in priv/library; generated consumer files are not
sources. Preserve project-local instructions and refuse destructive conflicts.
Do not add model calls, telemetry, services or global client configuration.

Run the checks documented in CONTRIBUTING.md. Use isolated temporary projects for
installer tests. Never test uninstall against unrelated user content. Stage files
by name, preserve other work and use a pull request after initial bootstrap.
Report structural tests separately from live client/model evaluations.
