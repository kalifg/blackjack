defmodule Blackjack.DealerServerTest do
  use ExUnit.Case
  doctest Blackjack.DealerServer

  test "Initializes the dealer" do
    {:ok, deck_pid} = Blackjack.DeckServer.init([:A, :K, :Q, :K])
    {:ok, _pid} = Blackjack.DealerServer.start_link(deck_pid)
  end
end
