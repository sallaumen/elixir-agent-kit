# Run with: elixir check.exs
ExUnit.start()

defmodule PrintSlot.Strict do
  def select(%{mark: :fixed, slot: slot}), do: {:fixed, slot}

  def select(%{markers: markers}) do
    case elem(markers, 0) do
      :proof -> :proof
      _ -> :normal
    end
  end

  def select(_record), do: :normal
end

defmodule PrintSlot.Lenient do
  def select(%{mark: :fixed, slot: slot}), do: {:fixed, slot}
  def select(%{markers: markers}) when elem(markers, 0) == :proof, do: :proof
  def select(_record), do: :normal
end

defmodule PrintSlotTest do
  use ExUnit.Case, async: true

  test "ordinary public results agree" do
    for module <- [PrintSlot.Strict, PrintSlot.Lenient],
        {row, expected} <- [
          {%{markers: {:proof, 5}}, :proof}, {%{markers: {:draft}}, :normal},
          {%{}, :normal}, {:draft, :normal}
        ] do
      assert module.select(row) == expected
    end
  end

  test "a fixed slot wins even over malformed markers; absence of a slot does not win" do
    for module <- [PrintSlot.Strict, PrintSlot.Lenient] do
      assert module.select(%{mark: :fixed, slot: nil, markers: {:proof}}) == {:fixed, nil}
      assert module.select(%{mark: :fixed, slot: 92, markers: nil}) == {:fixed, 92}
      assert module.select(%{mark: :fixed, markers: {:proof}}) == :proof
    end
  end

  test "malformed markers raise in a body but fall through in a guard" do
    for malformed <- [nil, {}, [:proof], %{}] do
      assert_raise ArgumentError, fn -> PrintSlot.Strict.select(%{markers: malformed}) end
      assert PrintSlot.Lenient.select(%{markers: malformed}) == :normal
    end
  end
end
