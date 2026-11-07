# HTTP clients and provider APIs

Part of the [Elixir context](../ELIXIR.md). Applies when `mix.lock` lists `req`,
`finch` or another HTTP client.

Inspect: which client the project uses (`Req` over `Finch` and `Mint`, or `Finch`
directly), the retry and timeout options on each paid or non-idempotent call,
how pools are sized per provider host, and how tests replace the transport.

- Build each client once as a value: `Req.new/1` with `base_url`, headers, an
  explicit `retry:` and timeouts, in a `build/0`. Call sites take the client as an
  argument with a default (`def load(client \\ build())`), so a test passes a
  stubbed one and production code needs no mock.
- `Req.get!/2` and the other bang functions raise only on transport errors; a
  4xx or 5xx is a response. Check `status` before using `body`, and give a rate
  limit (403 or 429 with `retry-after`) its own error so the caller can wait
  instead of failing.
- Choose the failure style by the caller. A client called from a render or a
  LiveView event returns `{:ok, value} | {:error, reason}` and rescues at its own
  boundary, so a dead service costs a reason, not a crashed view. A client used
  only inside a durable job may raise with the real status, and the job rescues
  per item (see [Oban](oban.md)). A raise that reaches a user-facing caller is a
  bug with a test.
- Keep "never connected" (`:unreachable`), "sent, outcome unknown" (`:timeout`)
  and "answered with a status" (`{:http, status}`) as distinct reasons; only the
  first proves the request had no effect.
- Req retries by default: `retry: :safe_transient` (the default since Req 0.4)
  retries GET and HEAD on HTTP 408, 429, 500, 502, 503 and 504 and on transport
  errors (`:timeout`, `:econnrefused`, `:closed`), up to `max_retries: 3` with
  exponential backoff or the `Retry-After` header. POST is not retried under the
  default, but `retry: :transient` or a custom retry function retries every
  method, so a paid POST sent that way can run several times. Set `retry: false`
  on a call with a cost or an effect unless the provider honors an idempotency
  key that the retry resends.
- A retry policy other than the default is a named two-argument function,
  `retry: &MyApp.Provider.Retry.decide/2`, that receives the request and the
  response or exception and returns `{:delay, ms}` or `false`, with
  `max_retries:` as the bound and no `retry_delay:` (Req rejects that option
  when the function returns `{:delay, ms}`). Retry only failures with nothing to
  pay for (a transport error before a response, a 429 honoring a capped
  `retry-after`, a 500, 502, 503 or 504), never a 4xx about the input or the
  key, never a stream after its first chunk reached the caller, and record each
  retry where operators see it.
- Timeouts: `receive_timeout` (default 15 s) bounds the wait for a response;
  `connect_options: [timeout: ...]` (default 30 s) bounds the connection. In Req
  0.7+ pool options move under `finch: [name: ..., pool_timeout: ...]`; earlier
  versions take `finch: Name` and `pool_timeout:` at the top level. A local
  service read on a render path gets timeouts in the hundreds of milliseconds,
  so a dead dependency bounds the render instead of holding it for the defaults.
- A read-modify-write against a remote resource sends the revision it read; a
  409 is `{:error, :conflict}` for the caller to resolve, never a retried
  overwrite.
- A timeout is not evidence that the provider did not do the work: the charge,
  message or job may have completed after the socket closed. Record the attempt
  with an id before the call, reconcile by that id before retrying, and treat
  the retry decision as a product rule, not a client default.
- Pools: `Finch` sizes pools per origin (`pools: %{"https://api.example.com" =>
  [size: 10, count: 2]}`; the default pool is `size: 50, count: 1`). `size` is
  the HTTP/1 connections per pool, `count` the number of pools for the same
  origin. A slow paid provider sharing the default pool starves other calls;
  give it its own pool and read `[:finch, :queue, :stop]` for wait time.
- Tests: `Req.Test.stub(name, plug)` and `Req.Test.expect(name, count, plug)`
  with `plug: {Req.Test, name}` on the request answer from a `Plug` function or
  module, so the response body, status and headers are explicit;
  `Req.Test.json/2` builds a JSON response and `Req.Test.transport_error/2`
  simulates `:timeout` or `:econnrefused`. Stubs are owned per test process and
  work with `async: true`. Test the real client with only the transport replaced,
  `Req.merge(MyApp.Client.build(), plug: {Req.Test, MyApp.Client})`, so its
  headers, timeouts and retry policy are under test too. Keep one real contract
  check where authorized.

Verify: a test for the timeout path and for the retried path asserting the
effect count; for a client on a render path, one stub per reason
(`Req.Test.transport_error/2`, a 500, a malformed body) asserting the reason
returned and no raise; the pool configuration named in the handoff when a
provider was added.
