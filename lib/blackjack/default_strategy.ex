defmodule Blackjack.DefaultStrategy do
  @behaviour Blackjack.PlayerStrategy

  @impl true
  def action(hand, dealer_card \\ nil)
  def action([:A, :A], _dealer_card) do
    :split
  end

  def action(hand, _dealer_card) do
    points = Blackjack.hand_points(hand)

    cond do
      points == 11 -> :double_down
      points < 15 -> :hit
      true -> :stand
    end
  end
end
