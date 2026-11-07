# Oban

Part of the [Elixir context](../ELIXIR.md). Applies when `mix.lock` lists `oban`.

Inspect: queue concurrency, `unique` options, `max_attempts`, which worker names
are persisted in `oban_jobs`, and whether a job calls a paid or rate-limited
provider.

- Queue concurrency limits workers, not the provider; account for provider
  capacity and budget inside the job, before the network call.
- `unique` prevents duplicate enqueueing, not duplicate effects of a retried job;
  make the external effect idempotent or record it before acting.
- Renaming a worker leaves persisted jobs pointing at the old module: keep the
  old module as an alias until the queue drains, or migrate the `worker` column.
- Use `snooze` for backoff that depends on external state and `{:cancel, reason}`
  for permanent failures; do not retry a paid call by default.
- A rate limit is not a broken job: rescue the client's rate-limit error in
  `perform/1` and return `{:snooze, seconds}` from the provider's `retry-after`,
  so attempts are not spent on requests that cannot succeed yet. `unique:
  [period: seconds]` folds repeated manual triggers into one job.
- Isolate a batch job per item: wrap each item, and each independent sub-fetch
  of an item, so its failure records an item-level error and the batch
  continues; only a failure of the source itself returns `{:error, reason}`, so
  Oban retries the whole job. Every branch returns a value or records an error,
  none swallows one, and the run's summary counts the item errors.

Verify: `Oban.Testing` (`assert_enqueued/2`, `perform_job/3`) with `testing:
:manual` in the test config; a retry scenario asserting the effect happened
once; a batch where one item fails and the rest are stored, and one where the
source fails and `perform_job/3` answers `{:error, _}` or `{:snooze, _}`.
