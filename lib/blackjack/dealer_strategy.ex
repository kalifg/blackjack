defmodule Blackjack.DealerStrategy do
  @behaviour Blackjack.PlayerStrategy

  # The house hits on any hand less than or equal to this value
  @house_limit 16

  @doc """
  Determine if the house should hit

  ## Examples

    iex> Blackjack.DealerStrategy.should_hit?([:"3", :"9"])
    true
    iex> Blackjack.DealerStrategy.should_hit?([:A, :K])
    false
    iex> Blackjack.DealerStrategy.should_hit?([:"9", :K])
    false
    iex> Blackjack.DealerStrategy.should_hit?([:A, :"6"])
    false
    iex> Blackjack.DealerStrategy.should_hit?([:A, :"3"])
    true
  """
  def should_hit?(hand, _dealer_card \\ nil) do
    Blackjack.hand_points(hand) <= @house_limit
  end
end
