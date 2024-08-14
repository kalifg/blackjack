defmodule Blackjack.PlayerServerTest do
  use ExUnit.Case
  doctest Blackjack.PlayerServer

  test "Initializes the dealer" do
    {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    {:ok, pid} = Blackjack.PlayerServer.start_link(deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
    [:"9", :"3", :A, :K] = Blackjack.PlayerServer.play_house(pid)
  end
end
