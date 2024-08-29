defmodule Blackjack.Player do
  alias Blackjack.Deck
  alias Blackjack.DefaultStrategy
  alias Blackjack.Player

  defstruct strategy: DefaultStrategy,
            current_hand: [],
            split_hands: [],
            finished_hands: [],
            wins: 0,
            losses: 0,
            pushes: 0,
            funds: nil

  @doc """
  Create a new player with a given stake

  ## Examples

    iex> Player.new(100)
    %Player{current_hand: [], finished_hands: [], funds: 100, losses: 0, split_hands: [], strategy: Blackjack.DefaultStrategy, wins: 0}
  """
  def new(funds \\ 0) when is_integer(funds) do
    %Player{funds: funds}
  end

  @doc """
  Play the current hand

  ## Examples

    iex> deck = %Deck{cards: [:A, :K, :Q, :K]}
    iex> dealer = %Player{current_hand: [:A, :"3"], strategy: Blackjack.DealerStrategy}
    iex> player = %Player{current_hand: [:"9", :"3"]}
    iex> Player.play_hand(player, dealer, deck)
    {%Player{current_hand: nil, finished_hands: [[:"9", :"3", :A, :K]]}, %Deck{cards: [:Q, :K]}}

    iex> deck = %Deck{cards: [:A, :K, :Q, :K]}
    iex> dealer = %Player{current_hand: [:A, :"3"], strategy: Blackjack.DealerStrategy}
    iex> player = %Player{current_hand: [:"9", :A]}
    iex> Player.play_hand(player, dealer, deck)
    {%Player{current_hand: nil, finished_hands: [[:"9", :A]]}, %Deck{cards: [:A, :K, :Q, :K]}}

    iex> deck = %Deck{cards: [:"7", :Q, :K, :"8"]}
    iex> dealer = %Player{current_hand: [:A, :"3"], strategy: Blackjack.DealerStrategy}
    iex> player = %Player{current_hand: [:A, :A]}
    iex> Player.play_hand(player, dealer, deck)
    {%Player{current_hand: nil, finished_hands: [[:A, :"7"], [:A, :Q]]}, %Deck{cards: [:K, :"8"]}}

    iex> deck = %Deck{cards: [:A, :Q, :K, :"8"]}
    iex> dealer = %Player{current_hand: [:A, :"3"], strategy: Blackjack.DealerStrategy}
    iex> player = %Player{current_hand: [:A, :A]}
    iex> Player.play_hand(player, dealer, deck)
    {%Player{current_hand: nil, finished_hands: [[:A, :Q], [:A, :K], [:A, :"8"]]}, %Deck{cards: []}}

    iex> deck = %Deck{cards: [:A, :Q, :K, :"8"]}
    iex> dealer = %Player{current_hand: [:A, :"3"], strategy: Blackjack.DealerStrategy}
    iex> player = %Player{current_hand: [:"9", :"2"]}
    iex> Player.play_hand(player, dealer, deck)
    {%Player{current_hand: nil, finished_hands: [[:"9", :"2", :A]]}, %Deck{cards: [:Q, :K, :"8"]}}
  """
  def play_hand(
        player = %Player{
          current_hand: current_hand,
          strategy: strategy,
          split_hands: split_hands,
          finished_hands: finished_hands
        },
        dealer = %Player{current_hand: [dealer_card | _other_cards]},
        deck
      ) do
    case strategy.action(current_hand, dealer_card) do
      :hit ->
        {player, deck} = Deck.deal(player, deck)
        play_hand(player, dealer, deck)

      :stand ->
        case splits(split_hands) do
          {next_hand, splits} ->
            play_hand(
              %Player{
                player
                | current_hand: next_hand,
                  split_hands: splits,
                  finished_hands: finished_hands ++ [current_hand]
              },
              dealer,
              deck
            )

          _ ->
            {%Player{
               player
               | current_hand: nil,
                 finished_hands: finished_hands ++ [current_hand]
             }, deck}
        end

      :split ->
        [card1, card2] = current_hand

        play_hand(
          %Player{
            player
            | current_hand: [card1],
              split_hands: split_hands ++ [[card2]],
              finished_hands: finished_hands
          },
          dealer,
          deck
        )

      :double_down ->
        {player = %Player{current_hand: hand}, deck} = Deck.deal(player, deck)
        {%Player{player | current_hand: nil, finished_hands: finished_hands ++ [hand]}, deck}
    end
  end

  defp splits([]), do: nil
  defp splits([next_hand | splits]), do: {next_hand, splits}

  @doc """
  Test if the player has any non-busted hands

  ## Examples

    iex> player = %Player{current_hand: nil, finished_hands: [[:"3", :"9"]]}
    iex> Player.still_going?(player)
    true

    iex> player = %Player{current_hand: nil, finished_hands: [[:A, :K]]}
    iex> Player.still_going?(player)
    false

    iex> player = %Player{current_hand: nil, finished_hands: [[:"8", :K, :Q]]}
    iex> Player.still_going?(player)
    false

    iex> player = %Player{current_hand: nil, finished_hands: [[:A, :K, :Q], [:A, :"9", :Q, :K]]}
    iex> Player.still_going?(player)
    true

    iex> player = %Player{current_hand: nil, finished_hands: [[:A, :K, :Q, :J], [:A, :"9", :Q, :K]]}
    iex> Player.still_going?(player)
    false

    iex> player = %Player{current_hand: nil, finished_hands: [[:A, :K], [:A, :"9"]]}
    iex> Player.still_going?(player)
    true

    iex> player = %Player{current_hand: nil, finished_hands: [[:A, :K], [:A, :Q]]}
    iex> Player.still_going?(player)
    false

    iex> player = %Player{current_hand: nil, finished_hands: [[:A, :K], [:K, :Q, :"3"]]}
    iex> Player.still_going?(player)
    false
  """
  def still_going?(%Player{finished_hands: hands}) do
    not (Enum.all?(hands, fn hand -> Blackjack.bust?(hand) or Blackjack.blackjack?(hand) end))
  end
end
