defmodule Blackjack.PlayerStrategy do
  alias Blackjack.Player
  @callback action(player :: %Player{}, dealer_card :: :A | :"2" | :"3" | :"4" | :"5" | :"6" | :"7" | :"8" | :"9" | :"10" | :J | :Q | :K) :: :hit | :stand | :double_down | :split
end
