# Phoenix and LiveView

Part of the [Elixir context](../ELIXIR.md). Applies when `mix.lock` lists `phoenix` or `phoenix_live_view`.

Inspect: `mount/3` versus `handle_params/3`, whether a subscription runs only when
`connected?(socket)`, how navigation is done (`push_patch` keeps the process,
`push_navigate` remounts, `redirect` leaves LiveView), `live_session` and
`on_mount` hooks, and where asynchronous work starts.

- Authorize and scope by tenant in `on_mount` and `handle_params`, not only in
  templates. Hiding a control is not authorization.
- Phoenix 1.8 scopes: `phx.gen.auth` assigns `current_scope` (configurable with
  `--assign-key`) in the browser pipeline and in `on_mount`; generated context
  functions take the scope struct as first argument and filter their queries by
  it (a `where` on the scope's key, or `Repo.all_by/3` in Ecto 3.13+). Read the
  scope struct and the context functions to learn the tenant and ownership
  rules; a context function that ignores its scope argument is a finding, not a
  style choice.
- Run asynchronous work with `assign_async/3`, `start_async/3` and
  `handle_async/3`, keyed by the entity and revision that requested it; drop a
  late result whose key no longer matches the current selection.
- One job of a kind at a time: keep `%{ref: ref}` in an assign, call
  `start_async(socket, {:job, ref}, fun)`, and in `handle_async({:job, ref}, ...)`
  act only while the assign still holds that ref. A timeout is
  `Process.send_after(self(), {:job_timeout, ref}, ms)`, whose handler calls
  `cancel_async/3` and names the failure. A second submit while the job runs is
  refused in `handle_event/3`; `phx-disable-with` is feedback, not a guard.
- Push state from the server (PubSub subscribe in connected mount, `handle_info`),
  never poll the database from the browser. When the shown resource changes,
  unsubscribe from the old topic before subscribing to the new one; subscribing
  again on every reload delivers each broadcast twice.
- Read the page's data in `handle_params/3`, not in both `mount/3` and
  `handle_params/3`: both run on the dead render and again on the connected one,
  so a read in each doubles the work. Skip the read for a `push_patch` that keeps
  the same resource (opening a panel or a tab) and let PubSub messages drive the
  refresh. Wrap the read in a `:telemetry.span/3` so its cost per render is on the
  dashboard.
- End `handle_event/3` with a clause that records an unexpected event (its name
  and param keys, never the values) and returns `{:noreply, socket}`; an old tab
  after a deploy or a recovered form otherwise crashes the view and drops its
  state. An event the view expects validates its own params in its own clause.
- Use streams (`stream/4`, `stream_insert/4`) for large or growing collections;
  assigns re-render whole lists.
- Forms: `to_form/2`, `phx-change` for validation, `phx-submit` for the write,
  `phx-disable-with` on the submit control; optimistic UI is the exception, not
  the default round-trip. A form that mirrors saved settings sets
  `phx-auto-recover="ignore"`: after a reconnect LiveView re-sends each form's
  values through its `phx-change` event, which replays a confirmation or saves a
  half-filled picker.
- Focus and announcements after a patch: `phx-mounted` with `JS.focus/1` or
  `JS.focus_first/1`, `aria-live` regions outside `phx-update="ignore"`, flash
  rendered where a screen reader reaches it. Keyboard access survives
  `JS` commands only when the control is a real button or link.
- CSRF protection and `put_secure_browser_headers` are on by default; do not
  weaken the CSP to make a hook work.
- Interface motion belongs to the `motion-design` workflow; reduced motion is a
  state to design, not an afterthought.

Verify: `Phoenix.LiveViewTest` (`live/2`, `render_click/2`, `render_submit/2`,
`assert_patch/2`, `assert_redirect/2`, `assert_push_event/3`), `render_async/2`
to await every pending `assign_async` and `start_async` task (and `stream_async`
in LiveView 1.1) and render the result, with an explicit timeout when the work
exceeds ExUnit's `assert_receive_timeout` (100 ms); assert on the rendered HTML
or the assigns the task set, since there is no dedicated async assertion. Also a
reconnect (stop the view process and mount it again), `render_hook/3` with an
event name the view does not handle (the page renders instead of crashing), a
telemetry handler counting the page's data reads per render, and a real browser
pass at the project's viewports for anything the test cannot observe.
