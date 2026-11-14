defmodule PrintDesk do
  def slips(values, render), do: Stream.map(values, render)
end

defmodule DeskPreference do
  def copies do
    Process.put(:observations, [Process.get(:copies, 1) | Process.get(:observations, [])])
    Process.get(:copies, 1)
  end
end
