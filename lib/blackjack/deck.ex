defmodule Blackjack.Deck do
  defstruct cards: []

  alias Blackjack.Deck
  alias Blackjack.Player

  @doc """
  Return the number of cards left in the deck

  ## Examples
    iex> deck = %Deck{cards: [:A, :K, :Q, :K]}
    iex> Deck.count(deck)
    4
    iex> Deck.count(Deck.deal(%Player{}, deck) |> elem(1))
    3
  """
  def count(%Deck{cards: cards}) do
    Enum.count(cards)
  end

  # @doc """
  # Deal n hands from the deck

  # ## Examples
  #   iex> deck = %Deck{cards: [:A, :K, :Q, :"9"]}
  #   iex> Deck.deal(deck, 2)
  #   {[[:A, :Q], [:K, :"9"]], %Deck{cards: []}}
  # """
  # def deal(%Deck{cards: cards}, n) when is_integer(n) do
  #   {dealt, remaining} = Enum.split(cards, n * 2)
  #   {Enum.reverse(get_hands([], dealt, n)), %Deck{cards: remaining}}
  # end

    @doc """
  Deal a card to a player

  ## Examples

    iex> deck = %Deck{cards: [:"9", :A, :K, :Q, :K]}
    iex> player = %Player{}
    iex> {player, deck} = Deck.deal(player, deck)
    {%Player{hand: [:"9"]}, %Deck{cards: [:A, :K, :Q, :K]}}
    iex> Deck.deal(player, deck)
    {%Player{hand: [:"9", :A]}, %Deck{cards: [:K, :Q, :K]}}
  """
  def deal(player = %Player{hand: hand}, %Deck{cards: cards}) do
    {%Player{player | hand: hand ++ [cards |> hd]}, %Deck{cards: cards |> tl}}
  end

  # @doc """
  # Draw a card from the deck

  # ## Examples
  #   iex> deck = %Deck{cards: [:A, :K, :Q, :K]}
  #   iex> {_card, deck} = Deck.draw_card(deck)
  #   {:A, %Deck{cards: [:K, :Q, :K]}}
  #   iex> {_card, deck} = Deck.draw_card(deck)
  #   {:K, %Deck{cards: [:Q, :K]}}
  #   iex> {_card, deck} = Deck.draw_card(deck)
  #   {:Q, %Deck{cards: [:K]}}
  #   iex> {_card, deck} = Deck.draw_card(deck)
  #   {:K, %Deck{cards: []}}
  #   iex> Deck.draw_card(deck)
  #   {nil, %Deck{cards: []}}
  # """
  # def draw_card(%Deck{cards: []}) do
  #   {nil, %Deck{cards: []}}
  # end

  # def draw_card(%Deck{cards: [card | rest_of_deck]}) do
  #   {card, %Deck{cards: rest_of_deck}}
  # end

  def shuffle_deck(%Deck{cards: cards}) do
    %Deck{cards: Enum.shuffle(cards)}
  end

  # defp get_hands(hands, cards, num_players) do
  #   if Enum.count(hands) < num_players do
  #     get_hands([Enum.take_every(cards, num_players) | hands], Enum.drop(cards, 1), num_players)
  #   else
  #     hands
  #   end
  # end
end
