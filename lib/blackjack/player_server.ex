defmodule Blackjack.PlayerServer do
  use GenServer

  ## Client API

  def start_link(deck_pid, strategy_module, hand) do
    GenServer.start_link(__MODULE__, {deck_pid, strategy_module, hand}, name: __MODULE__)
  end

  @doc """
  Take a card from the deck

  ## Examples

      iex> {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
      iex> {:ok, pid} = Blackjack.PlayerServer.start_link(deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
      iex> Blackjack.PlayerServer.hit(pid)
      [:"9", :"3", :A]
      iex> Blackjack.PlayerServer.hit(pid)
      [:"9", :"3", :A, :K]
  """
  def hit(pid) do
    GenServer.call(pid, :hit)
  end

  @doc """
  Play the house's hand

  ## Examples

    iex> {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    iex> {:ok, pid} = Blackjack.PlayerServer.start_link(deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
    iex> Blackjack.PlayerServer.play_house(pid)
    [:"9", :"3", :A,  :K]
  """
  def play_house(pid) do
    GenServer.call(pid, :play_house)
  end

  # Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call(:hit, _from, {deck_pid, strategy, hand}) do
    card = Blackjack.DeckServer.draw_card(deck_pid)
    hand = hand ++ [card]
    {:reply, hand, {deck_pid, strategy, hand}}
  end

  def handle_call(:play_house, from, {deck_pid, strategy, hand}) do
    if strategy.should_hit?(hand) do
      card = Blackjack.DeckServer.draw_card(deck_pid)
      handle_call(:play_house, from, {deck_pid, strategy, hand ++ [card]})
    else
      {:reply, hand, {deck_pid, strategy, hand}}
    end
  end
end
