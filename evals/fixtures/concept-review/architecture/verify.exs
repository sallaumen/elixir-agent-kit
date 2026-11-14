# Run from any directory: elixir path/to/verify.exs
cases = [
  {Studio.Legacy, "minutes", 89, :standard},
  {Studio.Legacy, "minutes", 90, :long},
  {Studio.Mixer, "time", 5399, :standard},
  {Studio.Mixer, "time", 5400, :long}
]

Code.compiler_options(ignore_module_conflict: true)

for {file, expected_misses} <- [{"positive.ex", [{Studio.Mixer, 5399, :long, :standard}]}, {"control.ex", []}] do
  Code.compile_file(Path.join(__DIR__, file))

  misses =
    for {mod, key, n, want} <- cases,
        actual = apply(mod, :preview, [%{key => n}]),
        actual != want,
        do: {mod, n, actual, want}

  IO.puts("#{file}: #{inspect(misses)}")
  if misses != expected_misses, do: raise("#{file}: expected #{inspect(expected_misses)}")
end
