defmodule Blackjack.PlayTableStrategy do
  alias Blackjack.Player
  import Blackjack.Sigils.PlayTable

  @behaviour Blackjack.PlayerStrategy

  @impl true

  @doc """
  Pull an action from the action table based on the player's hand and the dealer's card.

  If no actions are defined for a hand, default to :stand

  ## Examples

  iex> Blackjack.PlayTableStrategy.action(%Player{current_hand: ~H"99"}, :A)
  :stand

  iex> Blackjack.PlayTableStrategy.action(%Player{current_hand: ~H"99"}, :"2")
  :split

  iex> Blackjack.PlayTableStrategy.action(%Player{current_hand: ~H"92"}, :"3")
  :double

  iex> Blackjack.PlayTableStrategy.action(%Player{current_hand: ~H"AK"}, :"7")
  :stand

  iex> Blackjack.PlayTableStrategy.action(%Player{current_hand: ~H"678"}, :"7")
  :stand

  iex> Blackjack.PlayTableStrategy.action(%Player{current_hand: ~H"679"}, :"7")
  :stand

  iex> Blackjack.PlayTableStrategy.action(%Player{current_hand: ~H"6"}, :"7")
  :hit
  """
  def action(%Player{current_hand: [_card]}, _dealer_card) do
    :hit
  end

  def action(%Player{current_hand: hand}, dealer_card) do
    action_table()
    |> Map.get(hand |> Blackjack.classify_hand, :stand |> List.duplicate(10))
    |> Enum.at(dealer_card |> dealer_card_to_index)
  end

  defp dealer_card_to_index(:A) do
    9
  end

  defp dealer_card_to_index(dealer_card) when dealer_card in [:T, :J, :Q, :K] do
    8
  end

  defp dealer_card_to_index(dealer_card) do
    (dealer_card |> Atom.to_string |> String.to_integer) - 2
  end

  # Possible hand classifications:
  #
  # :single
  # :blackjack
  # :bust
  # :hard_{n}, where 5 <= n <= 21
  # :soft_{n}, where 13 <= n <= 20
  # :pair_{n}, where 2 <= n <= 10 or n == "A"
  defp action_table do
    ~P"""
    hard_5 :HHHHHHHHHH
    hard_6 :HHHHHHHHHH
    hard_7 :HHHHHHHHHH
    hard_8 :HHHHHHHHHH
    hard_9 :HDDDDHHHHH
    hard_10:DDDDDDDDHH
    hard_11:DDDDDDDDDH
    hard_12:HHSSSHHHHH
    hard_13:SSSSSHHHHH
    hard_14:SSSSSHHHHH
    hard_15:SSSSSHHHHH
    hard_16:SSSSSHHHHH
    soft_13:HHHDDHHHHH
    soft_14:HHHDDHHHHH
    soft_15:HHDDDHHHHH
    soft_16:HHDDDHHHHH
    soft_17:HDDDDHHHHH
    soft_18:SDDDDSSHHH
    pair_2 :PPPPPPHHHH
    pair_3 :PPPPPPHHHH
    pair_4 :HHHPPHHHHH
    pair_5 :DDDDDDDDHH
    pair_6 :PPPPPHHHHH
    pair_7 :PPPPPPHHHH
    pair_8 :PPPPPPPPPP
    pair_9 :PPPPPSPPSS
    pair_A :PPPPPPPPPP
    """
  end
end
