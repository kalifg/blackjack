defmodule Blackjack.Player do
  # alias Blackjack.Dealer
  # alias Blackjack.Deck
  alias Blackjack.DefaultStrategy
  alias Blackjack.Player

  use GenServer

  defstruct [strategy: DefaultStrategy, hand: [], wins: 0, losses: 0]

  ## Client API

  # def start_link(name, player = %Player{}) do
  #   GenServer.start_link(__MODULE__, player, name: name)
  # end

  # @doc """
  # Show the player's hand

  # ## Examples

  #     iex> {:ok, pid} = Player.start_link(:player, %Player{hand: [:"9", :"3"]})
  #     iex> Player.show_hand(pid)
  #     [:"9", :"3"]
  # """
  # def show_hand(pid) do
  #   GenServer.call(pid, :show_hand)
  # end

  # @doc """
  # Take a card from the deck

  # ## Examples

  #     iex> deck = %Deck{cards: [:A, :K, :Q, :K]}
  #     iex> {:ok, dealer} = Dealer.start_link(%Dealer{deck: deck})
  #     iex> {:ok, player} = Player.start_link(:player, %Player{hand: [:"9", :"3"]})
  #     iex> Player.hit(dealer)
  #     [:"9", :"3", :A]
  #     iex> Player.hit(dealer)
  #     [:"9", :"3", :A, :K]
  # """
  # def hit(pid) do
  #   GenServer.call(pid, :hit)
  # end

  # @doc """
  # Play the player's hand

  # ## Examples

  #   iex> deck = %Deck{cards: [:A, :K, :Q, :K]}
  #   iex> {:ok, player} = Blackjack.Player.start_link(:player, %Player{hand: [:"9", :"3"]})
  #   iex> {:ok, dealer} = Blackjack.Player.start_link(:dealer, %Dealer{deck: deck})
  #   iex> Blackjack.Player.play_hand(dealer)
  #   [[:"9", :"3", :A, :K]]
  # """
  # def play(player, dealer) when is_pid(player) and is_pid(dealer) do
  #   GenServer.call(player, {:play, dealer})
  # end

  # Server Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call(:show_hand, _from, player = %Player{hand: hand}) do
    {:reply, hand, player}
  end

  def handle_call({:receive, card}, _from, player = %Player{hand: hand}) do
    player = %{player | hand: hand ++ [card]}
    {:reply, player, player}
  end

  # def handle_call(:hit, _from, player = %Player{hand: hand}) do
  #   card = Blackjack.Deck.draw_card(deck)
  #   hand = hand ++ [card]
  #   {:reply, hand, %{player | hand: hand}}
  # end

  # def handle_call({:play, dealer}, _from, player = %Player{deck: deck, strategy: strategy, hand: hand}) when is_pid(dealer) do
  #   {:reply, play_hand(hand, show_hand(dealer) |> hd, strategy), %{player | hand: hand}}
  # end

  # defp play_hand(hand, dealer, strategy) do
  #   # case strategy.action(hand, dealer) do
  #   #   :hit -> play_hand(hand ++ [Blackjack.Deck.draw_card(deck)], dealer_card, deck, strategy)
  #   #   :stand -> hand
  #   #   :double_down -> hand ++ [Blackjack.Deck.draw_card(deck)]
  #   #   :split -> [hand, hand]
  #   # end
  # end
end
