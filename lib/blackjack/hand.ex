defmodule Blackjack.Hand do
  @doc """
  Get the point values for a card or a hand of cards.

  ## Examples

    iex> Hand.points(:"1")
    [1]

    iex> Hand.points(:"2")
    [2]

    iex> Hand.points(:K)
    [10]

    iex> Hand.points(:A)
    [1, 11]

    iex> Hand.points([:A, :K])
    21

    iex> Hand.points([:A, :A, :K])
    12

    iex> Hand.points([:A, :A, :K, :K])
    22

    iex> Hand.points([:A, :A, :K, :K, :K])
    32

    iex> Hand.points([:"6", :"7", :"8"])
    21

    iex> Hand.points([:"6", :A, :"8"])
    15

    iex> Hand.points([:"6", :A, :A])
    18

    iex> Hand.points([:A, :K, :Q, :K, :K, :K])
    51

    iex> Hand.points([:"9", :"2"])
    11

    iex> Hand.points([:A, :"2", :Q])
    13

    iex> Hand.points([:A, :"2", :Q, :K])
    23
  """
  def points(card) when is_atom(card) do
    case card do
      :A -> [1, 11]
      :T -> [10]
      :K -> [10]
      :Q -> [10]
      :J -> [10]
      _ -> [card |> Atom.to_string() |> String.to_integer()]
    end
  end

  def points(hand) when is_list(hand) do
    {aces, others} =
      hand
      |> Enum.map(&points/1)
      |> Enum.split_with(fn x -> length(x) > 1 end)

    points = Enum.sum(others |> Enum.map(fn [x] -> x end)) + length(aces)

    if Enum.count(aces) > 0 and points < 12 do
      points + 10
    else
      points
    end
  end

  @doc """

  Classify a hand based on the two cards in the hand.

  ## Examples

  iex> Hand.classify(~H"AA")
  :pair_A

  iex> Hand.classify(~H"AK")
  :blackjack

  iex> Hand.classify(~H"A5")
  :soft_16

  iex> Hand.classify(~H"K5")
  :hard_15

  iex> Hand.classify(~H"TJ")
  :hard_20

  iex> Hand.classify(~H"678")
  :hard_21

  iex> Hand.classify(~H"QQ")
  :pair_10

  iex> Hand.classify(~H"K")
  :single
  """
  def classify([_card]) do
    :single
  end

  def classify([card, card]) do
    classify_pair(card)
  end

  def classify([:A, card]) when card in [:T, :J, :Q, :K] do
    :blackjack
  end

  def classify([card, :A]) when card in [:T, :J, :Q, :K] do
    :blackjack
  end

  def classify([:A, card]) do
    classify_soft(card)
  end

  def classify([card, :A]) do
    classify_soft(card)
  end

  def classify(hand) do
    points = points(hand)

    if points > 21 do
      :bust
    else
      classify_hard(points)
    end
  end

  defp classify_pair(card) when card in [:T, :J, :Q, :K] do
    String.to_atom("pair_10")
  end

  defp classify_pair(:A) do
    :pair_A
  end

  defp classify_pair(card) do
    String.to_atom("pair_#{card |> Atom.to_string() |> String.to_integer()}")
  end

  defp classify_soft(card) do
    String.to_atom("soft_#{(card |> Atom.to_string() |> String.to_integer()) + 11}")
  end

  defp classify_hard(points) when is_integer(points) do
    String.to_atom("hard_#{points}")
  end

  @doc """
  Determine if a hand is a bust

  ## Examples

    iex> Hand.bust?(~H"AKQ")
    false
    iex> Hand.bust?([:A, :K, :Q, :K])
    true
  """
  def bust?(hand) when is_list(hand) do
    points(hand) > 21
  end

  @doc """
  Determine if a hand is a blackjack

  ## Examples

    iex> Hand.blackjack?([:A, :K])
    true
    iex> Hand.blackjack?([:A, :K, :Q])
    false
    iex> Hand.blackjack?([:A, :K, :Q, :K])
    false
  """
  def blackjack?(hand) when is_list(hand) do
    length(hand) == 2 and points(hand) == 21
  end
end
