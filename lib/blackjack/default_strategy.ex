defmodule Blackjack.DefaultStrategy do
  @behaviour Blackjack.PlayerStrategy

  @impl true
  def action(hand, _dealer_card \\ nil) do
    if Blackjack.hand_points(hand) < 15 do
      :hit
    else
      :stand
    end
  end
end
