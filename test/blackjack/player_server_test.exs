defmodule Blackjack.PlayerServerTest do
  use ExUnit.Case
  doctest Blackjack.PlayerServer

  test "Dealer plays a hand" do
    {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    {:ok, pid} = Blackjack.PlayerServer.start_link(:player, deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
    [:"9", :"3", :A, :K] = Blackjack.PlayerServer.play_house(pid)
  end

  test "Default plays a hand" do
    {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    {:ok, pid} = Blackjack.PlayerServer.start_link(:player, deck_pid, Blackjack.DefaultStrategy, [:"9", :"5"])
    [:"9", :"5", :A] = Blackjack.PlayerServer.play_house(pid)
  end
end
