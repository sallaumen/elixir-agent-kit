# Telemetry and observability

Part of the [Elixir context](../ELIXIR.md). Applies when `mix.lock` lists `telemetry`, as every Phoenix, Ecto and Oban project does.

Inspect: the project's `Telemetry` module (the `metrics/0` list), which events
are attached, and whether a paid call or a job emits anything at all.

- Phoenix emits `[:phoenix, :endpoint, :start | :stop]` (duration of the whole
  request), `[:phoenix, :router_dispatch, :start | :stop | :exception]`,
  `[:phoenix, :error_rendered]`, `[:phoenix, :socket_connected]`,
  `[:phoenix, :channel_joined]` and `[:phoenix, :channel_handled_in]`.
- LiveView emits spans under `[:phoenix, :live_view, :mount | :handle_params |
  :handle_event | :render]` and `[:phoenix, :live_component, :update |
  :handle_event]`, each with `:start`, `:stop` and `:exception` and a
  `duration` measurement.
- Ecto emits `[:my_app, :repo, :query]` (the repo's `telemetry_prefix`) with
  `total_time`, `query_time`, `queue_time`, `decode_time` and `idle_time`; a
  high `queue_time` means the pool is exhausted, a high `query_time` means the
  query or index.
- Oban emits `[:oban, :job, :start | :stop | :exception]` with `duration`,
  `queue_time`, `memory` and `reductions`; `queue_time` is the wait between
  scheduling and execution.
- Req emits no events of its own; its default adapter does:
  `[:finch, :request, :start | :stop | :exception]` for the whole call and
  `[:finch, :queue, :stop]` for the pool checkout wait (`duration`,
  `idle_time`).
- `Telemetry.Metrics` (`summary/2`, `counter/2`, `distribution/2`,
  `last_value/2`) describes what to aggregate; `Phoenix.LiveDashboard` renders
  those metrics in dev through `metrics: {MyAppWeb.Telemetry, :metrics}` in
  the router. Measurements are in native time units; convert with `unit:` or
  `System.convert_time_unit/3`.
- Custom spans: `:telemetry.span([:my_app, :provider, :call], meta, fn -> {result,
  meta} end)` emits `:start`, `:stop` and `:exception` with `duration`; use it
  around every paid call, job step and LiveView data load so a cost has a trace,
  and list each span in `metrics/0` (`summary("my_app.page.load.stop.duration",
  unit: {:native, :millisecond})`) so the dashboard shows it.

Verify: in a test, `:telemetry.attach/4` a handler that sends the event to
`self()` (or `:telemetry_test.attach_event_handlers/2`) and `assert_receive`
it with the expected measurements; a span around new provider code before a
performance claim.
