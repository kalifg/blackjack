defmodule Blackjack.PlayerTest do
  alias Blackjack.Player
  use ExUnit.Case
  doctest Blackjack.Player

  test "Dealer plays a hand" do
    {:ok, deck} = Blackjack.Deck.start_link([:A, :K, :Q, :K])
    {:ok, pid} = Blackjack.Player.start_link(:player, %Player{deck: deck, strategy: Blackjack.DealerStrategy, hand: [:"9", :"3"]})
    [:"9", :"3", :A, :K] = Blackjack.Player.play_hand(pid)
  end

  test "Default plays a hand" do
    {:ok, deck} = Blackjack.Deck.start_link([:A, :K, :Q, :K])
    {:ok, pid} = Blackjack.Player.start_link(:player, %Player{deck: deck, strategy: Blackjack.DefaultStrategy, hand: [:"9", :"5"]})
    [:"9", :"5", :A] = Blackjack.Player.play_hand(pid, :A)
  end
end
