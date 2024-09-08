defmodule Blackjack.Sigils.PlayTable do
  @doc """
  Shorthand for specifying actions in a play table

  ## Format
  Multiple lines, each one a hand classification, colon, then what action to
  take for dealer cards in order from 2 to {10, J, Q, K} and then A

  H = Hit, S = Stand, D = Double Down, P = Split

  `~P\"\"\"
      <hand_classification1>:<2_action><3_action>...<10_action><A_action>`
      <hand_classification2>:<2_action><3_action>...<10_action><A_action>`
  \"\"\"

  Returns a map of the form
  ```
    %{
     :hand_classification1 => [:2_action, :3_action, ..., :10_action, :A_action],
     :hand_classification2 => [:2_action, :3_action, ..., :10_action, :A_action],
    }
  ```

  It can handle embedded spaces used to make sure the actions line up

  ## Examples

  iex> import Blackjack.Sigils.PlayTable
  iex> ~P\"\"\"
  ...>  hard_11:DDDDDDDDDH
  ...> pair_A: PPPPPPPPPP
  ...> soft_15:HHDDDHHHHH
  ...> pair_5:DDDDDDDDHH
  ...> \"\"\"
  %{
    :hard_11 => [:double, :double, :double, :double, :double, :double, :double, :double, :double, :hit],
    :pair_A => [:split, :split, :split, :split, :split, :split, :split, :split, :split, :split],
    :soft_15 => [:hit, :hit, :double, :double, :double, :hit, :hit, :hit, :hit, :hit],
    :pair_5 => [:double, :double, :double, :double, :double, :double, :double, :double, :hit, :hit]
  }
  """
  def sigil_P(string, _modifiers) do
    string
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      [hand_classification, actions] = String.split(line, ":", trim: true) |> Enum.map(&String.trim/1)
      Map.put(
        acc,
        hand_classification |> String.to_atom,
        actions |> String.to_charlist |> Enum.map(&char_to_action/1)
      )
    end)
  end

  defp char_to_action(char) when char in [?H, ?S, ?D, ?P] do
    case char do
      ?H -> :hit
      ?S -> :stand
      ?D -> :double
      ?P -> :split
    end
  end
end
