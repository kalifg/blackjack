defmodule Blackjack.Deck do
  defstruct num_decks: 1, cards: []

  alias Blackjack.Deck
  alias Blackjack.Player

  @doc """
  Generate n shuffled decks of cards
  """
  def new(num \\ 1) when is_integer(num) and num > 0 do
    %Deck{
      num_decks: num,
      cards:
        1..(4 * num)
        |> Enum.flat_map(fn _ ->
          [:A, :"2", :"3", :"4", :"5", :"6", :"7", :"8", :"9", :"10", :J, :Q, :K]
        end)
        |> Enum.shuffle()
    }
  end

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

  @doc """
  Deal a card to a player

  ## Examples

    iex> deck = %Deck{cards: [:"9", :A, :K, :Q, :K]}
    iex> player = %Player{}
    iex> {player, deck} = Deck.deal(player, deck)
    {%Player{current_hand: [:"9"]}, %Deck{cards: [:A, :K, :Q, :K]}}
    iex> Deck.deal(player, deck)
    {%Player{current_hand: [:"9", :A]}, %Deck{cards: [:K, :Q, :K]}}
  """
  def deal(player = %Player{current_hand: hand}, %Deck{cards: cards}) do
    {%Player{player | current_hand: hand ++ [cards |> hd]}, %Deck{cards: cards |> tl}}
  end

  def shuffle_deck(%Deck{cards: cards}) do
    %Deck{cards: Enum.shuffle(cards)}
  end
end
