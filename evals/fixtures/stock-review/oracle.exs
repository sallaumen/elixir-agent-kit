# Evaluator only. Both assertions pass at base and fail independently at head.
ExUnit.start()

defmodule StockContractTest do
  use ExUnit.Case

  test "depots may reuse the same receipt number" do
    east = %{depot: :east, receipt: 7, units: 3}
    west = %{depot: :west, receipt: 7, units: 5}
    assert Stock.totals([east, west]) == %{east: 3, west: 5}
  end

  test "the final date belongs to the reporting period" do
    last = %{date: ~D[2026-02-28]}
    assert Stock.period([last], ~D[2026-02-01], last.date) == [last]
  end
end
