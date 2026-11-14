ExUnit.start(seed: 0)
defmodule PaperTrayHoldout do
  use ExUnit.Case
  @snap System.fetch_env!("SCENARIO") == "inverse"
  defp trace, do: Enum.reverse(Process.get(:observations, []))
  test "construction and empty use" do
    Process.put(:copies, 2)
    _never = PaperTray.tickets([30])
    assert trace() == if(@snap, do: [2], else: [])
    assert Enum.to_list(PaperTray.tickets([])) == []
    assert trace() == if(@snap, do: [2,2], else: [])
  end
  test "demand and repeated use" do
    Process.put(:copies, 2)
    stream = PaperTray.tickets([9,10,-1])
    Process.put(:copies, 3)
    assert Enum.take(stream, 1) == [{9, if(@snap, do: 2, else: 3)}]
    assert trace() == if(@snap, do: [2], else: [3])
    Process.put(:copies, 4)
    assert Enum.to_list(stream) == [{9,if(@snap, do: 2, else: 4)}, {10,if(@snap, do: 2, else: 4)}, {-1,0}]
    assert trace() == if(@snap, do: [2], else: [3,4,4,4])
  end
  test "consumer changes preference between elements" do
    Process.put(:copies, 2)
    stream = PaperTray.tickets([9,10])
    assert Enum.map(stream, fn row -> Process.put(:copies, 5); row end) ==
      [{9,2}, {10, if(@snap, do: 2, else: 5)}]
    assert trace() == if(@snap, do: [2], else: [2,5])
  end
  test "consumer in another process" do
    Process.put(:copies, 2)
    stream = PaperTray.tickets([5])
    answer = Task.async(fn -> Process.put(:copies, 4); {Enum.to_list(stream), trace()} end) |> Task.await()
    assert answer == if(@snap, do: {[{5,2}], []}, else: {[{5,4}], [4]})
    assert trace() == if(@snap, do: [2], else: [])
  end
end
