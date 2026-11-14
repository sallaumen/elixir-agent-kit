defmodule Studio.Legacy do
  def preview(row), do: Studio.Schedule.classify(row)
end

defmodule Studio.Mixer do
  def preview(row), do: Studio.Schedule.classify(row)
end

defmodule Studio.Schedule do
  def classify(%{"minutes" => n}), do: classify_length(n * 60)
  def classify(%{"time" => n}), do: classify_length(round(n / 60) * 60)
  defp classify_length(seconds) when seconds >= 5400, do: :long
  defp classify_length(_seconds), do: :standard
end
