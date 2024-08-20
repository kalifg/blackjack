defmodule Blackjack.Player do
  alias Blackjack.Player
  use GenServer

  defstruct [:deck, :strategy, hand: [], wins: 0, losses: 0]

  ## Client API

  def start_link(name, player = %Player{}) do
    GenServer.start_link(__MODULE__, player, name: name)
  end

  @doc """
  Show the player's hand

  ## Examples

      iex> {:ok, deck} = Blackjack.Deck.start_link([:A, :K, :Q, :K])
      iex> {:ok, pid} = Blackjack.Player.start_link(:player, %Player{deck: deck, strategy: Blackjack.DealerStrategy, hand: [:"9", :"3"]})
      iex> Blackjack.Player.show_hand(pid)
      [:"9", :"3"]
  """
  def show_hand(pid) do
    GenServer.call(pid, :show_hand)
  end

  @doc """
  Take a card from the deck

  ## Examples

      iex> {:ok, deck} = Blackjack.Deck.start_link([:A, :K, :Q, :K])
      iex> {:ok, pid} = Blackjack.Player.start_link(:player, %Player{deck: deck, strategy: Blackjack.DealerStrategy, hand: [:"9", :"3"]})
      iex> Blackjack.Player.hit(pid)
      [:"9", :"3", :A]
      iex> Blackjack.Player.hit(pid)
      [:"9", :"3", :A, :K]
  """
  def hit(pid) do
    GenServer.call(pid, :hit)
  end

  @doc """
  Play the house's hand

  ## Examples

    iex> {:ok, deck} = Blackjack.Deck.start_link([:A, :K, :Q, :K])
    iex> {:ok, pid} = Blackjack.Player.start_link(:player, %Player{deck: deck, strategy: Blackjack.DealerStrategy, hand: [:"9", :"3"]})
    iex> Blackjack.Player.play_hand(pid)
    [:"9", :"3", :A,  :K]
  """
  def play_hand(pid) do
    GenServer.call(pid, :play_hand)
  end

  # Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call(:show_hand, _from, player = %Player{hand: hand}) do
    {:reply, hand, player}
  end

  def handle_call(:hit, _from, player = %Player{deck: deck, hand: hand}) do
    card = Blackjack.Deck.draw_card(deck)
    hand = hand ++ [card]
    {:reply, hand, %{player | hand: hand}}
  end

  def handle_call(:play_hand, from, player = %Player{deck: deck, strategy: strategy, hand: hand}) do
    if strategy.should_hit?(hand) do
      card = Blackjack.Deck.draw_card(deck)
      handle_call(:play_hand, from, %{player | hand: hand ++ [card]})
    else
      {:reply, hand, player}
    end
  end
end
