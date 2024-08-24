defmodule Blackjack.Dealer do
  alias Blackjack.Dealer
  alias Blackjack.DealerStrategy
  alias Blackjack.Deck
  alias Blackjack.Player

  # use GenServer

  defstruct [deck: %Deck{}, player: %Player{strategy: DealerStrategy, hand: []}]

  # def start_link(dealer = %Dealer{deck: %Deck{}}) do
  #   GenServer.start_link(__MODULE__, dealer, name: __MODULE__)
  # end

  @doc """
  Request a card from the dealer

  ## Examples

    iex> deck = %Deck{cards: [:A, :K, :Q, :K]}
    iex> {:ok, dealer} = Blackjack.Dealer.start_link(%Dealer{deck: deck})
    iex> Blackjack.Dealer.hit(dealer)
    :A
  """
  def hit(dealer, deck) do
    {card, deck} = Deck.draw_card(deck)
    {card, %Dealer{deck: deck}}
  end

  def init(dealer) do
    {:ok, dealer}
  end

  def handle_call(:hit, _from, %Dealer{deck: deck}) do
    {card, deck} = Deck.draw_card(deck)
    {:reply, card, %Dealer{deck: deck}}
  end
end
