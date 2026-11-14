defmodule PaperTray do
  def tickets(values) do
    copies = DeskPreference.copies()
    PrintDesk.slips(values, &ticket(&1, copies))
  end

  def ticket(value, copies),
    do: {value, if(value < 0, do: 0, else: min(value, copies))}
end
