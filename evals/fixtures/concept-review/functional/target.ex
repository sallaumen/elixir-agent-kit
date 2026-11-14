defmodule PaperTray do
  def tickets(values), do: PrintDesk.slips(values, &ticket/1)

  defp ticket(value) do
    copies = DeskPreference.copies()
    {value, if(value < 0, do: 0, else: min(value, copies))}
  end
end
