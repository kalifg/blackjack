defmodule BlackjackTest do
  use ExUnit.Case
  doctest Blackjack

  test "Knows that an ace can be have two values" do
    assert Blackjack.points(:A) == [1, 11]
  end
end
