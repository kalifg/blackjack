defmodule Blackjack.DealerServer do
  use GenServer

  ## Client API

  def start_link(deck_pid) do
    GenServer.start_link(__MODULE__, {deck_pid, []}, name: __MODULE__)
  end

  @doc """
  Receive a card

  ## Examples

      iex> {:ok, deck_pid} = Blackjack.DeckServer.start_link([:"3", :"9", :A, :K, :Q, :K])
      iex> {:ok, pid} = Blackjack.DealerServer.start_link(deck_pid)
      iex> Blackjack.DealerServer.receive(pid, Blackjack.DeckServer.draw_card(deck_pid))
      [:"3"]
      iex> Blackjack.DealerServer.receive(pid, Blackjack.DeckServer.draw_card(deck_pid))
      [:"9", :"3"]
  """
  def receive(pid, card) do
    GenServer.call(pid, {:receive, card})
  end

  @doc """
  Play the house's hand

  ## Examples

    iex> {:ok, deck_pid} = Blackjack.DeckServer.start_link([:"3", :"9", :A, :K, :Q, :K])
    iex> {:ok, pid} = Blackjack.DealerServer.start_link(deck_pid)
    iex> Blackjack.DealerServer.receive(pid, Blackjack.DeckServer.draw_card(deck_pid))
    [:"3"]
    iex> Blackjack.DealerServer.receive(pid, Blackjack.DeckServer.draw_card(deck_pid))
    [:"9", :"3"]
    iex> Blackjack.DealerServer.play_house(pid)
    [:K, :A, :"9", :"3"]
  """
  def play_house(pid) do
    GenServer.call(pid, :play_house)
  end

  # Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:receive, card}, _from, {deck_pid, hand}) do
    {:reply, [card | hand], {deck_pid, [card | hand]}}
  end

  def handle_call(:play_house, from, {deck_pid, hand}) do
    if Blackjack.house_should_hit?(hand) do
      card = Blackjack.DeckServer.draw_card(deck_pid)
      handle_call(:play_house, from, {deck_pid, [card | hand]})
    else
      {:reply, hand, {deck_pid, hand}}
    end
  end
end
