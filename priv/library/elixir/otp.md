# OTP processes and supervision

Part of the [Elixir context](../ELIXIR.md). Applies when the project starts its own processes (`GenServer`, `Task`, `Agent`, a supervision tree).

Inspect: the supervision tree (`Application.start/2`, child specs), which process
owns each piece of state, every `GenServer.call/3` timeout, and what happens on
restart.

- Use a process for state ownership, lifecycle or concurrency control, not to
  organize functions. Keep pure calculations as functions.
- Pick the restart strategy for the failure you expect; a crash that loses state
  the user depends on needs persistence or a recovery read, not a tighter restart.
- Give long `call`s an explicit timeout and a caller that survives `:timeout`.
  Move blocking work out of callbacks with `Task.Supervisor` or `handle_continue/2`.
- Watch mailbox growth on pollers and broadcasters: dedupe by content hash or
  sequence before broadcasting; `Process.info(pid, :message_queue_len)` measures it.
- A periodic process schedules its next tick inside `handle_info/2` (scheduling
  only in `init/1` runs once), reads the interval from application config so the
  test environment can stretch it, and rescues a known flaky source inside the
  tick, so one bad read keeps the schedule instead of spending the supervisor's
  restart budget. Work that must survive a restart or retry with backoff is an
  Oban job, not a timer.
- A short-lived cache of an expensive read shared by every render (a shell
  command, a file scan, a local status) is an ETS table owned by a supervised
  process with `read_concurrency: true`; entries carry
  `System.monotonic_time/1`, expired ones are dropped on write, and the TTL is a
  config value where 0 turns the cache off (the test value). A restart empties
  it, so nothing durable may depend on it.
- Before renaming a module, search behaviours, callbacks, configuration, child
  specs, dynamic dispatch (`apply/3`, `String.to_existing_atom/1`), serialized
  references and persisted jobs. A direct-call search proves nothing.
- Never expose a private function only for tests.

Verify: `start_supervised!/1` in tests, a restart scenario, `:sys.get_state/1` for
inspection, `assert_receive` with a bounded timeout instead of `Process.sleep`.
