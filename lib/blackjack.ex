defmodule Blackjack do
  @moduledoc """
  Documentation for `Blackjack`.
  """

  # Any hand greater than this value is a bust
  @bust_limit 21

  def main(args) do
    IO.inspect(args)
  end

  @doc """
  Get the point values for a card

  ## Examples

    iex> Blackjack.points(:"1")
    [1]
    iex> Blackjack.points(:"2")
    [2]
    iex> Blackjack.points(:K)
    [10]
    iex> Blackjack.points(:A)
    [1, 11]

  """
  def points(card) when is_atom(card) do
    case card do
      :A -> [1, 11]
      :K -> [10]
      :Q -> [10]
      :J -> [10]
      _ -> [card |> Atom.to_string |> String.to_integer]
    end
  end

  @doc """
  Get the point values for a hand.  If the hand contains an ace, the ace will be
  counted as 11 if the total is less than or equal to 11, otherwise it will be
  counted as 1.

  ## Examples

    iex> Blackjack.hand_points([:A, :K])
    21
    iex> Blackjack.hand_points([:A, :A, :K])
    12
    iex> Blackjack.hand_points([:A, :A, :K, :K])
    22
    iex> Blackjack.hand_points([:A, :A, :K, :K, :K])
    32
    iex> Blackjack.hand_points([:"6", :"7", :"8"])
    21
    iex> Blackjack.hand_points([:"6", :A, :"8"])
    15
    iex> Blackjack.hand_points([:"6", :A, :A])
    18
    iex> Blackjack.hand_points([:A, :K, :Q, :K, :K, :K])
    51
  """
  def hand_points(hand) when is_list (hand) do
    {aces, others} = hand
    |> Enum.map(&points/1)
    |> Enum.split_with(fn x -> length(x) > 1 end)

    points = Enum.sum(others |> Enum.map(fn [x] -> x end)) + length(aces)

    if points < 12 do
      points + 10
    else
      points
    end
  end

  @doc """
  Generate n shuffled decks of cards
  """
  def deck(num \\ 1) when is_integer(num) and num > 0 do
    1..(4 * num)
    |> Enum.flat_map(fn _ -> [:A, :"2", :"3", :"4", :"5", :"6", :"7", :"8", :"9", :"10", :J, :Q, :K] end)
    |> Enum.shuffle
  end

  @doc """
  Determine if a hand is a bust

  ## Examples

    iex> Blackjack.bust?([:A, :K, :Q])
    false
    iex> Blackjack.bust?([:A, :K, :Q, :K])
    true
  """
  def bust?(hand) when is_list(hand) do
    hand_points(hand) > @bust_limit
  end

  @doc """
  Determine if a hand is a blackjack

  ## Examples

    iex> Blackjack.blackjack?([:A, :K])
    true
    iex> Blackjack.blackjack?([:A, :K, :Q])
    false
    iex> Blackjack.blackjack?([:A, :K, :Q, :K])
    false
  """
  def blackjack?(hand) when is_list(hand) do
    length(hand) == 2 and hand_points(hand) == 21
  end
end
