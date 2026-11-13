defmodule Store do
  # Row format: {id, state, manual_marker?, ledger_evidence}.
  # Available ledger evidence: :none, :recorded, :reversed, :imported.
  def candidates(rows, limit) do
    rows
    |> Enum.filter(fn {_, state, marker, _} -> state == :posted and marker end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.take(limit)
  end

  def change(rows, ids) do
    Enum.map(rows, fn {id,state,marker,evidence}=row ->
      if id in ids, do: {id,:waived,marker,evidence}, else: row
    end)
  end
end

defmodule Runner do
  def run(rows, limit), do: walk(rows,limit,0)
  defp walk(rows,limit,n) do
    case Store.candidates(rows,limit) do
      [] -> {rows,n}
      page ->
        ids=for {id,_,_,evidence} <- page, evidence != :recorded, do: id
        walk(Store.change(rows,ids),limit,n+1)
    end
  end
end
