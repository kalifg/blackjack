defmodule Blackjack.DefaultStrategy do
  @behaviour Blackjack.PlayerStrategy

  @impl true
  def should_hit?(hand, _dealer_card \\ nil) do
    Blackjack.hand_points(hand) < 15
  end
end
