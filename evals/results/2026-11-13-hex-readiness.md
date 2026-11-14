# Hex packaging rehearsal: Git tag v1.2.0

**Verdict: installable via Hex; documentation is not ready for a first public
Hex release.** The public Git tag resolves to
`c2ff7e5be2a08fdfab757d101e95036069634396`. No package, documentation,
credential, or namespace reservation was sent to Hex. These are delivery
checks, not live agent evaluations.

## What was actually built

From a clean clone of the tag, with Elixir 1.19.5 / OTP 27 and Hex 2.7.0,
`mix hex.build` produced `elixir_agent_kit-1.2.0.tar`: 201,216 bytes,
SHA-256 `aae49769f6922ccd7deb1844c4cc6e63fd262f9d984881e0a12f9f8830acc487`.
Its inner checksum verified. The 94 regular files (586,662 bytes) matched the
tracked, declared package inputs byte for byte:

| Contents | Files |
|---|---:|
| Elixir source, including the Mix tasks | 10 |
| Library: 38 workflow bodies, companion material, references and templates | 68 |
| Documentation and its asset | 10 |
| Mix project, README, changelog, license, contribution and security policies | 6 |

The metadata specifies MIT, Mix, Elixir `~> 1.15`, a GitHub link and no package
requirements. No Git history, CI configuration, generated client pointers, tests,
evaluation packets, build artifacts or local config was included. The tagged
checkout also passed all 54 ExUnit tests and the 38-workflow structural check.

## How the installation was tested

1. Copied **that tarball** to the tarballs directory of a disposable signed Hex
   registry, built it with `mix hex.registry build`, and served only the registry
   over loopback. Used the generated public key and isolated Hex configuration
   and cache; the temporary signing key was discarded.
2. Created a fresh Mix project, configured all three adapters, and required
   `{:elixir_agent_kit, "== 1.2.0", repo: "kitlocal", only: [:dev, :test], runtime: false}`.
   Observed HTTP requests for the registry record and tarball; verified the
   lock recorded the Hex SCM, registry, version and archive checksum. Every
   installed package file matched the inspected archive.
3. Verified installer dry-run, install, list, check, a no-change second
   install, all 38 workflow references and consumer tests. Production compiled
   without the dependency. Uninstall preserved pre-existing project guidance.
4. Ran `mix hex.publish package --dry-run --yes` with an empty Hex home and a
   loopback-only API URL. It exited successfully without an upload. The
   interactive dry-run also attempts account selection; neither test verifies
   a real publisher's authentication or ownership.

## Before publication

- Align installation instructions (English, Portuguese and AI prompt) and the
  versioning policy: this tag explicitly says Git only. Keep Git instructions
  as an option; label the update check as comparing Git tags.
- Eight relative Markdown links point at evaluation material omitted from the
  archive: three in the changelog, one in the README and four in provenance.
  They resolve in a checkout. Use version-pinned source URLs in packaged
  documents; keep the evaluation material out of the package. No installed
  workflow reference failed.
- Keep the published Git tag immutable. If correcting shipped files, issue a
  new patch tag and repeat the archive and clean-consumer checks on it so the
  Git and Hex distributions of a given version agree.
- The public package API returned HTTP 404 during this rehearsal. This did
  not reserve the name. Recheck before first publication, confirm the intended
  owner and use their authenticated Hex account. The tag has no ExDoc
  dependency; package-only publication is supported and HexDocs is a separate
  decision. After publication, repeat the consumer test against public hexpm,
  without the local repo option, and verify the lock and tarball.

See the official [publishing guide](https://hex.pm/docs/publish),
[local registry task](https://hexdocs.pm/hex/Mix.Tasks.Hex.Registry.html) and
[package-only and dry-run options](https://hexdocs.pm/hex/Mix.Tasks.Hex.Publish.html).
