defmodule Blackjack.DeckServer do
  use GenServer

  # Client API

  def start_link(initial_deck) do
    GenServer.start_link(__MODULE__, initial_deck, name: __MODULE__)
  end

  @doc """
  Return the number of cards left in the deck

  ## Examples
    iex> {:ok, pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    iex> Blackjack.DeckServer.count(pid)
    4
    iex> Blackjack.DeckServer.draw_card(pid)
    iex> Blackjack.DeckServer.count(pid)
    3
  """
  def count(pid) do
    GenServer.call(pid, :count)
  end

  @doc """
  Deal n hands from the deck

  ## Examples
    iex> {:ok, pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :"9"])
    iex> Blackjack.DeckServer.deal(pid, 2)
    [[:A, :Q], [:K, :"9"]]
  """
  def deal(pid, n) do
    GenServer.call(pid, {:deal, n})
  end

  @doc """
  Draw a card from the deck

  ## Examples
    iex> {:ok, pid} = Blackjack.DeckServer.start_link([:A, :K, :Q, :K])
    iex> Blackjack.DeckServer.draw_card(pid)
    :A
    iex> Blackjack.DeckServer.draw_card(pid)
    :K
    iex> Blackjack.DeckServer.draw_card(pid)
    :Q
    iex> Blackjack.DeckServer.draw_card(pid)
    :K
    iex> Blackjack.DeckServer.draw_card(pid)
    nil
  """
  def draw_card(pid) do
     GenServer.call(pid, :draw_card)
  end

  def shuffle_deck(pid) do
    GenServer.cast(pid, :shuffle_deck)
  end

  # Server API

  @doc """
  Initialize the deck

  ## Examples

    iex> Blackjack.DeckServer.init([:A, :K, :Q, :K])
    {:ok, [:A, :K, :Q, :K]}
  """
  def init(deck) do
    {:ok, deck}
  end

  def handle_call({:deal, n}, _from, deck) do
    {dealt, remaining} = Enum.split(deck, n * 2)
    {:reply, Enum.reverse(get_hands([], dealt, n)), remaining}
 end

  def handle_call(:draw_card, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:draw_card, _from, [card | rest_of_deck]) do
    {:reply, card, rest_of_deck}
  end

  def handle_call(:count, _from, deck) do
    {:reply, Enum.count(deck), deck}
  end

  def handle_cast(:shuffle_deck, deck) do
    {:noreply, Enum.shuffle(deck)}
  end

  defp get_hands(hands, cards, num_players) do
    if Enum.count(hands) < num_players do
      get_hands([Enum.take_every(cards, num_players) | hands], Enum.drop(cards, 1), num_players)
    else
      hands
    end
  end
end
