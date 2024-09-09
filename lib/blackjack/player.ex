defmodule Blackjack.Player do
  alias Blackjack.Deck
  alias Blackjack.DefaultStrategy
  alias Blackjack.Hand
  alias Blackjack.Player

  defstruct strategy: DefaultStrategy,
            current_hand: [],
            split_hands: [],
            finished_hands: [],
            wins: 0,
            losses: 0,
            pushes: 0,
            funds: nil,
            maximum_funds: 0,
            default_wager: 10,
            wager: nil,
            round_result: nil

  @doc """
  Create a new player with a given stake

  ## Examples

    iex> Player.new(100)
    %Player{current_hand: [], finished_hands: [], funds: 100, losses: 0, split_hands: [], strategy: Blackjack.DefaultStrategy, wins: 0, default_wager: 10, wager: 10}
  """
  def new(funds \\ 0, strategy \\ DefaultStrategy, wager \\ 10) when is_integer(funds) and is_atom(strategy) and is_integer(wager) do
    %Player{funds: funds, maximum_funds: funds, strategy: strategy, default_wager: wager, wager: wager}
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
    iex> player = %Player{Player.new() | current_hand: [:"9", :"2"]}
    iex> {%Player{current_hand: nil, finished_hands: [[:"9", :"2", :A]], wager: 20}, %Deck{cards: [:Q, :K, :"8"]}} = Player.play_hand(player, dealer, deck)
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
    case strategy.action(player, dealer_card) do
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

      :double ->
        {player = %Player{current_hand: hand}, deck} = Deck.deal(player, deck)
        {%Player{player | current_hand: nil, finished_hands: finished_hands ++ [hand], wager: 2 * player.wager}, deck}
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
    not (Enum.all?(hands, fn hand -> Hand.bust?(hand) or Hand.blackjack?(hand) end))
  end

  def broke?(%Player{funds: funds}) do
    funds <= 0
  end

  @doc """
  Determine the winnings for a player

  ## Examples

    iex> Player.winnings([:"6", :"7", :"6"], [:A, :"3", :"4"], 10)
    {:win, 10}

    iex> Player.winnings([:"6", :"7"], [:A, :"3", :"4"], 10)
    {:loss, -10}

    iex> Player.winnings([:"6", :"7", :"6", :"9"], [:A, :"3", :"4"], 10)
    {:bust, -10}

    iex> Player.winnings([:A, :K], [:A, :K], 10)
    {:push, 0}

    iex> Player.winnings([:"6", :"7", :"4"], [:A, :"6"], 10)
    {:push, 0}

    iex> Player.winnings([:A, :K], [:A, :"3"], 10)
    {:blackjack, 15}

    iex> Player.winnings(~H"A3", ~H"AK", 10)
    {:dealer_blackjack, -10}
  """
  def winnings(player_hand, dealer_hand, wager)
    when is_list(player_hand) and is_list(dealer_hand) and is_integer(wager) do
    cond do
      Hand.blackjack?(dealer_hand) and not Hand.blackjack?(player_hand) ->
        {:dealer_blackjack, -wager}

      Hand.blackjack?(player_hand) and not Hand.blackjack?(dealer_hand) ->
        {:blackjack, trunc(wager * 1.5)}

      true ->
        player_points = Hand.points(player_hand)
        dealer_points = Hand.points(dealer_hand)

        cond do
          player_points > 21 -> {:bust, -wager}
          dealer_points > 21 or player_points > dealer_points -> {:win, wager}
          player_points == dealer_points -> {:push, 0}
          true -> {:loss, -wager}
        end
    end
  end
end
