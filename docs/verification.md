> Historical record for the initial 0.1 release. The 0.2 reference layout replaces
> snapshots and native wrappers; see [compatibility](compatibility.md) for current behavior.

# Initial release verification

Verified locally on 2026-11-05:

| Check | Environment | Result |
|---|---|---|
| Formatting, warnings-as-errors compilation and 21 ExUnit tests | Elixir 1.19.5 / OTP 27, macOS | Passed |
| Formatting, warnings-as-errors compilation and 21 ExUnit tests | Elixir 1.15.8 / OTP 26, official Linux container | Passed |
| Metadata, provenance and local Markdown reference validation | Python 3, local checkout | Passed |
| Real Mix consumer installation, repeatability, drift exit and uninstall | Temporary consumer, local path dependency | Passed |
| Development/test availability and production exclusion | Temporary Mix consumer | Passed |
| Hex-compatible archive build | `mix hex.build`, no publication | Passed |

The consumer smoke test uses the real CLI with all three adapters. It does not
invoke any AI model. ExUnit covers local-edit preservation, stale entry removal,
unmanaged collisions, malformed state/markers, symlinks, path traversal, empty
instruction files, selective discovery and installed relative links.

A GitHub release's notes record the subsequent public Git-fetch smoke result.
CI status is separate from these local checks. Live Codex, Claude Code and
DeepSeek-harness discovery/behavior evaluations remain unverified; follow the
procedure in [compatibility.md](compatibility.md) to produce that evidence.
