defmodule Blackjack do
  @moduledoc """
  Documentation for `Blackjack`.
  """

  # Any hand greater than this value is a bust
  @bust_limit 21

  # The house hits on any hand less than or equal to this value
  @house_limit 16

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
  Deal a card from the deck

  ## Examples

    iex> Blackjack.deal([:A, :K, :Q, :J])
    {:A, [:K, :Q, :J]}
    iex> Blackjack.deal([:"1", :"7", :A, :"3"])
    {:"1", [:"7", :A, :"3"]}
  """
  def deal(deck) when is_list(deck) do
    {Enum.at(deck, 0), Enum.drop(deck, 1)}
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
  Determine if the house should hit

  ## Examples

    iex> Blackjack.house_should_hit?([:A, :K])
    false
    iex> Blackjack.house_should_hit?([:A, :K, :Q])
    false
    iex> Blackjack.house_should_hit?([:A, :K, :Q, :K])
    false
    iex> Blackjack.house_should_hit?([:A, :K, :Q, :K, :K])
    false
    iex> Blackjack.house_should_hit?([:A, :"5", :K])
    true
  """
  def house_should_hit?(hand) when is_list(hand) do
    hand_points(hand) <= @house_limit
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

  @doc """
  Hit a hand

  ## Examples
    iex> Blackjack.hit([:"3", :"9"],[:"9", :"3", :"6", :K, :A])
    {[:"3", :"9", :"9"], [:"3", :"6", :K, :A]}
  """
  def hit(hand, deck) when is_list(deck) and is_list(hand) do
    {card, deck} = deal(deck)
    {hand ++ [card], deck}
  end

  @doc """
  Play the house's hand

  ## Examples

    iex> Blackjack.play_house([:A, :K], [:A, :K, :Q, :K])
    {[:A, :K], [:A, :K, :Q, :K]}
    iex> Blackjack.play_house([:"3", :"9"], [:"9", :"3", :"6", :K, :A])
    {[:"3", :"9", :"9"], [:"3", :"6", :K, :A]}
    iex> Blackjack.play_house([:"3", :"3"], [:"9", :"3", :"6", :K, :A])
    {[:"3", :"3", :"9", :"3"], [:"6", :K, :A]}
  """
  def play_house(hand, deck) when is_list(deck) and is_list(hand) do
    if house_should_hit?(hand) do
      {hand, deck} = hit(hand, deck)
      play_house(hand, deck)
    else
      {hand, deck}
    end
  end

  # @doc """
  # Deal the players' hands and then the house's hand

  # ## Examples

  #   Blackjack.deal_hands([:A, :K, :"9", :"3", :"6", :K, :A, :Q, :J], 2)
  #   {[[:A, :"3"], [:K, :"6"]], [:"9", :K], [:A, :Q, :J]}
  # """
  # def deal_hands(deck, num_players) when is_list(deck) and is_integer(num_players) do
  #   Enum.map(1..num_players, fn _ -> deal(deck) end) |> IO.inspect(label: "Players' hands")
  # end
end
