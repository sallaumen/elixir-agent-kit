# Security

Part of the [Elixir context](../ELIXIR.md). Applies when the project serves
HTTP, takes user input or reads secrets.

Inspect: the browser pipeline (`protect_from_forgery`,
`put_secure_browser_headers`), every place a token is verified, every call
that turns input into an atom, upload handling, how params reach `Ecto`, and
where secrets are read.

- CSRF: `protect_from_forgery` installs `Plug.CSRFProtection`; it raises on an
  invalid token by default (`with: :clear_session` only drops the session).
  LiveView checks the `_csrf_token` connect param once when the socket joins;
  a JSON API pipeline without cookies does not need it.
- `Phoenix.Token`: `verify/4` enforces the `max_age` (seconds) recorded by
  `sign/4`, 86400 by default; pass `max_age:` on verify for each purpose so a
  reset link or download token lives minutes, not a day.
- Atoms: use `String.to_existing_atom/1` for input that selects a known value,
  never `String.to_atom/1`; atoms are not garbage collected.
- Uploads: `Plug.Upload` writes to a temporary path that is removed when the
  owning process exits; `content_type` and `filename` are client-controlled
  and must be validated by inspecting the content before they are trusted. Move
  or copy the file within the request, or `give_away/3` it to another process.
- Database input: build changes through `Ecto.Changeset.cast/3` with an explicit
  field list, or an explicit allowlist of fields and operators for filters and
  sorts; never interpolate params into a query or map a param to a column name
  without a lookup. Scope every read by the current tenant or scope. A field the
  server sets (`user_id`, `org_id`, a role, a price) is never in the `cast/3`
  list; set it from the scope or with `put_change/3` after casting.
- LiveView: `handle_event/3` params are untrusted exactly like controller params,
  including ids of records the user may not own; load through the scoped context
  function, not `Repo.get/2`. Authorization belongs in `live_session`
  `on_mount` hooks and `handle_params/3`; a hidden control is not a check.
- Secrets: read them in `config/runtime.exs` with `System.fetch_env!/1` so a
  missing value fails boot; never in `config/config.exs`, which is evaluated at
  compile time and bakes the value into the release.
- Logs: Phoenix filters parameters whose key contains a term in
  `config :phoenix, :filter_parameters` (default `["password"]`); add tokens and
  secrets. Logger prints only the metadata keys configured for the formatter
  (`config :logger, :default_formatter, metadata: [...]` in Elixir 1.15+);
  never put a secret or a full request body in metadata.

Verify: a test that sends a request with a tampered or expired token, one with a
record id the user does not own, and `mix sobelow` when the project includes it.
