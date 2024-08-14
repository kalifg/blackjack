defmodule Blackjack.DeckServerTest do
  use ExUnit.Case
  doctest Blackjack.DeckServer

  test "Initializes the deck" do
    {:ok, _pid} = Blackjack.DeckServer.init([:A, :K, :Q, :K])
  end

  test "Draws a card from the deck" do
    {:ok, pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    :A = Blackjack.DeckServer.draw_card(pid)
  end

  test "Shuffles the deck" do
    {:noreply, shuffled_deck} = Blackjack.DeckServer.handle_cast(:shuffle_deck, [:A, :K, :Q, :K])
    assert shuffled_deck != [:A, :K, :Q, :K]
  end
end
