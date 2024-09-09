defmodule Blackjack.DefaultStrategy do
  alias Blackjack.Player
  alias Blackjack.Hand
  
  @behaviour Blackjack.PlayerStrategy

  @impl true
  def action(player, dealer_card \\ nil)

  def action(%Player{current_hand: [_card]}, _dealer_card) do
    :hit
  end

  def action(%Player{current_hand: [:A, :A]}, _dealer_card) do
    :split
  end

  def action(%Player{current_hand: hand, funds: funds, wager: wager}, _dealer_card) do
    points = Hand.points(hand)

    cond do
      points == 11 and funds >= 2 * wager-> :double
      points < 17 -> :hit
      true -> :stand
    end
  end
end
