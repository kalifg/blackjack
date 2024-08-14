defmodule Blackjack.DeckServer do
  use GenServer

  # Client API

  def start_link(initial_deck) do
    GenServer.start_link(__MODULE__, initial_deck, name: __MODULE__)
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

  @doc """
  Draw a card from the deck

  ## Examples

    iex> Blackjack.DeckServer.handle_call(:draw_card, nil, [:A, :K, :Q, :K])
    {:reply, :A, [:K, :Q, :K]}
    iex> Blackjack.DeckServer.handle_call(:draw_card, nil, [])
    {:reply, nil, []}
  """
  def handle_call(:draw_card, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:draw_card, _from, [card | rest_of_deck]) do
    {:reply, card, rest_of_deck}
  end

  def handle_cast(:shuffle_deck, deck) do
    {:noreply, Enum.shuffle(deck)}
  end
end
