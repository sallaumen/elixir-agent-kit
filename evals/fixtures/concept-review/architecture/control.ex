defmodule Studio.Legacy do
  def preview(%{"minutes" => n}), do: Studio.Schedule.classify(n * 60)
end

defmodule Studio.Mixer do
  def preview(%{"time" => n}), do: Studio.Schedule.classify(n)
end

defmodule Studio.Schedule do
  def classify(seconds) when is_integer(seconds) and seconds >= 5400, do: :long
  def classify(seconds) when is_integer(seconds), do: :standard
end
