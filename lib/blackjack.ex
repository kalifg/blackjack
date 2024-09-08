defmodule Blackjack do
  alias Blackjack.Dealer
  alias Blackjack.Deck
  alias Blackjack.Player

  @moduledoc """
  Documentation for `Blackjack`.
  """

  # Any hand greater than this value is a bust
  @bust_limit 21

  def main([decks, rounds, strategy, funds, wager]) do
    IO.puts("Attempting #{rounds} rounds of blackjack")

    deck = Deck.new(String.to_integer(decks))
    dealer = Dealer.new()

    player =
      Player.new(
        String.to_integer(funds),
        Module.concat([String.to_atom(strategy)]),
        String.to_integer(wager)
      )

    players = [player]

    {players, dealer, deck} =
      Enum.reduce(1..String.to_integer(rounds), {players, dealer, deck}, &play_or_exit/2)

    display_end_status(rounds, dealer, players, deck)
  end

  defp play_or_exit(round, {players, dealer, deck}) do
    if Enum.all?(players, &Player.broke?/1) do
      display_end_status(round, dealer, players, deck)
      IO.puts("All players are broke")
      exit(:normal)
    else
      play_round(round, {players, dealer, deck})
    end
  end

  defp play_round(_round, {players, dealer, deck}) do
    {players, dealer, deck} = Dealer.play_round(players, dealer, deck)
    {players, dealer} = Dealer.clear_hands(players, dealer)

    deck =
      if Deck.count(deck) < 20 do
        Deck.new(deck.num_decks)
      else
        deck
      end

    {players, dealer, deck}
  end

  defp display_end_status(round, _dealer, players, _deck) do
    IO.inspect(
      %{
        Players:
          Enum.map(players, fn player ->
            [
              wins: player.wins,
              losses: player.losses,
              pushes: player.pushes,
              win_percentage: display_win_percentage(player),
              maximum_funds: player.maximum_funds,
              funds: player.funds
            ]
          end)
      },
      label: "Round #{round}"
    )
  end

  defp display_win_percentage(%Player{wins: wins, losses: losses, pushes: pushes})
       when wins + losses + pushes == 0 do
    "0%"
  end

  defp display_win_percentage(%Player{wins: wins, losses: losses, pushes: pushes}) do
    ((wins / (wins + losses + pushes) * 100) |> Float.round(2) |> Float.to_string()) <> "%"
  end

  def display_round_status(round, dealer, players, _deck) do
    IO.inspect(
      %{
        Dealer: dealer.finished_hands |> Enum.map(&display_hand/1),
        Players:
          Enum.map(players, fn player ->
            [
              hands: player.finished_hands |> Enum.map(&display_hand/1),
              wins: player.wins,
              losses: player.losses,
              pushes: player.pushes,
              win_percentage:
                ((player.wins / (player.wins + player.losses + player.pushes) * 100)
                 |> Float.round(2)
                 |> Float.to_string()) <> "%",
              wager: player.wager,
              result: player.round_result,
              maximum_funds: player.maximum_funds,
              funds: player.funds
            ]
          end)
      },
      label: "Round #{round}"
    )
  end

  defp display_hand(hand) do
    (hand |> Enum.join("")) <> " (" <> Integer.to_string(hand_points(hand)) <> ")"
  end

  @doc """
  Get the point values for a card

  ## Examples

    iex> Blackjack.points(:"1")
    [1]
    iex> Blackjack.points(:"2")
    [2]
    iex> Blackjack.points(:K)
    [10]
    iex> Blackjack.points(:A)
    [1, 11]

  """
  def points(card) when is_atom(card) do
    case card do
      :A -> [1, 11]
      :T -> [10]
      :K -> [10]
      :Q -> [10]
      :J -> [10]
      _ -> [card |> Atom.to_string() |> String.to_integer()]
    end
  end

  @doc """
  Get the point values for a hand.  If the hand contains an ace, the ace will be
  counted as 11 if the total is less than or equal to 11, otherwise it will be
  counted as 1.

  ## Examples

    iex> Blackjack.hand_points([:A, :K])
    21
    iex> Blackjack.hand_points([:A, :A, :K])
    12
    iex> Blackjack.hand_points([:A, :A, :K, :K])
    22
    iex> Blackjack.hand_points([:A, :A, :K, :K, :K])
    32
    iex> Blackjack.hand_points([:"6", :"7", :"8"])
    21
    iex> Blackjack.hand_points([:"6", :A, :"8"])
    15
    iex> Blackjack.hand_points([:"6", :A, :A])
    18
    iex> Blackjack.hand_points([:A, :K, :Q, :K, :K, :K])
    51
    iex> Blackjack.hand_points([:"9", :"2"])
    11
    iex> Blackjack.hand_points([:A, :"2", :Q])
    13
    iex> Blackjack.hand_points([:A, :"2", :Q, :K])
    23
  """
  def hand_points(hand) when is_list(hand) do
    {aces, others} =
      hand
      |> Enum.map(&points/1)
      |> Enum.split_with(fn x -> length(x) > 1 end)

    points = Enum.sum(others |> Enum.map(fn [x] -> x end)) + length(aces)

    if Enum.count(aces) > 0 and points < 12 do
      points + 10
    else
      points
    end
  end

  @doc """
  Classify a hand based on the two cards in the hand.

  ## Examples

  iex> Blackjack.classify_hand(~H"AA")
  :pair_A

  iex> Blackjack.classify_hand(~H"AK")
  :blackjack

  iex> Blackjack.classify_hand(~H"A5")
  :soft_16

  iex> Blackjack.classify_hand(~H"K5")
  :hard_15

  iex> Blackjack.classify_hand(~H"TJ")
  :hard_20

  iex> Blackjack.classify_hand(~H"678")
  :hard_21

  iex> Blackjack.classify_hand(~H"QQ")
  :pair_10

  iex> Blackjack.classify_hand(~H"K")
  :single
  """
  def classify_hand([_card]) do
    :single
  end

  def classify_hand([card, card]) do
    classify_pair(card)
  end

  def classify_hand([:A, card]) when card in [:T, :J, :Q, :K] do
    :blackjack
  end

  def classify_hand([card, :A]) when card in [:T, :J, :Q, :K] do
    :blackjack
  end

  def classify_hand([:A, card]) do
    classify_soft(card)
  end

  def classify_hand([card, :A]) do
    classify_soft(card)
  end

  def classify_hand(hand) do
    points = hand_points(hand)

    if points > 21 do
      :bust
    else
      classify_hard(points)
    end
  end

  defp classify_pair(card) when card in [:T, :J, :Q, :K] do
    String.to_atom("pair_10")
  end

  defp classify_pair(:A) do
    :pair_A
  end

  defp classify_pair(card) do
    String.to_atom("pair_#{card |> Atom.to_string() |> String.to_integer()}")
  end

  defp classify_soft(card) do
    String.to_atom("soft_#{(card |> Atom.to_string() |> String.to_integer()) + 11}")
  end

  defp classify_hard(points) when is_integer(points) do
    String.to_atom("hard_#{points}")
  end

  @doc """
  Determine if a hand is a bust

  ## Examples

    iex> Blackjack.bust?(~H"AKQ")
    false
    iex> Blackjack.bust?([:A, :K, :Q, :K])
    true
  """
  def bust?(hand) when is_list(hand) do
    hand_points(hand) > @bust_limit
  end

  @doc """
  Determine if a hand is a blackjack

  ## Examples

    iex> Blackjack.blackjack?([:A, :K])
    true
    iex> Blackjack.blackjack?([:A, :K, :Q])
    false
    iex> Blackjack.blackjack?([:A, :K, :Q, :K])
    false
  """
  def blackjack?(hand) when is_list(hand) do
    length(hand) == 2 and hand_points(hand) == 21
  end

  @doc """
  Determine the winnings for a player

  ## Examples

    iex> Blackjack.player_winnings([:"6", :"7", :"6"], [:A, :"3", :"4"], 10)
    {:win, 10}

    iex> Blackjack.player_winnings([:"6", :"7"], [:A, :"3", :"4"], 10)
    {:loss, -10}

    iex> Blackjack.player_winnings([:"6", :"7", :"6", :"9"], [:A, :"3", :"4"], 10)
    {:bust, -10}

    iex> Blackjack.player_winnings([:A, :K], [:A, :K], 10)
    {:push, 0}

    iex> Blackjack.player_winnings([:"6", :"7", :"4"], [:A, :"6"], 10)
    {:push, 0}

    iex> Blackjack.player_winnings([:A, :K], [:A, :"3"], 10)
    {:blackjack, 15}

    iex> Blackjack.player_winnings(~H"A3", ~H"AK", 10)
    {:dealer_blackjack, -10}
  """
  def player_winnings(player_hand, dealer_hand, wager)
      when is_list(player_hand) and is_list(dealer_hand) and is_integer(wager) do
    cond do
      blackjack?(dealer_hand) and not blackjack?(player_hand) ->
        {:dealer_blackjack, -wager}

      blackjack?(player_hand) and not blackjack?(dealer_hand) ->
        {:blackjack, trunc(wager * 1.5)}

      true ->
        player_points = hand_points(player_hand)
        dealer_points = hand_points(dealer_hand)

        cond do
          player_points > @bust_limit -> {:bust, -wager}
          dealer_points > @bust_limit or player_points > dealer_points -> {:win, wager}
          player_points == dealer_points -> {:push, 0}
          true -> {:loss, -wager}
        end
    end
  end
end
