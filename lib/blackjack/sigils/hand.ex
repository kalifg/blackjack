defmodule Blackjack.Sigils.Hand do
@doc """
Custom sigil for Blackjack hands.

To use the custom sigil, you need to import the module:

  import Blackjack.Sigils.Hand

  ## Examples
  iex> import Blackjack.Sigils.Hand
  iex> ~H"A3"
  [:A, :"3"]
  iex> ~H"AT"
  [:A, :T]
"""
  def sigil_H(string, _modifiers) do
    string
    |> String.graphemes()
    |> Enum.map(&String.to_atom/1)
  end
end
