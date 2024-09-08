defmodule Blackjack.TableStrategy do
  alias Blackjack.Player
  @behaviour Blackjack.PlayerStrategy

  @impl true

  def action(player, dealer_card \\ nil)

  def action(%Player{current_hand: [_card]}, _dealer_card) do
    :hit
  end

  def action(%Player{current_hand: [c1, c2]}, dealer_card) when (c1 == :A and c2 in [:"2", :"3", :"4", :"5", :"6"]) or (c1 in [:"2", :"3", :"4", :"5", :"6"] and c2 == :"A") do
    cond do
      dealer_card in [:"4", :"5", :"6"] -> :double
      true -> :hit
    end
  end

  def action(%Player{current_hand: [c1, c2]}, dealer_card) when (c1 == :A and c2 == :"7") or (c1 == :"7" and c2 == :"A") do
    cond do
      dealer_card in [:"2", :"7", :"8"] -> :stand
      dealer_card in [:"3", :"4", :"5", :"6"] -> :double
      true -> :hit
    end
  end

  def action(%Player{current_hand: [c1, c2]}, _dealer_card) when (c1 == :A and c2 in [:"8", :"9"]) or (c1 in [:"8", :"9"] and c2 == :"A") do
    :stand
  end


  def action(%Player{current_hand: [:"2", :"2"]}, dealer_card) do
    cond do
      dealer_card in [:"4", :"5", :"6", :"7"] -> :split
      true -> :hit
    end
  end

  def action(%Player{current_hand: [:"3", :"3"]}, dealer_card) do
    cond do
      dealer_card in [:"4", :"5", :"6", :"7"] -> :split
      true -> :hit
    end
  end

  def action(%Player{current_hand: [:"5", :"5"]}, dealer_card) do
    cond do
      dealer_card < 10 -> :double
      true -> :hit
    end
  end

  def action(%Player{current_hand: [:"6", :"6"]}, dealer_card) do
    cond do
      dealer_card < 7 -> :split
      true -> :hit
    end
  end

  def action(%Player{current_hand: [:"7", :"7"]}, dealer_card) do
    cond do
      dealer_card < 8 -> :split
      true -> :hit
    end
  end

  def action(%Player{current_hand: [:"8", :"8"]}, _dealer_card) do
    :split
  end

  def action(%Player{current_hand: [:"9", :"9"]}, dealer_card) do
    cond do
      dealer_card in [:"7", :T, :J, :Q, :K, :A] -> :stand
      true -> :split
    end
  end

  def action(%Player{current_hand: [card, card]}, _dealer_card) when card in [:T, :J, :Q, :K] do
    :stand
  end

  def action(%Player{current_hand: [:A, :A]}, _dealer_card) do
    :split
  end

  def action(%Player{current_hand: hand, wager: wager, funds: funds}, dealer_card) do
    points = Blackjack.hand_points(hand)

    cond do
      points == 9 and dealer_card in [:"3", :"4", :"5", :"6"] and funds >= 2 * wager -> :double
      points == 10 and dealer_card in [:"2", :"3", :"4", :"5", :"6", :"7", :"8", :"9"] and funds >= 2 * wager -> :double
      points == 11 and funds >= 2 * wager -> :double
      points == 12 and dealer_card in [:"4", :"5", :"6"] -> :stand
      points > 12 and points < 17 and dealer_card in [:"2", :"3", :"4", :"5", :"6"] -> :stand
      points > 16 -> :stand
      true -> :hit
    end
  end
end
