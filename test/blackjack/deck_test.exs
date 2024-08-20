defmodule Blackjack.DeckTest do
  use ExUnit.Case
  doctest Blackjack.Deck

  test "Initializes the deck" do
    {:ok, _pid} = Blackjack.Deck.init([:A, :K, :Q, :K])
  end

  test "Draws a card from the deck" do
    {:ok, pid} = Blackjack.Deck.start_link([:A, :K, :Q, :K])
    :A = Blackjack.Deck.draw_card(pid)
  end

  test "Shuffles the deck" do
    {:noreply, shuffled_deck} = Blackjack.Deck.handle_cast(:shuffle_deck, [:A, :K, :Q, :K])
    assert shuffled_deck != [:A, :K, :Q, :K]
  end
end
