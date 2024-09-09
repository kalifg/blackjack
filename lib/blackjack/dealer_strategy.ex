defmodule Blackjack.DealerStrategy do
  alias Blackjack.Hand
  alias Blackjack.Player

  @behaviour Blackjack.PlayerStrategy

  # The house hits on any hand less than or equal to this value
  @house_limit 16

  @doc """
  Determine if the house should hit

  ## Examples

    iex> Blackjack.DealerStrategy.action(%Player{current_hand: ~H"93"})
    :hit

    iex> Blackjack.DealerStrategy.action(%Player{current_hand: ~H"AK"})
    :stand

    iex> Blackjack.DealerStrategy.action(%Player{current_hand: ~H"9K"})
    :stand

    iex> Blackjack.DealerStrategy.action(%Player{current_hand: ~H"A6"})
    :stand

    iex> Blackjack.DealerStrategy.action(%Player{current_hand: ~H"A3"})
    :hit
  """
  def action(%Player{current_hand: hand}, _dealer_card \\ nil) do
    if Hand.points(hand) <= @house_limit do
      :hit
    else
      :stand
    end
  end
end
