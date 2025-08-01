defmodule Blackjack.Dealer do
  alias Blackjack.Player
  alias Blackjack.Deck

  @doc """
  Create a dealer

  ## Examples

    iex> %Player{strategy: Blackjack.DealerStrategy}
  """
  def new() do
    %Player{strategy: Blackjack.DealerStrategy}
  end

  @doc """
  Deal hands for a round of blackjack

  ## Examples

    iex> deck = %Deck{cards: [:A, :"3", :"5", :J, :Q, :K, :"2", :"4", :"6", :T]}
    iex> player = Player.new(100)
    iex> dealer = Dealer.new()
    iex> {[%Player{current_hand: [:A, :"5"]}], %Player{current_hand: [:"3", :J]}, %Deck{cards: [:Q, :K, :"2", :"4", :"6", :T]}} = Dealer.deal_hands([player], dealer, deck)
  """
  def deal_hands(players, dealer = %Player{}, deck = %Deck{}) when is_list(players) do
    1..2 |> Enum.reduce({players, dealer, deck}, fn _, {players, dealer, deck} ->
      deal_round(players, dealer, deck)
    end)
  end

  defp deal_round(players, dealer = %Player{}, deck = %Deck{}) when is_list(players) do
    {players, deck} = players |> Enum.reduce({[], deck}, fn player, {players, deck} ->
      {player, deck} = Deck.deal(player, deck)
      {players ++ [player], deck}
    end)

    {dealer, deck} = Deck.deal(dealer, deck)

    {players, dealer, deck}
  end

  @doc """
  Play a round of blackjack

  ## Examples

      iex> deck = %Deck{cards: [:"9", :"3", :"2", :J, :Q, :K, :"2", :"4", :"6", :T]}
      iex> player = Player.new(100)
      iex> dealer = Dealer.new()
      iex> {[%Player{finished_hands: [[:"9", :"2", :Q]], wins: 1, funds: 120}], %Player{finished_hands: [[:"3", :J, :K]]}, %Deck{cards: [:"2", :"4", :"6", :T]}} = Dealer.play_round([player], dealer, deck)

      iex> deck = %Deck{cards: [:"9", :"3", :"2", :J, :"4", :"6", :"2", :"4", :"6", :T]}
      iex> player = Player.new(100)
      iex> dealer = Dealer.new()
      iex> {[%Player{finished_hands: [[:"9", :"2", :"4"]], losses: 1, funds: 80}], %Player{finished_hands: [[:"3", :J, :"6"]]}, %Deck{cards: [:"2", :"4", :"6", :T]}} = Dealer.play_round([player], dealer, deck)

      iex> deck = %Deck{cards: [:A, :"3", :"6", :J, :Q, :K, :"2", :"4", :"6", :T]}
      iex> player = Player.new(100)
      iex> dealer = Dealer.new()
      iex> {[%Player{finished_hands: [[:A, :"6"]], wins: 1, funds: 110}], %Player{finished_hands: [[:"3", :J, :Q]]}, %Deck{cards: [:K, :"2", :"4", :"6", :T]}} = Dealer.play_round([player], dealer, deck)

      iex> deck = %Deck{cards: [:A, :"3", :"2", :J, :Q, :K, :"2", :"4", :"6", :T]}
      iex> player = Player.new(100)
      iex> dealer = Dealer.new()
      iex> {[%Player{finished_hands: [[:A, :"2", :Q, :K]], losses: 1, funds: 90}], %Player{finished_hands: [[:"3", :J]]}, %Deck{cards: [:"2", :"4", :"6", :T]}} = Dealer.play_round([player], dealer, deck)

      iex> deck = %Deck{cards: [:"2", :"3", :Q, :J, :Q, :K, :"2", :"4", :"6", :T]}
      iex> player = Player.new(100)
      iex> dealer = Dealer.new()
      iex> {[%Player{finished_hands: [[:"2", :Q, :Q]], losses: 1, funds: 90}], %Player{finished_hands: [[:"3", :J]]}, %Deck{cards: [:K, :"2", :"4", :"6", :T]}} = Dealer.play_round([player], dealer, deck)

      iex> deck = %Deck{cards: [:A, :"3", :Q, :J, :Q, :K, :"2", :"4", :"6", :T]}
      iex> player = Player.new(100)
      iex> dealer = Dealer.new()
      iex> {[%Player{finished_hands: [[:A, :Q]], wins: 1, funds: 115}], %Player{finished_hands: [[:"3", :J]]}, %Deck{cards: [:Q, :K, :"2", :"4", :"6", :T]}} = Dealer.play_round([player], dealer, deck)

      iex> deck = %Deck{cards: [:A, :"3", :Q, :J, :Q, :K, :"2", :"4", :"6", :T, :"5", :"7", :"9"]}
      iex> player_1 = Player.new(100)
      iex> player_2 = Player.new(100)
      iex> player_3 = Player.new(100)
      iex> dealer = Dealer.new()
      iex>
      ...> {
      ...>  [
      ...>     %Player{finished_hands: [[:A, :Q]], wins: 1, funds: 115},
      ...>     %Player{finished_hands: [[:"3", :K, :"6"]], pushes: 1, funds: 100},
      ...>     %Player{finished_hands: [[:Q, :"2", :T]], losses: 1, funds: 90}
      ...>  ],
      ...>  %Player{finished_hands: [[:J, :"4", :"5"]]},
      ...>  %Deck{cards: [:"7", :"9"]}} = Dealer.play_round([player_1, player_2, player_3], dealer, deck)
  """
  def play_round(players, dealer = %Player{}, deck = %Deck{}) when is_list(players) do
    {players, dealer, deck} = deal_hands(players, dealer, deck)

    {players, dealer, deck} = players |> Enum.reduce({[], dealer, deck}, fn player, {players, dealer, deck} ->
      {player, deck} = if not Player.broke?(player) do
        Player.play_hand(player, dealer, deck)
      else
        {player, deck}
      end

      {players ++ [player], dealer, deck}
    end)

    {dealer, deck} = if Enum.any?(players, &Player.still_going?/1) do
      Player.play_hand(dealer, dealer, deck)
    else
      {%Player{dealer | current_hand: nil, finished_hands: dealer.finished_hands ++ [dealer.current_hand]}, deck}
    end

    {players, dealer} = players |> Enum.reduce({[], dealer}, fn player = %Player{finished_hands: finished_hands}, {players, dealer} ->
      {player, dealer} = finished_hands |> Enum.reduce({player, dealer}, fn hand, {player, dealer} ->
        {result, winnings} = Player.winnings(hand, dealer.finished_hands |> hd, player.wager)
        player = %Player{player | funds: player.funds + winnings, maximum_funds: max(player.maximum_funds, player.funds + winnings), round_result: result}

        if player.funds < 0 do
          Blackjack.display_round_status(0, dealer, players, deck)
        end

        player = cond do
          winnings > 0 -> %Player{player | wins: player.wins + 1}
          winnings < 0 -> %Player{player | losses: player.losses + 1}
          true -> %Player{player | pushes: player.pushes + 1}
        end

        {player, dealer}
      end)
      {players ++ [player], dealer}
    end)

    {players, dealer, deck}
  end

  @doc """
  Clear the hands after a round of blackjack

  ## Examples

      iex> players = [%Player{current_hand: [:A, :K], split_hands: [[:A, :"6"]], finished_hands: [[:A, :K]], funds: 20, default_wager: 10, wager: 20}, %Player{current_hand: [:A, :K], split_hands: [[:A, :"6"]], finished_hands: [[:A, :K]], funds: 5, default_wager: 10, wager: 10}]
      iex> dealer = %Player{current_hand: [:A, :K], finished_hands: [[:A, :K]]}
      iex> {[%Player{current_hand: [], split_hands: [], finished_hands: [], wager: 10}, %Player{current_hand: [], split_hands: [], finished_hands: [], wager: 5}], %Player{current_hand: [], finished_hands: []}} = Dealer.clear_hands(players, dealer)
  """
  def clear_hands(players, dealer = %Player{}) when is_list(players) do
    players = players |> Enum.map(fn player ->
      %Player{player | current_hand: [], split_hands: [], finished_hands: [], wager: min(player.funds, player.default_wager), round_result: nil}
    end)

    dealer = %Player{dealer | current_hand: [], finished_hands: []}

    {players, dealer}
  end
end
