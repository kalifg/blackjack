defmodule Blackjack do
  alias Blackjack.Dealer
  alias Blackjack.Deck
  alias Blackjack.Hand
  alias Blackjack.Player

  @moduledoc """
  Documentation for `Blackjack`.
  """
  def main([players, decks, rounds, sessions, strategy, funds, wager]) do
    for session <- 1..(sessions |> String.to_integer) do
      IO.puts("Session #{session}: attempting #{rounds} rounds of blackjack")

      deck = Deck.new(String.to_integer(decks))
      dealer = Dealer.new()

      players = Enum.map(1..String.to_integer(players), fn _ ->
        Player.new(
          String.to_integer(funds),
          Module.concat([strategy |> String.to_atom]),
          String.to_integer(wager)
        )
      end)

      {players, dealer, deck} =
        Enum.reduce(1..String.to_integer(rounds), {players, dealer, deck}, &play_or_exit/2)

      display_end_status(rounds, dealer, players, deck)
    end
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
    (hand |> Enum.join("")) <> " (" <> Integer.to_string(Hand.points(hand)) <> ")"
  end
end
