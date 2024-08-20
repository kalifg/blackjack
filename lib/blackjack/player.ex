defmodule Blackjack.Player do
  use GenServer

  ## Client API

  def start_link(name, deck_pid, strategy_module, hand) do
    GenServer.start_link(__MODULE__, {deck_pid, strategy_module, hand}, name: name)
  end

  @doc """
  Show the player's hand

  ## Examples

      iex> {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
      iex> {:ok, pid} = Blackjack.Player.start_link(:player, deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
      iex> Blackjack.Player.show_hand(pid)
      [:"9", :"3"]
  """
  def show_hand(pid) do
    GenServer.call(pid, :show_hand)
  end

  @doc """
  Take a card from the deck

  ## Examples

      iex> {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
      iex> {:ok, pid} = Blackjack.Player.start_link(:player, deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
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

    iex> {:ok, deck_pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    iex> {:ok, pid} = Blackjack.Player.start_link(:player, deck_pid, Blackjack.DealerStrategy, [:"9", :"3"])
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

  def handle_call(:show_hand, _from, {deck_pid, strategy, hand}) do
    {:reply, hand, {deck_pid, strategy, hand}}
  end

  def handle_call(:hit, _from, {deck_pid, strategy, hand}) do
    card = Blackjack.DeckServer.draw_card(deck_pid)
    hand = hand ++ [card]
    {:reply, hand, {deck_pid, strategy, hand}}
  end

  def handle_call(:play_hand, from, {deck_pid, strategy, hand}) do
    if strategy.should_hit?(hand) do
      card = Blackjack.DeckServer.draw_card(deck_pid)
      handle_call(:play_hand, from, {deck_pid, strategy, hand ++ [card]})
    else
      {:reply, hand, {deck_pid, strategy, hand}}
    end
  end
end
