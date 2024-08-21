defmodule Blackjack.DealerStrategy do
  @behaviour Blackjack.PlayerStrategy

  # The house hits on any hand less than or equal to this value
  @house_limit 16

  @doc """
  Determine if the house should hit

  ## Examples

    iex> Blackjack.DealerStrategy.action([:"3", :"9"])
    :hit
    iex> Blackjack.DealerStrategy.action([:A, :K])
    :stand
    iex> Blackjack.DealerStrategy.action([:"9", :K])
    :stand
    iex> Blackjack.DealerStrategy.action([:A, :"6"])
    :stand
    iex> Blackjack.DealerStrategy.action([:A, :"3"])
    :hit
  """
  def action(hand, _dealer_card \\ nil) do
    if Blackjack.hand_points(hand) <= @house_limit do
      :hit
    else
      :stand
    end
  end
end
