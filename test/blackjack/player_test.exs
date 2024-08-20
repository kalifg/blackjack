defmodule Blackjack.PlayerTest do
  use ExUnit.Case
  doctest Blackjack.Player

  test "Dealer plays a hand" do
    {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    {:ok, pid} = Blackjack.Player.start_link(:player, deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
    [:"9", :"3", :A, :K] = Blackjack.Player.play_hand(pid)
  end

  test "Default plays a hand" do
    {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    {:ok, pid} = Blackjack.Player.start_link(:player, deck_pid, Blackjack.DefaultStrategy, [:"9", :"5"])
    [:"9", :"5", :A] = Blackjack.Player.play_hand(pid)
  end
end
